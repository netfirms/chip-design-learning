# Open-source chip design tools

A map of free and open-source tools for chip design, grouped by the job they
do. The core list follows the tools page of the Estonian chip competence
centre, [kiip.ee/en/tools](https://kiip.ee/en/tools/); the "In this course"
column says where each one fits in this repo's flow.

Legend: **used** = this course runs it; **alt** = an alternative to a tool we
use; **next** = worth learning after the course.

## HDL simulation and synthesis

| Tool | What it does | In this course |
| ---- | ------------ | -------------- |
| [Icarus Verilog](https://steveicarus.github.io/iverilog/) ([older site](https://bleyer.org/icarus/)) | Verilog simulator (`iverilog` + `vvp`) | **used**: `make sim` |
| [Verilator](https://www.veripool.org/verilator/) | Compiles Verilog/SystemVerilog to fast C++; also the best linter | **used**: `make lint`, `make verilator` |
| [Yosys](https://yosyshq.net/yosys/) | RTL synthesis: Verilog to a netlist of gates or standard cells | **used**: `make synth`, `make synth-sky130`, and inside ORFS |
| [GHDL](https://ghdl.free.fr) | VHDL simulator; with the Yosys plugin, also VHDL synthesis | **alt**: if your lab teaches VHDL |
| [EDA Playground](https://www.edaplayground.com) | Run and share HDL in the browser, many simulators | **alt**: try the course's RTL with nothing installed |

## ASIC flows: RTL to GDS

| Tool | What it does | In this course |
| ---- | ------------ | -------------- |
| [OpenROAD](https://github.com/the-openroad-project) | Floorplan, placement, CTS, routing, STA for digital chips | **used**: `make pnr` via OpenROAD-flow-scripts |
| [OpenLane](https://openlane.readthedocs.io/en/latest/) | Automated RTL-to-GDS flow around Yosys, OpenROAD, Magic, KLayout; the flow behind many sky130 shuttles | **alt**: same tools, different wrapper; used by Tiny Tapeout and Efabless-style projects |
| [SiliconCompiler](https://www.siliconcompiler.com) | Python framework to build and run chip flows | **next**: scripting flows across PDKs |
| [Coriolis2](https://libre-soc.org/HDL_workflow/coriolis2/) | Place-and-route back end from LIP6 (Sorbonne) | **alt** |
| [OPUS](https://www.ic-optimize.com/) | Analog and mixed-signal sizing and optimisation | **next**: analog design |

## Timing and verification

| Tool | What it does | In this course |
| ---- | ------------ | -------------- |
| [OpenSTA](https://github.com/The-OpenROAD-Project/OpenSTA) | Static timing analysis (reads Liberty, SDC, netlist, parasitics) | **used**: inside OpenROAD for every timing report |
| [OpenTimer](https://github.com/OpenTimer/OpenTimer) | High-performance STA engine for large designs | **alt** |
| [Verible](https://github.com/chipsalliance/verible) | SystemVerilog parser, formatter, linter, language server | **next**: format and lint your RTL in the editor |
| [Surelog](https://github.com/chipsalliance/Surelog) | SystemVerilog preprocessor, parser and elaborator | **next**: full SystemVerilog front end |
| [UHDM](https://github.com/chipsalliance/UHDM) | Universal Hardware Data Model: a common SystemVerilog data model (used with Surelog) | **next** |
| [NuSMV](https://nusmv.fbk.eu) | Symbolic model checker for finite-state systems | **next**: formal methods beyond SymbiYosys |

## Waveforms, test and debug

| Tool | What it does | In this course |
| ---- | ------------ | -------------- |
| [GTKWave](https://gtkwave.sourceforge.net) | Waveform viewer for VCD/FST files | **used**: `make waves` |
| [AutoBench](https://github.com/AutoBench) | LLM-based automatic testbench generation for HDL | **next**: compare with the hand-written self-checking testbenches |

## Analog, circuit simulation and PCB

Chips do not live alone: the same open-source ecosystem covers transistor
level simulation and the board your chip goes on.

| Tool | What it does | In this course |
| ---- | ------------ | -------------- |
| [Ngspice](https://ngspice.sourceforge.io) | SPICE circuit simulator, mixed-signal; works with the sky130 transistor models | **next**: simulate a standard cell or your PWM's RC filter |
| [QucsStudio](https://qucsstudio.de) | Free circuit simulator with a GUI (from the Qucs family) | **alt** to Ngspice for schematic-driven simulation |
| [KiCad](https://www.kicad.org/) | Schematic capture and PCB layout | **next**: a board for your Tiny Tapeout chip |
| [Horizon EDA](https://horizon-eda.org) | Schematic and PCB with a modern workflow | **alt** to KiCad |
| [gEDA](http://www.repo.hu/projects/geda-archive/www.geda-project.org/) | Classic suite of schematic, simulation and PCB tools (archived) | historical |
| [Fritzing](https://fritzing.org) | Breadboard-style schematics and PCBs for prototypes | **alt**: quick lab prototypes |

## Also used in this course

| Tool | What it does | Where |
| ---- | ------------ | ----- |
| [OpenROAD-flow-scripts](https://github.com/The-OpenROAD-Project/OpenROAD-flow-scripts) | Makefiles and scripts that drive Yosys + OpenROAD end to end | `make pnr`, `scripts/orfs.sh` |
| [SkyWater sky130 PDK](https://github.com/google/skywater-pdk) | Open 130 nm process: cells, rules, models | every `synth-sky130` and `pnr` |
| [KLayout](https://www.klayout.de/) | Layout viewer/editor, GDS export, DRC | opening `6_final.gds` |
| [Surfer](https://surfer-project.org/) | Modern waveform viewer (also in the browser) | alternative to GTKWave |
| [cocotb](https://www.cocotb.org/), [SymbiYosys](https://symbiyosys.readthedocs.io/) | Python testbenches; formal verification | Module 8 and further study |
| [Magic](http://opencircuitdesign.com/magic/), [Netgen](http://opencircuitdesign.com/netgen/) | DRC and LVS signoff | Module 8: toward tapeout |
| [Tiny Tapeout](https://tinytapeout.com/) | Get a small design fabricated on a shared chip | Module 8 |

## Learning and community

| Resource | What it is |
| -------- | ---------- |
| [kiip.ee](https://kiip.ee/en/) | Estonian chip competence centre: tools list, [trainings](https://kiip.ee/en/trainings/), [pilot lines](https://kiip.ee/en/pilot-lines/), [funding](https://kiip.ee/en/funding/) and [other chip centres](https://kiip.ee/en/about/other-chip-centers/) in Europe |
| [HDLBits](https://hdlbits.01xz.net/) | Verilog practice problems |
| [ZipCPU blog](https://zipcpu.com/) | Practical FPGA/ASIC design, DSP and formal verification |
| [ORFS documentation](https://openroad-flow-scripts.readthedocs.io/) | Flow tutorial and every flow variable |
| [Yosys documentation](https://yosyshq.readthedocs.io/projects/yosys/en/latest/) | Synthesis commands and internals |
