"""test_pwm.py -- cocotb testbench for rtl/pwm.v

Two ideas that are much easier in Python than in a Verilog testbench:

1. A *monitor*: a coroutine that runs in the background for the whole test,
   watches the output pins, and turns them into transactions ("this period
   was high for N cycles"). The test itself never looks at single cycles.
2. *Parametrised* tests: one test function, run once per duty value.

Run:  make cocotb            (in designs/pwm)
"""
import random

import cocotb
from cocotb.triggers import ClockCycles, FallingEdge, ReadOnly, RisingEdge

from cocotb_util import start


class PeriodMonitor:
    """Watches pwm_out and records (duty latched, cycles high) for every period.

    pwm.v latches `duty` on the clock edge where the counter wraps to 0
    (period_start goes high), and drives pwm_out from a register, so the
    pin lags the counter by one cycle. The monitor follows the same rule.
    """

    def __init__(self, dut):
        self.dut = dut
        self.periods = []          # list of (expected_high, measured_high)
        cocotb.start_soon(self._run())

    async def _run(self):
        dut = self.dut
        expected, high, samples = None, 0, 0
        while True:
            await RisingEdge(dut.clk)
            duty_at_edge = int(dut.duty.value)   # value the flops just sampled
            await ReadOnly()
            # This cycle's pin value still belongs to the period that is ending
            high += int(dut.pwm_out.value)
            samples += 1
            if dut.period_start.value == 1:
                if expected is not None and samples == 2 ** len(dut.duty):
                    self.periods.append((expected, high))
                expected, high, samples = duty_at_edge, 0, 0


@cocotb.test()
@cocotb.parametrize(duty=[0, 1, 64, 128, 200, 255])
async def test_duty(dut, duty):
    """A constant duty value gives exactly `duty` high cycles per period."""
    dut.duty.value = duty
    await start(dut)
    mon = PeriodMonitor(dut)
    await ClockCycles(dut.clk, 4 * 2 ** len(dut.duty))
    assert len(mon.periods) >= 2, "monitor saw no complete periods"
    for expected, high in mon.periods:
        assert high == duty, f"duty={duty}: period was high for {high} cycles"


@cocotb.test()
async def test_no_glitch(dut):
    """duty changes at random moments, even mid-period.

    Every period must still be high for exactly the duty value that was
    latched at its start: the double buffering in pwm.v means a change can
    never produce a period that is a mix of the old and the new value.
    """
    period = 2 ** len(dut.duty)
    dut.duty.value = 0
    await start(dut)
    mon = PeriodMonitor(dut)

    for _ in range(40):
        await ClockCycles(dut.clk, random.randint(1, 2 * period), rising=False)
        dut.duty.value = random.randint(0, period - 1)
    await ClockCycles(dut.clk, 2 * period)

    assert len(mon.periods) > 10
    for i, (expected, high) in enumerate(mon.periods):
        assert high == expected, f"period {i}: expected {expected} high cycles, got {high}"
    dut._log.info("checked %d periods", len(mon.periods))
