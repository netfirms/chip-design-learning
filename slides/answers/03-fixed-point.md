# Quiz answers: Module 3: Fixed-point arithmetic

Answer key for the quiz at the end of [`03-fixed-point.md`](../03-fixed-point.md).

## 1. What integer stores 0.25 in Q1.15?

- **A** 256
- **B** 4096
- **C** 8192 ✔
- **D** 16384

**Answer: C.** v = real · 2^15 = 0.25 · 32768 = 8192.

## 2. The 16-bit word `16'hC000` is a Q1.15 number. What is its value?

- **A** −0.5 ✔
- **B** −0.25
- **C** 0.75
- **D** 1.5

**Answer: A.** 0xC000 = 49152 unsigned; as two's complement that is 49152 − 65536 = −16384, and −16384 / 32768 = −0.5.

## 3. What format and width is the product of two Q1.7 numbers?

**Answer:** Q2.14, 16 bits.

Multiplication adds the formats: Q1.7 × Q1.7 = Q(1+1).(7+7) = Q2.14. The extra integer bit is needed only for (−1) × (−1) = +1.

## 4. You sum 32 Q1.15 values. How many guard bits does the accumulator need?

- **A** 2
- **B** 4
- **C** 5 ✔
- **D** 32

**Answer: C.** ceil(log2 32) = 5 guard bits, so the sum is Q6.15 (21 bits). The 16-tap FIR needs 4.

## 5. What is the approximate SNR of a full-scale sine quantised to 10 bits?

- **A** ~42 dB
- **B** ~62 dB ✔
- **C** ~74 dB
- **D** ~98 dB

**Answer: B.** SNR ≈ 6.02 · N + 1.76 = 60.2 + 1.76 ≈ 62 dB. About 6 dB per bit.

## 6. Truncating with `x >>> n` introduces what error?

- **A** none
- **B** a +½ LSB bias
- **C** a −½ LSB bias (rounds toward −∞) ✔
- **D** random sign errors

**Answer: C.** Dropping bits always rounds down (toward −∞), so on average the result is ½ LSB too low. Round to nearest, `(x + 2^(n−1)) >>> n`, removes the bias for one extra adder.

## 7. `wire signed [15:0] a = -8;` What is `a >> 1` as a 16-bit value?

- **A** −4
- **B** 32764 ✔
- **C** −32764
- **D** 4

**Answer: B.** `>>` is a logical shift and fills with 0: 0xFFF8 >> 1 = 0x7FFC = 32764. Use `>>>` on signed values to get −4.

## 8. Why must the IIR feedback path saturate rather than wrap on overflow?

**Answer:** With wrap-around a large positive value becomes a large negative one, which is fed back and can sustain an oscillation forever.

That is an overflow limit cycle. Saturation turns the same event into a brief clip. In a feed-forward block a wrap is one bad sample; in a loop it can be permanent.
