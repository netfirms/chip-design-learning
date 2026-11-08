# Quiz answers: Module 1: The flow, end to end

Answer key for the quiz at the end of [`01-flow.md`](../01-flow.md).

## 1. Put the flow in order: (1) place and route, (2) lint, (3) simulate, (4) synthesise.

- **A** 1, 4, 2, 3
- **B** 3, 2, 4, 1 ✔
- **C** 4, 3, 2, 1
- **D** 2, 4, 3, 1

**Answer: B.** Simulate first (is the logic right?), lint (is the Verilog clean?), synthesise (RTL to gates), then place and route (gates to layout). Everything after simulation assumes the RTL is right.

## 2. Yosys reports `$_DFFE_PN0P_`. Which flip-flop is that?

- **A** negative clock, reset to 1
- **B** positive clock, no enable, sync reset
- **C** enable, positive clock, active-low reset to 0, positive enable ✔
- **D** a latch with enable

**Answer: C.** DFF, E = enable, P = positive clock, N = negative (active-low) reset, 0 = reset value, P = positive enable. It matches `always @(posedge clk or negedge rst_n)` with `if (en)`.

## 3. Which Verilator warning do you get from an `always @*` block with an `if` and no `else`?

- **A** `WIDTH`
- **B** `LATCH` ✔
- **C** `BLKSEQ`
- **D** `MULTIDRIVEN`

**Answer: B.** When no branch assigns the signal, it must keep its old value, so synthesis infers a latch. Add an `else` or a default assignment at the top of the block.

## 4. Why does the testbench compare with `!==` and not `!=`?

**Answer:** `!==` also compares X and Z, so an uninitialised (X) output fails the check.

`count != expected` is X (not true) when `count` is X, so the `if` would not fire and the bug would pass silently. `!==` is a 4-state compare that returns 1 or 0.

## 5. The counter meets a 10 ns clock with +5.24 ns worst slack. Estimate its fastest clock.

- **A** ~95 MHz
- **B** ~150 MHz
- **C** ~210 MHz ✔
- **D** ~520 MHz

**Answer: C.** f_max ≈ 1 / (period − slack) = 1 / (10 − 5.24) ns = 1 / 4.76 ns ≈ 210 MHz.

## 6. Which ORFS stage makes the clock edge arrive at every flip-flop at nearly the same time?

- **A** `2_floorplan`
- **B** `3_place`
- **C** `4_cts` ✔
- **D** `6_finish`

**Answer: C.** Clock tree synthesis builds a buffered tree from the clock pin to every flip-flop and keeps the skew within budget; hold repair runs right after it.

## 7. In `sky130_fd_sc_hd__dfrtp_1`, what do `hd` and `_1` mean?

**Answer:** `hd` = the high-density standard cell library; `_1` = drive strength 1 (the smallest).

sky130 · fd (foundry) · sc (standard cell) · hd (high density) · dfrtp (D flip-flop, reset, Q output) · _1 (drive strength). `_2`, `_4` are faster, larger versions.

## 8. Static timing analysis (STA) needs which of these?

- **A** a testbench with full coverage
- **B** the netlist, cell timing (Liberty) and the SDC constraints ✔
- **C** a VCD from simulation
- **D** the GDS only

**Answer: B.** STA checks every register-to-register path against the clock in the SDC, using the cell delays from Liberty. No test vectors are needed; that is why it is called static.
