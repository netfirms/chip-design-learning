"""test_fir.py -- cocotb testbench for rtl/fir.v

The point of this testbench: the reference model is the *same Python* that
designed the filter (python/dsp_coeffs.py). If someone re-designs the filter
and forgets to update the coefficient ROM in fir.v, this test fails.

Structure (the usual verification "layers"):

    driver  --in_sample-->  DUT  --out_sample-->  monitor
       |                                             |
       +----> model (Python) ----> expected queue ---+--> scoreboard (compare)

Run:  make cocotb            (in designs/fir)
"""
import random
from collections import deque

import numpy as np

import cocotb
from cocotb.triggers import FallingEdge, ReadOnly, RisingEdge

import dsp_coeffs
from cocotb_util import q15, saturate, start

H = [int(c) for c in dsp_coeffs.quantise_fir(dsp_coeffs.design_fir())]
FRAC = dsp_coeffs.FIR_FRAC


class FirModel:
    """Bit-exact model of fir.v: full-precision MAC, round half up, saturate."""

    def __init__(self):
        self.x = [0] * len(H)          # x[n], x[n-1], ...

    def push(self, sample):
        self.x = [sample] + self.x[:-1]
        acc = sum(h * x for h, x in zip(H, self.x))
        return saturate((acc + (1 << (FRAC - 1))) >> FRAC)


class FirTB:
    """Driver + monitor + scoreboard around one fir instance."""

    def __init__(self, dut):
        self.dut = dut
        self.model = FirModel()
        self.expected = deque()
        self.outputs = []
        self.errors = 0
        dut.in_valid.value = 0
        dut.in_sample.value = 0
        cocotb.start_soon(self._monitor())

    async def send(self, sample, gap=0):
        """Drive one sample with the valid/ready handshake (on falling edges)."""
        dut = self.dut
        for _ in range(gap):
            await FallingEdge(dut.clk)
        while True:
            await FallingEdge(dut.clk)
            if dut.in_ready.value == 1:
                break
        dut.in_sample.value = sample
        dut.in_valid.value = 1
        self.expected.append(self.model.push(sample))
        await FallingEdge(dut.clk)
        dut.in_valid.value = 0

    async def _monitor(self):
        dut = self.dut
        while True:
            await RisingEdge(dut.clk)
            await ReadOnly()
            if dut.out_valid.value == 1:
                y = dut.out_sample.value.to_signed()
                self.outputs.append(y)
                assert self.expected, "out_valid without an input"
                want = self.expected.popleft()
                if y != want:
                    self.errors += 1
                    dut._log.error("output %d: got %d, model %d",
                                   len(self.outputs) - 1, y, want)

    async def drain(self):
        """Wait until every sample sent has come out."""
        while self.expected:
            await RisingEdge(self.dut.clk)
        await FallingEdge(self.dut.clk)
        assert self.errors == 0, f"{self.errors} outputs differ from the model"


def test_coefficients_match_design():
    """Not a simulation: a plain check that the ROM is the filter we designed."""
    assert sum(H) == 2**FRAC, "DC gain must be exactly 1.0"
    assert H == H[::-1], "linear-phase FIR must be symmetric"


@cocotb.test()
async def test_impulse(dut):
    """An impulse of (almost) 1.0 reproduces the coefficients h[0..15]."""
    await start(dut)
    test_coefficients_match_design()
    tb = FirTB(dut)
    for x in [32767] + [0] * (len(H) + 4):
        await tb.send(x)
    await tb.drain()
    for k, h in enumerate(H):
        assert abs(tb.outputs[k] - h) <= 1, f"tap {k}: {tb.outputs[k]} != {h}"


@cocotb.test()
async def test_random_bit_exact(dut):
    """Random full-scale samples and random gaps between them."""
    await start(dut)
    tb = FirTB(dut)
    for _ in range(500):
        await tb.send(random.randint(-32768, 32767), gap=random.choice([0, 0, 0, 3, 20]))
    await tb.drain()
    dut._log.info("%d samples bit-exact vs. the Python model", len(tb.outputs))


@cocotb.test()
async def test_saturation(dut):
    """A worst-case input pattern pushes the sum past 1.0: output must clip, not wrap."""
    await start(dut)
    tb = FirTB(dut)
    # sign(h[k]) * full scale makes every product positive
    worst = [32767 if h > 0 else -32768 for h in H[::-1]]
    for x in worst * 3:
        await tb.send(x)
    await tb.drain()
    assert max(tb.outputs) == 32767, "expected the output to saturate at +32767"


@cocotb.test()
async def test_frequency_response(dut):
    """Measure |H(f)| from the hardware at a few frequencies and compare with numpy."""
    await start(dut)
    tb = FirTB(dut)
    n, amp = 256, 0.5
    for f in (0.02, 0.1, 0.3):
        tb.outputs.clear()
        x = [q15(amp * np.sin(2 * np.pi * f * i)) for i in range(n)]
        for s in x:
            await tb.send(s)
        await tb.drain()
        y = np.array(tb.outputs[2 * len(H):]) / 32768      # skip the start-up transient
        t = np.arange(2 * len(H), n)
        # Least-squares fit of a sine at f: amplitude of the output tone
        basis = np.column_stack([np.sin(2 * np.pi * f * t), np.cos(2 * np.pi * f * t)])
        gain = np.hypot(*np.linalg.lstsq(basis, y, rcond=None)[0]) / amp
        ideal = abs(np.sum(np.array(H) / 2**FRAC * np.exp(-2j * np.pi * f * np.arange(len(H)))))
        dut._log.info("f = %.2f fs: |H| = %.4f (%.1f dB), ideal %.4f",
                      f, gain, 20 * np.log10(gain + 1e-9), ideal)
        assert abs(gain - ideal) < 0.002 + 0.01 * ideal, f"gain at {f} fs off"
