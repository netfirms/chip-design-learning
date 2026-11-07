# iir -- 2nd-order IIR low-pass biquad (Module 5, advanced)

y[n] = b0 x[n] + b1 x[n-1] + b2 x[n-2] - a1 y[n-1] - a2 y[n-2]: a Butterworth
low-pass with cutoff 0.05 fs, coefficients in Q2.14, designed by
`python/dsp_coeffs.py` with the bilinear transform.

**Architecture:** fully parallel, one sample per clock. The coefficients are
constants, so synthesis turns each multiplier into shifts and adds. The
feedback path (y[n-1] -> multiply -> add -> y[n]) is the critical path and
cannot be pipelined without changing the filter, so this design runs at a
50 MHz clock.

**Verification:** step response settles to the input (DC gain 1); 300 random
samples bit-exact vs. a model; gain at 0.01 fs (pass) and 0.2 fs (stop,
about -26 dB).

| Target                | Result                                                       |
| --------------------- | ------------------------------------------------------------ |
| `make sim`            | `PASS: 1400 samples bit-exact vs. model, filter response OK` |
| `make plot`           | `build/iir_out.png`                                          |
| `make synth-sky130`   | ~2,400 cells                                                 |
| `make pnr`            | 50 MHz (20 ns clock)                                         |
