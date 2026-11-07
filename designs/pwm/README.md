# pwm -- pulse-width modulator (Module 2, basic)

Switches `pwm_out` high for `duty` out of every 2^WIDTH clock cycles. After a
low-pass filter the average is VDD x duty / 2^WIDTH, so this is a timer
peripheral, a motor/LED driver and a 1-bit DAC in one.

What to look at:

- `duty` is latched once per period (double buffering), so changing it
  mid-period never makes a short glitch pulse.
- The output comes straight from a flip-flop, so it cannot glitch either.
- The testbench checks the exact high time for duty values 0, 1, 16, 32, 48,
  63 and 8, and `make plot` shows the "RC-filtered" analog level.

| Target                | Result                                          |
| --------------------- | ----------------------------------------------- |
| `make sim`            | `PASS: all duty cycles exact`                   |
| `make plot`           | `build/pwm_out.png`                             |
| `make synth-sky130`   | ~70 cells                                       |
| `make pnr`            | 60 x 60 um die, 100 MHz                         |
