"""test_counter.py -- cocotb testbench for rtl/counter.v

The Verilog testbench (tb/counter_tb.v) and this file check the same thing;
compare them side by side. Here the "model" is two lines of ordinary Python,
and the stimulus is random, so every run explores a different enable pattern
(the seed is printed at the top of the log; replay it with
`make cocotb COCOTB_RANDOM_SEED=<seed>`).

Run:  make cocotb            (in designs/counter)
"""
import random

import cocotb
from cocotb.triggers import ClockCycles, FallingEdge, RisingEdge, ReadOnly

from cocotb_util import start


@cocotb.test()
async def test_reset(dut):
    """After reset the count is 0, and holds while en is low."""
    dut.en.value = 0
    await start(dut)
    await ClockCycles(dut.clk, 5)
    await ReadOnly()
    assert dut.count.value == 0, f"count = {int(dut.count.value)} after reset"
    assert dut.wrap.value == 0


@cocotb.test()
async def test_wraps(dut):
    """Counting 2^WIDTH cycles comes back to 0, with exactly one wrap pulse."""
    width = len(dut.count)
    dut.en.value = 1
    await start(dut)
    wraps = 0
    for _ in range(2**width):
        await RisingEdge(dut.clk)
        await ReadOnly()
        wraps += int(dut.wrap.value)
    assert dut.count.value == 0, "count should be back to 0 after 2^WIDTH cycles"
    assert wraps == 1, f"expected one wrap pulse, saw {wraps}"


@cocotb.test()
async def test_random_enable(dut):
    """Random en pattern, every cycle compared with a Python model."""
    width = len(dut.count)
    mask = (1 << width) - 1
    dut.en.value = 0
    await start(dut)

    model = 0
    for cycle in range(2000):
        en = random.random() < 0.7
        dut.en.value = int(en)

        # Combinational output, checked before the clock edge
        await ReadOnly()
        expect_wrap = en and model == mask
        assert dut.wrap.value == expect_wrap, f"cycle {cycle}: wrap wrong"

        # Registered output, checked after the clock edge
        await RisingEdge(dut.clk)
        if en:
            model = (model + 1) & mask
        await ReadOnly()
        assert dut.count.value == model, (
            f"cycle {cycle}: count = {int(dut.count.value)}, model = {model}"
        )
        await FallingEdge(dut.clk)
