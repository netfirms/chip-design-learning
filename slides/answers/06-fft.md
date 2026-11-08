# Quiz answers: Module 6: The FFT

Answer key for the quiz at the end of [`06-fft.md`](../06-fft.md).

## 1. How many radix-2 butterflies does a 1024-point FFT have?

- **A** 1,024
- **B** 5,120 ✔
- **C** 10,240
- **D** 1,048,576

**Answer: B.** (N/2) · log2 N = 512 · 10 = 5,120. Our 8-point FFT has 4 · 3 = 12.

## 2. In the 8-point FFT, input x[6] goes to which position in stage 1?

- **A** 1
- **B** 3 ✔
- **C** 5
- **D** 6

**Answer: B.** 6 = 110 in binary; reversed, 011 = 3. Bit reversal is pure wiring in hardware: it costs nothing.

## 3. Which two of the 8-point twiddle factors need no multiplier?

**Answer:** W^0 = 1 and W^2 = −j.

Multiplying by 1 is a wire; multiplying by −j is swap re/im and negate one. W^1 and W^3 need a constant multiply by √2/2 per component.

## 4. The input is Q1.15 (16 bits) and every stage divides by 2. Why are the internal and output words 17 bits, not 16?

**Answer:** A complex value with |re|, |im| < 1 can have magnitude up to √2, so one extra integer bit is needed even with the ÷2 per stage.

÷2 per stage cancels the 8× growth from the three stages (overall 1/8). The √2 is left over.

## 5. The error histogram leans negative. Why?

- **A** the twiddles are rounded up
- **B** truncating every stage rounds toward −∞ ✔
- **C** the testbench is wrong
- **D** overflow

**Answer: B.** `s[IW:1]` drops one bit each stage: a −½ LSB bias, accumulated over 3 stages. Round to nearest centres it on 0 (Exercise 3).

## 6. With the frame x[n] = A for all n (DC), what does our FFT (with its 1/8 scaling) output?

- **A** X[0] = 8A, others 0
- **B** X[0] = A, others 0 ✔
- **C** X[k] = A/8 for all k
- **D** X[k] = A for all k

**Answer: B.** X[0] = (1/8) · Σ A = A, and every other bin sums a full cycle of twiddles to 0. An impulse gives the opposite: flat A/8.

## 7. The design takes 17 cycles per 8-sample frame at 50 MHz. What is its throughput?

- **A** ~2.9 MS/s
- **B** ~6.25 MS/s
- **C** ~23.5 MS/s ✔
- **D** 400 MS/s

**Answer: C.** 8 samples / 17 cycles · 50 MHz ≈ 23.5 MS/s. Load and unload are serial; the compute is one long combinational cycle.

## 8. A wrong twiddle factor is a structural bug. Which test is designed to catch it?

**Answer:** A known-answer frame, such as the complex tone e^(j2π·3n/8), which must land in X[3] only.

Known-answer frames catch structural bugs (wrong twiddle, wrong wiring); random frames against a floating-point DFT catch arithmetic bugs.
