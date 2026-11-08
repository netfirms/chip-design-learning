![chip-design-learning: Hardware is the new Software](docs/images/banner.webp)

# chip-design-learning

> **Hardware is the new Software.** Chips are written as code, tested like
> code, built by a compiler-like flow and versioned in git. With open-source
> tools you can go from a Verilog file to a real chip layout on a laptop.

A **fast-track course in digital chip design for electronics and electrical
engineering students**. It starts with a counter and finishes with real DSP
hardware (FIR and IIR filters and an FFT), each taken from Verilog through
simulation, synthesis and place & route on the open SkyWater sky130 process.

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/netfirms/chip-design-learning?quickstart=1)

Nothing to install: open the course in your browser with every tool ready,
place & route included ([how it works](docs/codespaces.md)).

**Start here: [the course](docs/learning-path.md)** · [browser labs](docs/codespaces.md) · [tool setup](docs/setup.md) ·
[how the flow works](docs/flow-overview.md) · [fixed-point primer](docs/fixed-point.md) ·
[open-source tool links](docs/tools.md) ·
[slide decks for every module](slides/)

![The RTL-to-GDS flow](docs/images/flow.svg)

## A chip, from the outside

The first design, `counter`, as it really comes out of `make pnr`: the
transistors and the wiring between them, seen from the corner in a true
isometric view, with the 3 input pins and 9 output pins at their real places
on the die edge. The power straps on the top two metal layers are hidden so
you can see down to the transistors.

![Isometric render of the counter chip: transistors, metal wiring and labelled input and output pins](docs/images/counter_iso_transistors.webp)

The same chip as a simplified block drawing: what goes in, what comes out,
and the parts synthesis builds inside.

![Isometric block drawing of the counter chip with its input and output pins](docs/images/counter_iso.png)

## The examples

Every picture below is rendered straight from the layout file that `make pnr`
produces for that design: the transistors and the wiring on metal 1 to 3 in
an isometric view, with the input pins (orange) and output pins (green)
labelled at their real places on the die edge. Each design's page has more
3D views.

