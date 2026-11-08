# Quiz answers: Module 4: FIR filters

Answer key for the quiz at the end of [`04-fir.md`](../04-fir.md).

## 1. How many clock cycles does the time-shared FIR spend per sample, and what sample rate is that at 100 MHz?

- **A** 16, 6.25 MS/s
- **B** 17, ~5.9 MS/s ✔
- **C** 1, 100 MS/s
- **D** 32, ~3.1 MS/s

**Answer: B.** One cycle to accept the sample plus 16 multiply-accumulate cycles = 17 cycles. 100 MHz / 17 ≈ 5.9 MS/s.

## 2. The 16-tap filter's accumulator is 36 bits. How wide would it be for 64 taps (same Q1.15 inputs and coefficients)?

- **A** 36
- **B** 38 ✔
- **C** 40
- **D** 64

**Answer: B.** AW = W + CW + guard bits = 16 + 16 + log2(64) = 16 + 16 + 6 = 38.

## 3. A symmetric (linear-phase) FIR has 31 taps. By how many samples does it delay every frequency?

- **A** 7.5
- **B** 15 ✔
- **C** 15.5
- **D** 31

**Answer: B.** The group delay of a symmetric FIR with N taps is (N − 1) / 2 = 30 / 2 = 15 samples. For our 16 taps it is 7.5.

## 4. On which clock edge does a sample move from the source into the filter?

**Answer:** On a rising edge where `in_valid && in_ready` (here `in_ready = !busy`).

That is the valid/ready contract, as in AXI-Stream. Until then the source holds `in_sample` and `in_valid` steady.

## 5. The Q1.15 coefficients sum to exactly 32768. What does that tell you?

- **A** the filter is unstable
- **B** the DC gain is exactly 1.0 ✔
- **C** the filter is high-pass
- **D** the output saturates

**Answer: B.** At DC every x[n−k] is the same value, so y = x · Σh[k] / 2^15 = x · 32768 / 32768 = x.

## 6. Which block uses most of the FIR's 314 flip-flops?

- **A** the accumulator
- **B** the coefficient ROM
- **C** the delay line ✔
- **D** the control FSM

**Answer: C.** 16 samples × 16 bits = 256 flip-flops. In a real product a long delay line would be an SRAM, which is far denser.

## 7. A 32-tap FIR must reach 25 MS/s on a 100 MHz clock. Using cycles per sample ≈ N / M, how many multipliers (M) do you need?

**Answer:** M = 8.

100 MHz / 25 MS/s = 4 cycles per sample, so N / M ≤ 4 → M ≥ 32 / 4 = 8. In practice you add a little margin for the load cycle.

## 8. The testbench checks bit-exact output against a model **and** measures gain with sine bursts. Why both?

**Answer:** Bit-exact proves the arithmetic matches the model; the sine test proves it is the right filter (the model could share a design mistake).

Two different kinds of bugs: an arithmetic bug (wrong rounding, sign extension) vs. a design bug (wrong coefficients, wrong cutoff).
