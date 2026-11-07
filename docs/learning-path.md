# Learning path

Eight stages, each ending with an exercise you do in this repo. Work through
them in order; each one uses the output of the one before. Tick the boxes as
you go.

---

## Stage 0: Digital logic foundations

Before writing Verilog, be comfortable with what it describes.

- Boolean algebra, logic gates, truth tables, Karnaugh maps
- Combinational vs. sequential logic
- Flip-flops, clocks, setup and hold time
- Binary arithmetic, two's complement, adders
- Finite state machines (Moore and Mealy)

**Resources:** *Digital Design and Computer Architecture* (Harris & Harris),
chapters 1 to 3. [Nand2Tetris](https://www.nand2tetris.org/) part 1 is a good
hands-on alternative.

- [ ] **Exercise:** draw the gate-level circuit for a 2-bit counter with
      enable on paper. How many flip-flops does it need? Compare with
      `make show` once you reach stage 3.

## Stage 1: Verilog and simulation

- Modules, ports, `wire` vs. `reg`, `assign` vs. `always`
- Blocking (`=`) vs. non-blocking (`<=`) assignment, and why sequential logic
  uses `<=`
- Parameters, generate blocks
- Writing *synthesisable* code vs. testbench-only code (`#delays`, `$display`)
- Self-checking testbenches

**Resources:** [HDLBits](https://hdlbits.01xz.net/) (do the whole thing, it
is the best way to get fluent); [ZipCPU tutorials](https://zipcpu.com/tutorial/).

- [ ] Run `make sim` and `make waves`. Find the cycle where `wrap` is high.
- [ ] **Exercise:** add a `load` input and `load_value[WIDTH-1:0]` to
      `counter.v` that sets the count synchronously. Extend the testbench
      model and checks, and make sure `make sim` still prints `PASS`.
- [ ] **Exercise:** break the RTL on purpose (e.g. count by 2). Confirm the
      testbench fails. A testbench that cannot fail is not testing anything.

## Stage 2: Lint and good RTL habits

- `default_nettype none`, explicit widths, no inferred latches
- Reset strategy: synchronous vs. asynchronous, active-low conventions
- One clock domain per module until you learn clock-domain crossing

- [ ] Run `make lint`. Then add `wire [3:0] x = count;` to `counter.v` and see
      which warnings Verilator reports. Remove it again.
- [ ] Run `make verilator` to run the same testbench with Verilator.

## Stage 3: Logic synthesis with Yosys

- What `synth` does: elaborate, `proc` (always blocks to logic), optimise,
  technology mapping, ABC
- Generic gates vs. standard cells from a Liberty file
- Reading `stat` output; area in um^2

**Resources:** [Yosys documentation](https://yosyshq.readthedocs.io/projects/yosys/en/latest/),
in particular "Getting started" and the `synth` command reference.

- [ ] Run `make synth` and `make show`. Count the flip-flops in the schematic.
- [ ] Run `make synth-sky130`. Which sky130 cell was used for the flip-flops,
      and why one with a reset pin (`dfrtp`)?
- [ ] **Exercise:** change `WIDTH` to 16 and 32 (in `counter.v`'s default)
      and record how area scales. Is it linear? Why?
- [ ] **Exercise:** run `yosys` interactively, `read_verilog rtl/counter.v`,
      then step through `hierarchy`, `proc`, `opt`, `techmap`, running `show`
      after each to see how the design changes.

## Stage 4: Timing

- Clock period, setup/hold, slack, critical path
- SDC constraints: `create_clock`, `set_input_delay`, `set_output_delay`
- Static timing analysis (STA) with OpenSTA

- [ ] Read `designs/counter/orfs/constraint.sdc` and explain each line.
- [ ] After stage 5, find the critical path in the timing report. Which
      cells does it go through?

## Stage 5: Place & route with OpenROAD

- Floorplan, placement, clock tree synthesis, routing, finishing
- The ORFS stages and their numbered outputs (`1_synth` .. `6_final`)
- Reading logs and reports, viewing layouts

**Resources:** [ORFS documentation](https://openroad-flow-scripts.readthedocs.io/),
especially the *Flow Tutorial* and *Flow Variables* pages;
[docs/flow-overview.md](flow-overview.md).

- [ ] Run `make pnr`. Open `6_final.gds` in KLayout or run `make pnr-gui`.
      Find the 8 flip-flops and the clock buffers.
- [ ] **Exercise:** shrink `clk_period` in `constraint.sdc` until timing
      fails (negative WNS in `reports/.../6_finish.rpt`). What is the fastest
      clock this counter can run at in sky130?
- [ ] **Exercise:** change `PLACE_DENSITY` and `DIE_AREA` in
      `orfs/config.mk`. How do wire length and the layout change?

## Stage 6: A bigger design

Take the flow you now know through something with real structure. Pick one:

- UART transmitter + receiver
- PWM generator with a register interface
- 4-bit or 8-bit ALU, then a small CPU (e.g. a single-cycle RISC-V subset)

- [ ] **Exercise:** add it as `designs/<name>` (see the README), with a
      self-checking testbench, and take it through `make check` and `make pnr`.

## Stage 7: Verification beyond testbenches

- [cocotb](https://www.cocotb.org/): testbenches in Python
- Formal verification with [SymbiYosys](https://symbiyosys.readthedocs.io/):
  prove properties instead of testing cases
- Coverage, constrained random stimulus

- [ ] **Exercise:** write a cocotb test for the counter, and a SymbiYosys
      proof that `count` never jumps by more than 1.

## Stage 8: Toward a real tapeout

- Signoff: DRC, LVS, antenna checks (Magic, KLayout, Netgen)
- I/O pads, padframes, and the harness around your design
- Shuttle programs for open-source silicon. [Tiny Tapeout](https://tinytapeout.com/)
  is the most accessible way to get a small design fabricated, and its
  template uses the same tools as this repo.

---

## Glossary

| Term     | Meaning                                                             |
| -------- | ------------------------------------------------------------------- |
| RTL      | Register-transfer level: the Verilog you write                      |
| Netlist  | A circuit described as instances of cells connected by nets          |
| PDK      | Process design kit: everything the foundry gives you to design for a process |
| Liberty  | `.lib` file with timing, power and function of each standard cell    |
| LEF/DEF  | Physical abstract of cells (LEF) and placed/routed design (DEF)      |
| ODB      | OpenROAD's database format for the design                            |
| GDS      | Final layout polygons sent to the foundry                            |
| SDC      | Timing constraints file                                             |
| STA      | Static timing analysis                                              |
| WNS/TNS  | Worst / total negative slack                                        |
| CTS      | Clock tree synthesis                                                |
| DRC/LVS  | Design rule check / layout vs. schematic                            |
