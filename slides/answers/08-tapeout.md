# Quiz answers: Module 8: Your own design and tapeout

Answer key for the quiz at the end of [`08-tapeout.md`](../08-tapeout.md).

## 1. Which signoff check answers "is the layout the same circuit as the netlist?"

- **A** DRC
- **B** LVS ✔
- **C** antenna
- **D** STA

**Answer: B.** Layout versus schematic: it extracts the circuit from the polygons and compares it with the netlist (Netgen). DRC checks the polygons against the foundry rules.

## 2. What does the antenna check protect against?

**Answer:** Long metal wires collecting charge during plasma etching and damaging the thin gate oxide they connect to.

The fix is a diode near the gate or breaking the wire with a jump to a higher layer. OpenROAD repairs many antenna violations automatically.

## 3. An NCO has a 16-bit phase accumulator at f_clk = 50 MHz. What fcw gives about 1 MHz out?

- **A** 50
- **B** 656
- **C** 1311 ✔
- **D** 13107

**Answer: C.** f_out = f_clk · fcw / 2^16 → fcw = 1 MHz · 65536 / 50 MHz ≈ 1310.7 → 1311 (≈ 1.0002 MHz). The step size is 50 MHz / 65536 ≈ 763 Hz.

## 4. Why does a quarter-wave sine ROM make the table 4× smaller?

**Answer:** A sine's four quadrants are mirror images and negations of the first, so you store 0 to 90° and use symmetry (flip the address, negate the output) for the rest.

The top two phase bits pick the quadrant; the rest index a table one quarter the size.

## 5. A simulation passes. A formal proof of the same property also passes. What does the proof add?

**Answer:** It checks every possible input sequence (up to the depth, or for all time by induction), not only the cases the testbench happened to drive.

A simulation checks the cases you thought of. SymbiYosys with `mode prove` covers the ones you did not.

## 6. What is the fixed I/O of a Tiny Tapeout tile?

- **A** 8 in, 8 out, 8 bidirectional, clk, rst_n ✔
- **B** 16 in, 16 out
- **C** one SPI port
- **D** 32 GPIO and a CPU bus

**Answer: A.** `ui_in[7:0]`, `uo_out[7:0]`, `uio_*[7:0]` with `uio_oe`, plus `clk`, `rst_n` and `ena`. Check the current template before you submit.

## 7. In the `tt_um_yourname_pwm` wrapper, why is `uio_oe` set to `8'b0`?

**Answer:** 0 makes the bidirectional pins inputs, so the unused pins do not drive anything.

`uio_oe` is the output enable of each bidirectional pin; a 1 would drive `uio_out` onto the pin.

## 8. The spec rows "How will I know it works?" and "Area / power budget" are empty. What should you do?

- **A** start the RTL anyway
- **B** fill them in before writing RTL ✔
- **C** skip verification
- **D** make the design bigger

**Answer: B.** Without a test plan and a budget you cannot tell when you are done or whether it fits. If you cannot fill in those rows, you are not ready to write RTL.
