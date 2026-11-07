# Fixed-point arithmetic for DSP hardware

In MATLAB or numpy a filter coefficient is `0.0201` and nobody thinks about
it. In hardware there is no floating point unless you pay for one (a single
float multiplier is bigger than this whole repo's FIR). Instead, DSP hardware
uses **fixed point**: an integer with an implied binary point.

## Q format

`Qm.n` means a signed number with `m` integer bits (including the sign) and
`n` fractional bits, stored as an `m+n`-bit two's-complement integer `v`.
The real value is

```
real = v / 2^n
```

| Format | Bits | Range                | Resolution (1 LSB)   | Used for                      |
| ------ | ---- | -------------------- | -------------------- | ----------------------------- |
| Q1.15  | 16   | [-1, 1 - 2^-15]      | 3.05e-5 (~ -90 dB)   | samples, FIR coefficients     |
| Q2.14  | 16   | [-2, 2 - 2^-14]      | 6.1e-5               | IIR coefficients (|a1| up to 2) |
| Q1.7   | 8    | [-1, 1 - 2^-7]       | 7.8e-3 (~ -42 dB)    | low-cost audio, ML inference  |

Examples in Q1.15: `0.5 -> 16384`, `-1.0 -> -32768`, `0.0201 -> 659`
(rounded from 658.6).

A 16-bit sample has about 6 dB per bit x 16 = **~96 dB** of dynamic range;
the same rule tells you how many bits an ADC or a filter's output needs.

## Arithmetic rules

**Addition** needs both operands in the same format. The result can be one
bit wider: `Q1.15 + Q1.15` fits in `Q2.15`. Adding `N` values needs
`ceil(log2(N))` extra *guard bits*. That is why the 16-tap FIR's accumulator
has 4 guard bits.

**Multiplication** adds the formats: `Qa.b x Qc.d = Q(a+c).(b+d)`.
`Q1.15 x Q1.15 = Q2.30` (32 bits). To get back to Q1.15 you shift right by
15 and keep 16 bits.

**Rounding** when you drop fractional bits:

- *Truncation* (`>>> n`) rounds toward minus infinity: cheap, but biased by
  -0.5 LSB on average. The FFT example uses it, and `make plot` in
  `designs/fft` shows the resulting error histogram leaning negative.
- *Round to nearest* (`(x + 2^(n-1)) >>> n`) costs one adder and has no bias.
  The FIR and IIR examples use it.

**Overflow** when the result does not fit:

- *Wrap-around* (the default in Verilog) turns a large positive value into a
  large negative one: a loud click in audio, and in an IIR filter it can
  start an oscillation that never stops.
- *Saturation* clamps to the largest/smallest value. It costs two comparators
  and a mux; the FIR and IIR outputs saturate.
- *Scaling* avoids overflow by design: the FFT halves every butterfly output
  so the values can never grow.

## In Verilog

```verilog
// Declare signed, or comparisons and shifts treat values as unsigned
wire signed [15:0] x, h;            // Q1.15
wire signed [31:0] p = x * h;       // Q2.30, both operands signed -> signed multiply

// Sign-extend before adding into a wider accumulator
wire signed [35:0] acc_next = acc + {{4{p[31]}}, p};

// Round to nearest and return to Q1.15
wire signed [35:0] r = (acc_next + (1 <<< 14)) >>> 15;

// Saturate
wire signed [15:0] y = (r >  32767) ?  16'sd32767 :
                       (r < -32768) ? -16'sd32768 : r[15:0];
```

Pitfalls:

- If *either* operand of `*` is unsigned, Verilog does an unsigned multiply.
  Mixing `signed` with a plain `wire` or a sized literal like `4'd3` silently
  breaks the sign.
- `>>` is a logical shift (fills with 0). Use `>>>` on signed values.
- A part-select like `p[30:15]` is always unsigned. Wrap it in `$signed()` if
  you keep computing with it.

## Coefficient quantisation

Rounding coefficients to 16 bits changes the filter.
`python3 python/dsp_coeffs.py` prints the response before and after
quantisation. For the FIR the change is a fraction of a dB. IIR filters are
more sensitive: the poles move, and with too few bits a filter with poles
near the unit circle can become unstable. The script prints the pole radius,
which must stay below 1.

## Exercises

1. Convert `0.70710678` (sqrt(2)/2, used in the FFT) to Q1.15. What is the
   error in LSBs?
2. What Q format does the product of a Q1.15 sample and a Q2.14 coefficient
   have? How many bits is it?
3. In `designs/fir/rtl/fir.v`, replace the round-to-nearest with plain
   truncation. Does the testbench catch it? (It should: the model rounds.)
   Update the model too and compare the DC error of a long constant input.
4. Reduce the IIR coefficients to Q2.8 in `python/dsp_coeffs.py`. How far do
   the poles move? Is the filter still stable?