| | Design | What it is | Size in sky130 |
| --- | --- | --- | --- |
| <img src="docs/images/counter_iso_transistors.webp" width="300"> | **[counter](designs/counter)**<br>Basic | Up-counter with enable: the whole flow in one afternoon | 27 cells, 60 × 60 µm, 100 MHz |
| <img src="docs/images/pwm_iso_transistors.webp" width="300"> | **[pwm](designs/pwm)**<br>Basic | PWM generator: timer, motor/LED driver, 1-bit DAC | 71 cells, 60 × 60 µm, 100 MHz |
| <img src="docs/images/fir_iso_transistors.webp" width="300"> | **[fir](designs/fir)**<br>Advanced | 16-tap low-pass FIR filter with one shared multiplier | 2,100 cells, 253 × 253 µm, 100 MHz |
| <img src="docs/images/iir_iso_transistors.webp" width="300"> | **[iir](designs/iir)**<br>Advanced | 2nd-order Butterworth IIR biquad, one sample per clock | 1,600 cells, 235 × 235 µm, 50 MHz |
| <img src="docs/images/fft_iso_transistors.webp" width="300"> | **[fft](designs/fft)**<br>Advanced | 8-point complex radix-2 FFT | 9,100 cells, 449 × 449 µm, 50 MHz |
| <img src="docs/images/riscv_iso_transistors.webp" width="300"> | **[riscv](designs/riscv)**<br>Advanced | RV32I RISC-V CPU that runs C compiled by gcc | 6,200 cells, 427 × 427 µm, 50 MHz |
| <img src="docs/images/tt_fir_iso_transistors.webp" width="300"> | **[tt_fir](designs/tt_fir)**<br>Capstone | The FIR as a [Tiny Tapeout](https://tinytapeout.com/) project: fixed pinout, synchronised inputs, ready for a shuttle | 1,160 cells, 2 tiles (161 × 226 µm), 50 MHz |

All seven designs pass their testbenches and route with 0 DRC violations and
positive timing slack.

**Software or hardware?** [codesign/](codesign/) runs the same 8-point FFT
as Python, NumPy and C and compares it with the `fft` chip on speed, energy
and area: a CPU wins on throughput with big batches, the chip uses hundreds
to tens of thousands of times less energy per FFT.

![Energy per FFT, software vs hardware](docs/images/codesign_energy.png)

Zoom in far enough and you reach the transistors: green diffusion, red
polysilicon gates, blue local interconnect and grey contacts.

![Transistor-level view of the FFT](docs/images/fft_3d_transistors.webp)

## How every design works

Each design is a small, self-contained project with the same commands:

```sh
cd designs/fir
make sim            # self-checking testbench, prints PASS or FAIL
make cocotb         # the same design tested from Python (cocotb)
make plot           # DSP designs: waveforms and the measured frequency response
make lint           # Verilator lint
make synth          # Yosys generic synthesis
make synth-sky130   # Yosys onto real sky130 cells, area in um^2
make pnr            # OpenROAD: RTL to GDS (Docker)
```

From the repo root, `make sim DESIGN=fir` does the same, and `make check`
runs lint, simulation and synthesis for every design (this is what CI runs).
`make check-cocotb` runs every Python testbench; see
[docs/verification.md](docs/verification.md).

The DSP testbenches check every output bit for bit against a reference model
and measure the frequency response from the hardware itself:

![FIR testbench: waveforms and measured frequency response](docs/images/fir_sim.png)

## Tools

| Stage                    | Tool                                                                 |
| ------------------------ | -------------------------------------------------------------------- |
| Simulation               | [Icarus Verilog](https://steveicarus.github.io/iverilog/), [Verilator](https://www.veripool.org/verilator/) |
| Verification             | [cocotb](https://www.cocotb.org/) (Python testbenches)               |
| Waveforms                | [GTKWave](https://gtkwave.sourceforge.net/) or [Surfer](https://surfer-project.org/) |
| Filter design, plots, 3D renders | Python: numpy, matplotlib, gdstk, pyvista                    |
| Synthesis                | [Yosys](https://yosyshq.net/yosys/)                                   |
| Place & route, STA       | [OpenROAD](https://theopenroadproject.org/) via [OpenROAD-flow-scripts](https://github.com/The-OpenROAD-Project/OpenROAD-flow-scripts) |
| Process design kit (PDK) | [SkyWater sky130](https://github.com/google/skywater-pdk) (`sky130hd` standard cells) |
| Layout viewing           | [KLayout](https://www.klayout.de/), OpenROAD GUI, `python/render_3d.py` |

## Quick start

**In the browser:** click **Open in GitHub Codespaces** above, wait for the
terminal to say *Ready*, and run `make sim` then `make pnr`. See
[docs/codespaces.md](docs/codespaces.md).

**On your own machine:**

```sh
# 1. Front-end tools (see docs/setup.md for macOS and OSS CAD Suite)
sudo apt-get install iverilog verilator yosys gtkwave graphviz
pip install -r python/requirements.txt
pip install -r python/requirements-verif.txt   # cocotb, for make cocotb

# 2. Check what you have
make doctor

# 3. Run the first example
make sim
make pnr            # needs Docker; pulls the OpenROAD image once

# 4. Compare every design: area, timing and power charts in ppa/index.html
make ppa
```

### PPA dashboard

CI places and routes every design and publishes a dashboard of area, cell mix,
setup slack, estimated fmax and power for all of them
(`python/ppa_dashboard.py`, workflow `pnr`). On `main` it goes to the
repository's GitHub Pages site; on a pull request it is the `ppa-dashboard`
artifact of the run, and the job summary shows the same numbers as a table.

## Repository layout

```
.devcontainer/        Codespaces / Dev Container with every tool preinstalled
docs/
  learning-path.md   the course: 9 modules and a Tiny Tapeout capstone, with exercises
  fixed-point.md     Q formats, rounding, saturation for DSP hardware
  flow-overview.md   what each RTL-to-GDS stage does and how to read reports
  setup.md           installing the tools (apt, OSS CAD Suite, Docker)
  codespaces.md      browser labs: the whole course in GitHub Codespaces
  tools.md           map of open-source chip design tools and where each fits
  verification.md    side module: Python testbenches with cocotb
slides/              one Marp slide deck per module (make slides / slides-pdf)
  images/            renders, plots and diagrams used in the docs
designs/<name>/
  rtl/               synthesisable Verilog
  tb/                self-checking testbench (Verilog)
  cocotb/            the same checks and more, in Python (make cocotb)
  orfs/              OpenROAD-flow-scripts config + timing constraints (SDC)
  Makefile           sets TOP/RTL/TB and includes mk/design.mk
designs/riscv/firmware/  C and assembly programs for the RISC-V CPU (make firmware)
mk/design.mk         shared make rules for every design
mk/cocotb.mk         runs a design's cocotb testbench (called by make cocotb)
python/
  dsp_coeffs.py      designs and quantises the FIR/IIR coefficients
  cocotb_util.py     clock/reset and fixed-point helpers for the cocotb tests
  plot_tb.py         plots testbench output (make plot)
  ppa_dashboard.py   area/timing/power dashboard for every design (make ppa)
  render_3d.py       3D render of a routed GDS
  render_iso.py      isometric block drawing of the counter chip and its pins
  render_transistors_iso.py  isometric transistor + wiring render with labelled pins
  make_diagrams.py   the SVG diagrams in docs/images
scripts/
  synth_*.tcl        Yosys synthesis scripts
  orfs.sh            runs OpenROAD-flow-scripts in Docker
  render_images.sh   regenerates every render and plot in docs/images
```

## Adding a design

Copy any example to `designs/<name>`, rename the module and files, and update
`TOP`/`RTL`/`TB` in its Makefile and `DESIGN_NAME`/`VERILOG_FILES` in
`orfs/config.mk`. Rename `cocotb/test_<old>.py` to `cocotb/test_<name>.py`
(or delete the folder). `make check` picks it up automatically, and
`python3 python/render_3d.py <your 6_final.gds> -o mychip.webp` renders it.
Module 8 of the course has project ideas.
