# SPDX-FileCopyrightText: © 2026 chip-design-learning contributors
# SPDX-License-Identifier: Apache-2.0
"""cocotb test for the Tiny Tapeout FIR project.

Talks to the chip only through its pins, like the RP2040 on the demo board:
put a sample on ui_in, pulse STROBE (uio[0]), wait for TOGGLE (uio[3]) to
flip, read the filtered sample from uo_out. Every output is compared bit for
bit with a Python model of the same fixed-point arithmetic.

    cd test && make -B               # RTL
    cd test && make -B GATES=yes     # gate level, after the GDS action
"""
import math
import random

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, FallingEdge

# Q1.15 coefficients, the same as in src/fir.v (python/dsp_coeffs.py)
H = [-114, -159, -139, 291, 1450, 3284, 5246, 6525,
     6525, 5246, 3284, 1450, 291, -139, -159, -114]


class FirModel:
    """Bit-exact model: 8-bit samples, Q1.15 taps, round, saturate."""

    def __init__(self):
        self.x = [0] * len(H)

    def push(self, sample):
        self.x = [sample] + self.x[:-1]
        acc = sum(h * x for h, x in zip(H, self.x))
        y = (acc + (1 << 14)) >> 15          # round to nearest, Q1.7
        return max(-128, min(127, y))        # saturate


def signed8(v):
    v = int(v)
    return v - 256 if v & 0x80 else v


async def send(dut, sample):
    """Send one sample through the pins and return the filter's output."""
    while not (int(dut.uio_out.value) >> 1) & 1:          # READY
        await FallingEdge(dut.clk)
    toggle = (int(dut.uio_out.value) >> 3) & 1
    dut.ui_in.value = sample & 0xFF
    dut.uio_in.value = 1                                    # STROBE high
    await ClockCycles(dut.clk, 4)
    dut.uio_in.value = 0
    for _ in range(100):
        await FallingEdge(dut.clk)
        if (int(dut.uio_out.value) >> 3) & 1 != toggle:     # TOGGLE flipped
            return signed8(dut.uo_out.value)
    raise AssertionError("no output: TOGGLE did not flip")


@cocotb.test()
async def test_project(dut):
    dut._log.info("Start")

    # 50 MHz, the Tiny Tapeout default clock
    clock = Clock(dut.clk, 20, unit="ns")
    cocotb.start_soon(clock.start())

    dut._log.info("Reset")
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 2)

    assert int(dut.uio_oe.value) == 0b0000_1110, "uio[3:1] must be outputs"

    model = FirModel()

    dut._log.info("Impulse response: x = 127 then zeros")
    impulse = [127] + [0] * (len(H) + 3)
    for i, x in enumerate(impulse):
        y = await send(dut, x)
        assert y == model.push(x), f"impulse sample {i}: got {y}"

    dut._log.info("Random full-scale samples")
    rng = random.Random(1)
    for i in range(200):
        x = rng.randint(-128, 127)
        y = await send(dut, x)
        assert y == model.push(x), f"random sample {i}: x={x} got {y}"

    dut._log.info("Pass band (0.02 fs) and stop band (0.3 fs)")
    for f, lo, hi in ((0.02, 0.95, 1.02), (0.30, 0.0, 0.02)):
        peak = 0
        for i in range(120):
            x = round(100 * math.sin(2 * math.pi * f * i))
            y = await send(dut, x)
            assert y == model.push(x)
            if i >= 2 * len(H):
                peak = max(peak, abs(y))
        gain = peak / 100
        dut._log.info(f"gain at {f} fs = {gain:.3f}")
        assert lo <= gain <= hi, f"gain {gain:.3f} at {f} fs out of range"
