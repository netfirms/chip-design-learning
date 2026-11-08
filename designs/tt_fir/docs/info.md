## How it works

A 16-tap low-pass FIR filter, y[n] = Σ h[k]·x[n−k] for k = 0..15. The
coefficients are a Hamming-windowed sinc with a cutoff of 0.1·f_s, stored as
signed Q1.15 constants (their sum is 1.0, so the DC gain is 1).

Samples are 8-bit signed Q1.7 (−128..127 means −1.0..+0.992). One
multiplier and one 28-bit accumulator are shared by all 16 taps, so every
sample takes 17 clock cycles: 1 to load it into the delay line, 16 to
multiply and accumulate. The result is rounded to the nearest Q1.7 value and
saturated instead of wrapping around. At 50 MHz the filter takes up to
about 2.9 million samples per second.

The design comes from the open course
[chip-design-learning](https://github.com/netfirms/chip-design-learning)
(Module 9). The filter core, `fir.v`, is the same file as the course's
16-bit FIR, built with its sample width set to 8.

| Pin | Direction | Function |
| --- | --- | --- |
| `ui[7:0]` | in | X, the next input sample (signed) |
| `uo[7:0]` | out | Y, the latest filtered sample (signed), held until the next one |
| `uio[0]` | in | STROBE: a rising edge loads X. Synchronised on chip, so it can come from anywhere |
| `uio[1]` | out | READY: high when a new sample can be loaded |
| `uio[2]` | out | VALID: high for one clock when Y changes |
| `uio[3]` | out | TOGGLE: flips every time Y changes |

## How to test

1. Reset the design (`rst_n` low, then high). Y reads 0.
2. Put a sample on `ui[7:0]`, then raise STROBE (`uio[0]`) and keep it high
   for at least 4 clock cycles. Keep X steady until you lower STROBE.
3. Wait for TOGGLE (`uio[3]`) to flip (about 19 clocks after STROBE rose), then read
   `uo[7:0]`.

Things to try from the demo board's microcontroller:

- **Impulse:** send 127 once, then zeros. Y walks through the coefficients
  scaled to 8 bits: 0, −1, −1, 1, 6, 13, 20, 25, 25, 20, 13, 6, 1, −1, −1, 0
  (exact values are in `test/test.py`).
- **Step:** send 100 again and again. Y settles at 100 after 16 samples
  (DC gain 1).
- **Pass band vs. stop band:** a sine at 0.02·f_s comes out at the same
  amplitude; a sine at 0.3·f_s comes out as 0 (below 1 LSB).

## External hardware

None. The demo board's RP2040 can drive X and STROBE and read Y. A DIP
switch on the inputs, a push button on `uio[0]` and LEDs on the outputs
work too.
