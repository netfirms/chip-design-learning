"""test_iir.py -- cocotb testbench for rtl/iir.v

The biquad accepts a sample every clock, so the driver streams samples
back to back and a monitor checks each output one cycle later. The model
takes its coefficients from python/dsp_coeffs.py, the script that designed
the filter, rounded to Q2.14 exactly as the RTL constants were.

Feedback filters have failure modes FIRs do not: overflow that wraps
around and makes the filter oscillate, and "limit cycles" where rounding
keeps a small output alive forever after the input stops. Both get a test.

Run:  make cocotb            (in designs/iir)
"""
import random
from collections import deque

import numpy as np

import cocotb
from cocotb.triggers import FallingEdge, ReadOnly, RisingEdge

import dsp_coeffs
from cocotb_util import q15, saturate, start

FRAC = dsp_coeffs.IIR_FRAC
_b, _a = dsp_coeffs.design_biquad_lowpass()
B = [int(v) for v in np.round(_b * 2**FRAC)]
A = [int(v) for v in np.round(_a * 2**FRAC)]     # A[0] = 2^14 (a0 = 1)


class BiquadModel:
    """Bit-exact Direct Form I biquad, same rounding and saturation as iir.v."""

    def __init__(self):
        self.x1 = self.x2 = self.y1 = self.y2 = 0

    def push(self, x):
        acc = (B[0] * x + B[1] * self.x1 + B[2] * self.x2
               - A[1] * self.y1 - A[2] * self.y2)
        y = saturate((acc + (1 << (FRAC - 1))) >> FRAC)
        self.x2, self.x1 = self.x1, x
        self.y2, self.y1 = self.y1, y
        return y


async def stream(dut, samples, model=None):
    """Drive one sample per clock, check every output against the model.

    Pass the same `model` to consecutive calls: the filter keeps its state
    between them, so the model must too. Returns the hardware's outputs.
    """
    model = model or BiquadModel()
    expected = deque()
    outputs = []

    async def monitor():
        while True:
            await RisingEdge(dut.clk)
            await ReadOnly()
            if dut.out_valid.value == 1:
                y = dut.out_sample.value.to_signed()
                want = expected.popleft()
                assert y == want, f"output {len(outputs)}: got {y}, model {want}"
                outputs.append(y)

    mon = cocotb.start_soon(monitor())
    for x in samples:
        await FallingEdge(dut.clk)
        dut.in_sample.value = x
        dut.in_valid.value = 1
        expected.append(model.push(x))
    await FallingEdge(dut.clk)
    dut.in_valid.value = 0
    await FallingEdge(dut.clk)
    mon.cancel()
    assert not expected, f"{len(expected)} samples never came out"
    return outputs


async def setup(dut):
    dut.in_valid.value = 0
    dut.in_sample.value = 0
    await start(dut)


@cocotb.test()
async def test_step(dut):
    """A step of 0.5 settles at 0.5 (DC gain 1), overshooting about 4 %."""
    await setup(dut)
    y = await stream(dut, [q15(0.5)] * 300)
    final = y[-1] / 32768
    overshoot = max(y) / 32768 / 0.5 - 1
    dut._log.info("step: final %.4f, overshoot %.1f %%", final, 100 * overshoot)
    assert abs(final - 0.5) < 0.002
    assert 0.02 < overshoot < 0.07, "a Butterworth biquad overshoots by ~4 %"


@cocotb.test()
async def test_random_bit_exact(dut):
    """Random half-scale input, every output compared with the model."""
    await setup(dut)
    y = await stream(dut, [random.randint(-16384, 16383) for _ in range(2000)])
    dut._log.info("%d samples bit-exact vs. the Python model", len(y))


def dead_band():
    """Largest constant output the filter can hold forever with zero input.

    With x = 0 and y[n-1] = y[n-2] = y, the next output is
    round(y * (-a1 - a2)). Because -a1 - a2 = 0.92 is close to 1, rounding
    gives back y itself for small y: a *granular limit cycle* (dead band).
    """
    y = 1
    while ((-A[1] - A[2]) * (y + 1) + (1 << (FRAC - 1))) >> FRAC == y + 1:
        y += 1
    return y


@cocotb.test()
async def test_overload_recovers(dut):
    """A full-scale square wave drives the output into saturation.

    With saturation the filter clips and then recovers. If the RTL wrapped
    around instead, the huge wrong value would be fed back and the output
    would swing wildly long after the input went quiet. What it *does* do is
    get stuck a few LSBs from zero: the dead band, see dead_band().
    """
    await setup(dut)
    square = ([32767] * 40 + [-32768] * 40) * 4
    y = await stream(dut, square + [0] * 400)
    assert max(y) == 32767 or min(y) == -32768, "expected saturation"
    tail = y[-50:]
    limit = dead_band()
    dut._log.info("after the input stops the output settles at %d LSB "
                  "(dead band of this biquad: +/-%d LSB)", tail[-1], limit)
    assert max(abs(v) for v in tail) <= limit, f"output did not settle: {tail[-5:]}"
    assert len(set(tail)) == 1, "expected a constant (DC) limit cycle"


@cocotb.test()
async def test_frequency_response(dut):
    """|H(f)| measured on the hardware, compared with the quantised design."""
    await setup(dut)
    model = BiquadModel()
    n, amp = 600, 0.4
    for f in (0.01, 0.05, 0.2):
        x = [q15(amp * np.sin(2 * np.pi * f * i)) for i in range(n)]
        y = np.array(await stream(dut, x, model))
        t = np.arange(200, n)                         # skip the transient
        basis = np.column_stack([np.sin(2 * np.pi * f * t), np.cos(2 * np.pi * f * t)])
        gain = np.hypot(*np.linalg.lstsq(basis, y[200:] / 32768, rcond=None)[0]) / amp
        z = np.exp(-2j * np.pi * f * np.arange(3))
        ideal = abs(np.dot(B, z) / np.dot(A, z))
        dut._log.info("f = %.2f fs: |H| = %.4f (%.1f dB), ideal %.4f",
                      f, gain, 20 * np.log10(gain), ideal)
        assert abs(gain - ideal) < 0.002 + 0.01 * ideal, f"gain at {f} fs off"
