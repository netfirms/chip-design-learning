# fft -- 8-point complex FFT (Module 6, advanced)

X[k] = (1/8) sum x[n] exp(-j 2 pi n k / 8), radix-2 decimation in time, with
16-bit complex inputs and 17-bit complex outputs.

- `rtl/fft_bfly.v`: one butterfly with a fixed twiddle. For N = 8 the
  twiddles are 1, -j (free: swap and negate) and sqrt(2)/2 (1 +/- j), which
  is one constant multiply per component.
- `rtl/fft8.v`: bit-reversal, three stages of four butterflies, and a small
  state machine: load 8 samples, compute in one cycle, stream out X[0..7].

Each butterfly divides by 2, so the output never overflows. The price is
truncation error, which `make plot` shows as a histogram leaning slightly
negative (truncation always rounds down).

**Verification:** every frame is compared with a floating-point DFT within
3 LSB: impulse, DC, a cosine on bin 1, a complex tone on bin 3, full-scale
corners and 20 random frames.

| Target                | Result                                                  |
| --------------------- | ------------------------------------------------------- |
| `make sim`            | `PASS: 26 frames, max error 2 LSB (tolerance 3)`        |
| `make plot`           | `build/fft8_out.png`: spectra vs. exact DFT, error histogram |
| `make synth-sky130`   | ~7,700 cells                                            |
| `make pnr`            | 50 MHz (20 ns clock)                                    |
