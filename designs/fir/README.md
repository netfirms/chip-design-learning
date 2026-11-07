# fir -- 16-tap low-pass FIR filter (Module 4, advanced)

y[n] = sum h[k] x[n-k], k = 0..15, with Q1.15 samples and coefficients, a
cutoff of 0.1 fs (designed by `python/dsp_coeffs.py`), round-to-nearest and
saturation on the output.

**Architecture:** one multiplier and one accumulator are reused for all 16
taps, so a sample takes 17 clock cycles. That is the opposite trade-off from
`designs/iir`, which computes everything in one cycle.

**Verification:** impulse response = coefficients; 300 random full-scale
samples compared bit for bit with a model of the same arithmetic; and the
gain at 0.02 fs (pass band) and 0.3 fs (stop band) measured from sine bursts.

| Target                | Result                                                      |
| --------------------- | ----------------------------------------------------------- |
| `make sim`            | `PASS: 720 samples bit-exact vs. model, filter response OK` |
| `make plot`           | `build/fir_out.png`: waveforms and |H(f)| measured from the hardware |
| `make synth-sky130`   | ~2,300 cells; the 16 x 16-bit delay line is 256 flip-flops  |
| `make pnr`            | 100 MHz (10 ns clock)                                       |

To change the filter: edit `FIR_CUTOFF` or `FIR_TAPS` in
`python/dsp_coeffs.py`, run it, and paste the printed coefficients into
`rtl/fir.v` (function `coef`) and `tb/fir_tb.v` (array `h`).
