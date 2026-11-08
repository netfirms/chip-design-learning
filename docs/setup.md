# Tool setup

You need two groups of tools:

1. **Front end** (simulation, lint, synthesis): small, install natively.
2. **Back end** (OpenROAD + the sky130 PDK): large, easiest to run in Docker.

Run `make doctor` at any point to see which tools are on your `PATH`.

**Don't want to install anything?** Open the repo in GitHub Codespaces and
every tool below, OpenROAD included, is ready in your browser:
[browser labs](codespaces.md). The same `.devcontainer/` also works on your
own machine with VS Code's *Dev Containers* extension and Docker.

## Option A: OSS CAD Suite (recommended for the front end)

[OSS CAD Suite](https://github.com/YosysHQ/oss-cad-suite-build) is a nightly
bundle of Yosys, Icarus Verilog, Verilator, GTKWave, nextpnr and more for
Linux, macOS and Windows. Distro packages of Yosys are often several releases
behind, so this is the easiest way to get current versions.

```sh
# Download the archive for your platform from the releases page, then:
tar -xzf oss-cad-suite-<platform>-<date>.tgz
source oss-cad-suite/environment     # add to your shell rc to make it permanent
yosys -V && iverilog -V && verilator --version
```

On macOS you may need to clear the quarantine flag once:
`xattr -dr com.apple.quarantine oss-cad-suite`.

## Option B: distro packages

```sh
# Debian / Ubuntu
sudo apt-get install iverilog verilator yosys gtkwave graphviz

# macOS (Homebrew)
brew install icarus-verilog verilator yosys graphviz
brew install --cask gtkwave       # or use Surfer: https://surfer-project.org/
```

Everything in this repo works with Ubuntu 24.04's packages (Yosys 0.33,
Verilator 5.x); CI uses them.

## Python (filter design and plots)

The DSP modules use Python 3 with numpy and matplotlib to design filter
coefficients (`python/dsp_coeffs.py`) and plot testbench results
(`make plot`):

```sh
python3 -m venv .venv && source .venv/bin/activate   # optional
pip install -r python/requirements.txt
```

### cocotb (Python testbenches)

`make cocotb` and `make check-cocotb` need cocotb 2.0 and Icarus Verilog
(see [verification.md](verification.md)):

```sh
pip install -r python/requirements-verif.txt
```

### 3D layout renders (optional)

`python/render_3d.py` turns a routed GDS into pictures like the ones in this
repo, and `scripts/render_images.sh` regenerates all of them. It needs
`gdstk` and `pyvista` (in `python/requirements.txt`). On a headless Linux
machine, also install an off-screen OpenGL library:
`sudo apt-get install libosmesa6`.

## Back end: OpenROAD-flow-scripts in Docker

[OpenROAD-flow-scripts](https://github.com/The-OpenROAD-Project/OpenROAD-flow-scripts)
(ORFS) bundles OpenROAD, Yosys, KLayout and the sky130 / gf180 / asap7 /
nangate45 platforms. The official image is `openroad/orfs`.

```sh
# Install Docker (https://docs.docker.com/get-docker/), then:
docker pull openroad/orfs:latest   # several GB, once
make pnr                           # runs scripts/orfs.sh for the counter
```

`make pnr` mounts this repo at `/work` inside the container and writes all
outputs to `designs/<name>/build/orfs/` on your machine. Every design
has the same `make pnr` target. To pin a specific
image, pass `ORFS_IMAGE=openroad/orfs:<tag>`.

### Viewing the layout

- `make pnr-gui` opens the OpenROAD GUI on the final design. On Linux this
  needs X11 (`xhost +local:` once). On macOS install XQuartz and allow network
  clients, or just use KLayout below.
- Or open the GDS with KLayout on your host:
  `klayout designs/counter/build/orfs/results/sky130hd/counter/base/6_final.gds`

### Building ORFS natively (optional)

If you want OpenROAD on your host instead of in Docker, follow the
[ORFS build instructions](https://openroad-flow-scripts.readthedocs.io/en/latest/user/BuildLocally.html).
It is a long build; Docker is fine for learning.

## Editor support

- VS Code: the *Verilog-HDL/SystemVerilog* or *TerosHDL* extensions, with
  Verilator configured as the linter.
- [Verible](https://github.com/chipsalliance/verible) gives a formatter
  (`verible-verilog-format`) and a language server.
