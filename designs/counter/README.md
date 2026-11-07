# counter

A parameterised up-counter with enable, asynchronous active-low reset and a
`wrap` output. It is the reference design for every stage of the flow.

| Target              | What it does                                         | Output (in `build/`)          |
| ------------------- | ---------------------------------------------------- | ----------------------------- |
| `make sim`          | Icarus Verilog, self-checking testbench              | `sim.log`, `counter.vcd`      |
| `make waves`        | Opens the VCD in GTKWave                             |                               |
| `make lint`         | Verilator `--lint-only -Wall`                        |                               |
| `make verilator`    | Same testbench compiled with Verilator               | `obj_dir/`                    |
| `make synth`        | Yosys generic synthesis                              | `counter_generic.v`, `synth_generic_stat.txt` |
| `make show`         | Schematic of the synthesised circuit                 | `counter.svg`                 |
| `make synth-sky130` | Yosys onto sky130 `hd` standard cells                | `counter_sky130.v`, `synth_sky130_stat.txt` |
| `make pnr`          | OpenROAD-flow-scripts, RTL to GDS (Docker)           | `orfs/results/.../6_final.gds` |
| `make pnr-gui`      | OpenROAD GUI on the final layout                     |                               |

Expected results with the default `WIDTH = 8`: the testbench prints `PASS`,
and sky130 synthesis gives 8 `sky130_fd_sc_hd__dfrtp_1` flip-flops and about
24 cells in total.
`make pnr` finishes in well under a minute with 0 DRC violations and positive
setup slack (about 5 ns at the 10 ns clock in `orfs/constraint.sdc`). Images of
each stage are written to `build/orfs/reports/sky130hd/counter/base/*.webp`.
