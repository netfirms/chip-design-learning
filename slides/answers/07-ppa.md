# Quiz answers: Module 7: Timing, area and power

Answer key for the quiz at the end of [`07-ppa.md`](../07-ppa.md).

## 1. A design meets an 8 ns clock with +1.5 ns slack. Estimate f_max.

- **A** ~125 MHz
- **B** ~154 MHz ✔
- **C** ~210 MHz
- **D** ~667 MHz

**Answer: B.** f_max ≈ 1 / (period − slack) = 1 / 6.5 ns ≈ 154 MHz. It is a first estimate: the tools re-optimise when you tighten the constraint.

## 2. You slow the clock from 10 ns to 20 ns. What happens to hold slack?

- **A** it doubles
- **B** it halves
- **C** essentially nothing ✔
- **D** it becomes negative

**Answer: C.** Hold checks that data does not change too soon after the **same** edge, so it does not depend on the period. CTS hold repair fixes it with delay buffers.

## 3. What is the difference between WNS and TNS?

**Answer:** WNS is the worst slack of any single path; TNS is the sum of all negative slack.

WNS tells you how far the worst path is from meeting timing; TNS tells you how many paths are failing and by how much in total.

## 4. You lower VDD from 1.8 V to 1.6 V at the same frequency. Roughly how much dynamic power do you save?

- **A** ~6 %
- **B** ~11 %
- **C** ~21 % ✔
- **D** ~50 %

**Answer: C.** Dynamic power ∝ V²: (1.6 / 1.8)² ≈ 0.79, so about 21 % less. The gates get slower, so you need timing margin.

## 5. Which sky130 corner do you use for **setup** signoff?

- **A** `tt_025C_1v80`
- **B** `ss_100C_1v60` ✔
- **C** `ff_n40C_1v95`
- **D** any, they give the same result

**Answer: B.** Slow process, low voltage, high temperature is the slowest case, so setup is hardest there. Hold is checked at the fast corner (`ff_n40C_1v95`).

## 6. A design uses 0.05 mm², runs at 100 MHz and takes 4 cycles per sample. What is its MS/s per mm²?

**Answer:** 500 MS/s per mm².

100 MHz / 4 = 25 MS/s; 25 / 0.05 = 500. Always normalise by area (and power) before claiming one architecture is better.

## 7. Why is the clock network often a large share of dynamic power?

**Answer:** It toggles every cycle (activity α = 1) and drives every flip-flop, a large capacitance.

P = α C V² f: the clock tree has the highest α of any net and a large C. Clock gating attacks exactly this.

## 8. Which knob reduces **leakage** power?

- **A** clock gating
- **B** operand isolation
- **C** power gating ✔
- **D** upsizing cells

**Answer: C.** Power gating switches off the supply to a whole block (sky130 `lpflow_*` cells). Clock gating and operand isolation only save dynamic power; upsizing increases both.
