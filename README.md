# chip-design-learning

Learning digital chip design end to end, from Verilog to a GDS layout, using
only open-source tools:

| Stage                    | Tool                                                                 |
| ------------------------ | -------------------------------------------------------------------- |
| Simulation               | [Icarus Verilog](https://steveicarus.github.io/iverilog/), [Verilator](https://www.veripool.org/verilator/) |
| Waveforms                | [GTKWave](https://gtkwave.sourceforge.net/) or [Surfer](https://surfer-project.org/) |
| Lint                     | Verilator `--lint-only`                                              |
| Synthesis                | [Yosys](https://yosyshq.net/yosys/)                                   |
| Place & route, STA       | [OpenROAD](https://theopenroadproject.org/) via [OpenROAD-flow-scripts](https://github.com/The-OpenROAD-Project/OpenROAD-flow-scripts) |
| Process design kit (PDK) | [SkyWater sky130](https://github.com/google/skywater-pdk) (`sky130hd` standard cells) |
| Layout viewing           | [KLayout](https://www.klayout.de/), OpenROAD GUI                      |

## Quick start

```sh
# 1. Install the front-end tools (see docs/setup.md for macOS / OSS CAD Suite)
sudo apt-get install iverilog verilator yosys gtkwave graphviz

# 2. Check what you have
make doctor

# 3. Simulate, lint and synthesise the example counter
make sim            # self-checking testbench, prints PASS/FAIL
make lint           # Verilator lint
make synth          # Yosys generic synthesis + cell count
make synth-sky130   # Yosys onto real sky130 cells, area in um^2
make show           # schematic as designs/counter/build/counter.svg

# 4. Full RTL-to-GDS with OpenROAD (needs Docker, pulls a large image once)
make pnr
make pnr-gui        # open the finished layout in the OpenROAD GUI
```

The counter routed in sky130 by `make pnr` (60 x 60 um die, 8 flip-flops,
timing met at 100 MHz with about 5 ns of slack):

![Counter layout after place and route](docs/images/counter_final_layout.webp)

`make check` runs lint, simulation and synthesis for every design; it is what
CI runs on each push.

## Repository layout

```
docs/
  learning-path.md   step-by-step curriculum with exercises
  flow-overview.md   what each RTL-to-GDS stage does and what it outputs
  setup.md           installing the tools (apt, OSS CAD Suite, Docker)
designs/
  counter/           first example design
    rtl/             synthesisable Verilog
    tb/              self-checking testbench
    synth/           Yosys scripts (generic and sky130)
    orfs/            OpenROAD-flow-scripts config + timing constraints (SDC)
    Makefile
scripts/
  orfs.sh            runs OpenROAD-flow-scripts in Docker
```

## Where to start

Read [docs/learning-path.md](docs/learning-path.md). It goes from "what is a
flip-flop" to a routed layout, with an exercise at each stage that builds on
the `counter` design. [docs/flow-overview.md](docs/flow-overview.md) is the
reference to come back to when a stage's output does not make sense.

## Adding a design

Copy `designs/counter` to `designs/<name>`, rename the module and files, and
update `TOP`/`RTL`/`TB` in its Makefile and `DESIGN_NAME`/`VERILOG_FILES` in
`orfs/config.mk`. Then `make sim DESIGN=<name>`. `make check` picks it up
automatically.
