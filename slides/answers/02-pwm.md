# Quiz answers: Module 2: Sequential control and timers

Answer key for the quiz at the end of [`02-pwm.md`](../02-pwm.md).

## 1. f_clk = 50 MHz and WIDTH = 10. What is the PWM frequency?

- **A** ~48.8 kHz ✔
- **B** ~97.7 kHz
- **C** ~195 kHz
- **D** 5 MHz

**Answer: A.** f_PWM = f_clk / 2^WIDTH = 50 MHz / 1024 ≈ 48.8 kHz.

## 2. VDD = 1.8 V, WIDTH = 8, duty = 64. What average voltage does the filtered output give?

- **A** 0.225 V
- **B** 0.45 V ✔
- **C** 0.9 V
- **D** 1.35 V

**Answer: B.** V_avg = VDD · duty / 2^WIDTH = 1.8 · 64 / 256 = 0.45 V (a 25 % duty cycle).

## 3. When does the RTL copy `duty` into the shadow register `duty_q`?

- **A** every clock
- **B** when `cnt` is all ones (end of the period) ✔
- **C** when `pwm_out` rises
- **D** only at reset

**Answer: B.** `if (cnt == {WIDTH{1'b1}}) duty_q <= duty;` A new value takes effect at the start of the next period, so a write mid-period can never make one wrong pulse.

## 4. Why is `pwm_out` a register and not `assign pwm_out = cnt < duty_q;`?

**Answer:** A flip-flop output has one clean transition per edge; the comparator output can glitch while the `cnt` bits settle.

A glitch on a pin that drives a power MOSFET is a real short pulse. Registering costs one cycle of latency, which does not matter here. Register every output that leaves the chip.

## 5. WIDTH = 8 and duty = 255. For how many clock cycles per period is `pwm_out` low?

- **A** 0
- **B** 1 ✔
- **C** 128
- **D** 255

**Answer: B.** `cnt < 255` is true for cnt = 0..254 (255 cycles) and false only for cnt = 255. And duty = 0 must never go high.

## 6. `make synth-sky130` reports 17 flip-flops. Where do they come from?

**Answer:** 8 for `cnt`, 8 for `duty_q`, 1 for `pwm_out`.

Every bit assigned with `<=` in the clocked block is a flip-flop. `period_start` is combinational (`assign`), so it adds none.

## 7. You add one bit of resolution (WIDTH 8 → 9) at the same clock. What happens to f_PWM?

- **A** it doubles
- **B** it stays the same
- **C** it halves ✔
- **D** it drops by 1/256

**Answer: C.** The period is 2^WIDTH clocks, so every extra bit doubles the period. This frequency-vs-resolution trade-off is why audio DACs use sigma-delta modulation.

## 8. What is shoot-through in a half-bridge, and what prevents it?

**Answer:** Both the high-side and low-side transistors on at once, shorting VDD to GND. A dead-time gap where both are off prevents it.

Real FETs turn off slower than they turn on, so the controller inserts a programmable gap between `pwm_h` falling and `pwm_l` rising (and back).
