"""cocotb_util.py -- small helpers shared by every cocotb testbench in designs/*/cocotb/.

Every design in this course has the same clock and reset ports (clk, rst_n),
so starting the clock and resetting the DUT is the same few lines each time.
"""
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, FallingEdge

CLK_PERIOD_NS = 10  # 100 MHz, the same clock as constraint.sdc


async def start(dut, reset_cycles=3):
    """Start a 100 MHz clock on dut.clk and pulse the active-low reset.

    Returns on a falling edge, which is the safe moment to drive inputs:
    half a clock away from the rising edge where the DUT samples them.
    """
    cocotb.start_soon(Clock(dut.clk, CLK_PERIOD_NS, unit="ns").start())
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, reset_cycles)
    await FallingEdge(dut.clk)
    dut.rst_n.value = 1


def q15(x):
    """Real number in [-1, 1) -> nearest Q1.15 integer, saturated."""
    return max(-32768, min(32767, int(round(x * 32768))))


def saturate(v, bits=16):
    """Clamp an integer to the signed range of a `bits`-wide register."""
    lo, hi = -(1 << (bits - 1)), (1 << (bits - 1)) - 1
    return max(lo, min(hi, v))
