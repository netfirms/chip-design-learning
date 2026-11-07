# chip-design-learning

**A fast-track course in digital chip design for electronics and electrical
engineering students**, from Verilog to a routed layout, using only
open-source tools. It starts with a counter and finishes with real DSP
hardware: FIR and IIR filters and an FFT, each taken through simulation,
synthesis and place & route on the SkyWater sky130 process.

Start with the course: **[docs/learning-path.md](docs/learning-path.md)**.

## The examples

| Design                                | Level    | What it is                                    | Clock   |
| ------------------------------------- | -------- | --------------------------------------------- | ------- |
| [`counter`](designs/counter)          | Basic    | Up-counter with enable: the whole flow in one afternoon | 100 MHz |
| [`pwm`](designs/pwm)                  | Basic    | PWM generator: timer, motor/LED driver, 1-bit DAC | 100 MHz |
| [`fir`](designs/fir)                  | Advanced | 16-tap low-pass FIR, time-shared MAC          | 100 MHz |
| [`iir`](designs/iir)                  | Advanced | 2nd-order Butterworth IIR biquad, parallel    | 50 MHz  |
| [`fft`](designs/fft)                  | Advanced | 8-point complex radix-2 FFT                   | 50 MHz  |

Every design has a self-checking testbench (DSP designs are checked bit for
bit against a reference model and against the expected frequency response)
and goes through the same commands:

```sh
cd designs/fir
make sim            # simulate; prints PASS or FAIL
make plot           # DSP designs: waveforms and measured frequency response
make lint           # Verilator lint
make synth          # Yosys generic synthesis
make synth-sky130   # Yosys onto real sky130 cells, area in um^2
make pnr            # OpenROAD: RTL to GDS (Docker)
```

From the repo root, `make sim DESIGN=fir` does the same, and `make check`
runs lint, simulation and synthesis for every design (this is what CI runs).

## Tools

| Stage                    | Tool                                                                 |
| ------------------------ | -------------------------------------------------------------------- |
| Simulation               | [Icarus Verilog](https://steveicarus.github.io/iverilog/), [Verilator](https://www.veripool.org/verilator/) |
| Waveforms                | [GTKWave](https://gtkwave.sourceforge.net/) or [Surfer](https://surfer-project.org/) |
| Filter design, plots     | Python with numpy and matplotlib                                     |
| Synthesis                | [Yosys](https://yosyshq.net/yosys/)                                   |
| Place & route, STA       | [OpenROAD](https://theopenroadproject.org/) via [OpenROAD-flow-scripts](https://github.com/The-OpenROAD-Project/OpenROAD-flow-scripts) |
| Process design kit (PDK) | [SkyWater sky130](https://github.com/google/skywater-pdk) (`sky130hd` standard cells) |
| Layout viewing           | [KLayout](https://www.klayout.de/), OpenROAD GUI                      |

## Quick start

```sh
# 1. Front-end tools (see docs/setup.md for macOS and OSS CAD Suite)
sudo apt-get install iverilog verilator yosys gtkwave graphviz
pip install -r python/requirements.txt

# 2. Check what you have
make doctor

# 3. Run the first example
make sim
make pnr            # needs Docker; pulls the OpenROAD image once
```

The counter routed in sky130 by `make pnr` (60 x 60 um die, 8 flip-flops,
timing met at 100 MHz with about 5 ns of slack):

![Counter layout after place and route](docs/images/counter_final_layout.webp)

## Repository layout

```
docs/
  learning-path.md   the course: 8 modules with exercises
  fixed-point.md     Q formats, rounding, saturation for DSP hardware
  flow-overview.md   what each RTL-to-GDS stage does and how to read reports
  setup.md           installing the tools (apt, OSS CAD Suite, Docker)
designs/<name>/
  rtl/               synthesisable Verilog
  tb/                self-checking testbench
  orfs/              OpenROAD-flow-scripts config + timing constraints (SDC)
  Makefile           sets TOP/RTL/TB and includes mk/design.mk
mk/design.mk         shared make rules for every design
python/
  dsp_coeffs.py      designs and quantises the FIR/IIR coefficients
  plot_tb.py         plots testbench output (make plot)
scripts/
  synth_*.tcl        Yosys synthesis scripts
  orfs.sh            runs OpenROAD-flow-scripts in Docker
```

## Adding a design

Copy any example to `designs/<name>`, rename the module and files, and update
`TOP`/`RTL`/`TB` in its Makefile and `DESIGN_NAME`/`VERILOG_FILES` in
`orfs/config.mk`. `make check` picks it up automatically. Module 8 of the
course has project ideas.
