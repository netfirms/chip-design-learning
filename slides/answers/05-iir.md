# Quiz answers: Module 5: IIR filters

Answer key for the quiz at the end of [`05-iir.md`](../05-iir.md).

## 1. Why are the IIR coefficients Q2.14 instead of Q1.15?

- **A** Q2.14 is more precise
- **B** |a1| = 1.56 > 1 needs an integer bit ✔
- **C** the multipliers are cheaper
- **D** to avoid rounding

**Answer: B.** Q1.15 covers only [−1, 1). a1 = −1.561 needs the range of Q2.14, [−2, 2), at the cost of one fraction bit.

## 2. Show that the integer coefficients (b0 = b2 = 329, b1 = 658, a1 = −25576, a2 = 10508) give a DC gain of exactly 1.

**Answer:** b0 + b1 + b2 = 1316 and 16384 + a1 + a2 = 16384 − 25576 + 10508 = 1316, so the ratio is 1.

H(1) = (b0 + b1 + b2) / (1 + a1 + a2); in Q2.14, 1 is 16384. A step input settles to exactly the input value.

## 3. A 2nd-order section has a2 = 0.81. What is its pole radius?

- **A** 0.81
- **B** 0.9 ✔
- **C** 0.656
- **D** 1.62

**Answer: B.** For complex poles r = √a2 = √0.81 = 0.9: inside the unit circle, so stable.

## 4. Why can't you add a pipeline register inside the feedback loop to raise the clock?

**Answer:** y[n] would then depend on y[n−2] instead of y[n−1]: it becomes a different filter.

In a feed-forward FIR an extra register only adds latency. In a loop it changes the transfer function. Look-ahead, block processing or interleaved channels are the real fixes.

## 5. How many adders does `329 * x` need as shift-and-add (plain binary, no CSD)?

- **A** 2
- **B** 3 ✔
- **C** 4
- **D** 8

**Answer: B.** 329 = 256 + 64 + 8 + 1: four non-zero bits, so (x << 8) + (x << 6) + (x << 3) + x, three adders.

## 6. Using CSD (digits −1, 0, +1), how many adders/subtractors does `31 * x` need?

- **A** 1 ✔
- **B** 2
- **C** 4
- **D** 5

**Answer: A.** 31 = 32 − 1, so (x << 5) − x: one subtractor. Plain binary 16 + 8 + 4 + 2 + 1 would need four adders.

## 7. Which filter needs the **most** coefficient bits to stay stable?

- **A** a 0.2 fs low-pass
- **B** a 0.05 fs low-pass
- **C** a 0.002 fs low-pass ✔
- **D** they all need the same

**Answer: C.** The narrower the filter relative to fs, the closer the poles hug z = 1. At 0.002 fs, Q2.10 already rounds the poles onto the unit circle.

## 8. Why is Direct Form I the usual choice in fixed point, even though Direct Form II needs fewer delays?

**Answer:** DF-II's internal signal (after the poles, before the zeros) can grow much larger than the input or output and overflow; DF-I only stores inputs and outputs.

DF-I uses 4 delays instead of 2, but every stored value has the range of the input or output, so the widths are easy to bound.
