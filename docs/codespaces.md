# Browser labs: the whole course in GitHub Codespaces

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/netfirms/chip-design-learning?quickstart=1)

> **Hardware is the new Software**, so it should run like software too: open
> a link, get an editor and a terminal, type `make`.

A codespace is a Linux machine in the cloud with VS Code in your browser.
This repo ships a dev container (`.devcontainer/`) that sets that machine up
with every tool the course uses, so you can do every module, including
place & route, from a Chromebook, a lab PC or a tablet with a keyboard.
Nothing gets installed on your own computer.

## Start a lab

1. Sign in to GitHub and click the **Open in GitHub Codespaces** button above
   (or on the repo page: **Code → Codespaces → Create codespace on main**).
2. Wait a few minutes the first time while the container builds. The terminal
   at the bottom shows the setup log and ends with **Ready**.
3. In the terminal:

```sh
make sim                  # counter testbench, prints PASS
make synth-sky130         # map the counter onto real sky130 cells
make pnr                  # RTL to GDS with OpenROAD, about a minute for the counter
make sim plot DESIGN=fir  # FIR waveforms and measured frequency response
```

Open any `.png` that `make plot` writes (in `designs/<name>/build/`) by
clicking it in the file explorer.

Want to keep your work? **Fork the repo first** and open the codespace from
your fork, then `git commit` and `git push` as usual.

## What is inside

| Stage | Tools ready in the codespace |
| ----- | ---------------------------- |
| Simulation, lint | Icarus Verilog, Verilator |
| Synthesis | Yosys (`make synth`, `make synth-sky130`) |
| Place & route, STA | OpenROAD-flow-scripts + sky130 in Docker (`make pnr`) |
| Waveforms | WaveTrace inside VS Code, GTKWave on the desktop |
| Layout viewing | KLayout and the OpenROAD GUI on the desktop |
| Python | numpy, matplotlib, gdstk, pyvista (`make plot`, `python/render_3d.py`) |
| Slides | Node.js for `make slides`, Marp preview in the editor |

Run `make doctor` to check. It lists `openroad` as missing because OpenROAD
lives in the Docker image, not on the `PATH`; `make pnr` uses it from there.

The first `make pnr` may take a few extra minutes: the OpenROAD image is
several GB, and the codespace starts downloading it in the background when
it boots (progress in `/tmp/orfs-pull.log`).

## Graphical tools: the desktop in a browser tab

GTKWave, KLayout and the OpenROAD GUI need a screen. The codespace runs a
small Linux desktop for them:

1. Open the **Ports** tab next to the terminal.
2. On port **6080 (Desktop)**, click the globe icon to open it in a new tab.
3. Click **Connect** and enter the password `vscode`.

Anything you start from the VS Code terminal now opens on that desktop:

```sh
make waves DESIGN=counter        # GTKWave on the counter VCD
klayout designs/counter/build/orfs/results/sky130hd/counter/base/6_final.gds
xhost +local: && make pnr-gui    # OpenROAD GUI on the routed counter
```

For quick looks at waveforms you do not need the desktop: click any `.vcd`
file in `designs/<name>/build/` and it opens in the WaveTrace viewer inside
VS Code.

## Machine size and free hours

The dev container asks for a 4-core, 16 GB machine with 32 GB of disk. That
is enough for every design, including the FFT (about 10 minutes of place &
route).

Codespaces bills by core-hours. A free personal account includes a monthly
allowance of core-hours and storage, and students get a larger one through
the [GitHub Student Developer Pack](https://education.github.com/pack). A
4-core machine uses 4 core-hours per hour, so the free allowance is roughly
a full course's worth of lab time. Check the current numbers on
[GitHub's Codespaces billing page](https://docs.github.com/en/billing/managing-billing-for-your-products/managing-billing-for-github-codespaces/about-billing-for-github-codespaces).

To make the hours last:

- **Stop** the codespace when you finish a session (it also stops by itself
  after 30 minutes idle). Your files stay.
- **Delete** codespaces you no longer need at
  [github.com/codespaces](https://github.com/codespaces); stopped ones still
  use storage.

## Teaching with it

- Every student opens their own codespace from the same link, so everyone has
  identical tool versions (the same Ubuntu 24.04 packages CI uses).
- Organisations on GitHub Team or Enterprise, and GitHub Classroom, can pay
  for students' codespaces and set up prebuilds so a codespace opens in
  seconds instead of minutes.
- The same `.devcontainer/` works locally with VS Code's **Dev Containers**
  extension and Docker, for students who prefer their own laptop.

## Troubleshooting

| Problem | Fix |
| ------- | --- |
| `make pnr` says it cannot connect to the Docker daemon | Wait a few seconds after the codespace starts and try again, or run **Codespaces: Rebuild Container** from the command palette. |
| `make pnr` fails with "no space left on device" | Run `docker system prune` and delete old `designs/*/build/` folders. |
| The desktop tab is blank | Reload it, or check that port 6080 is listed in the Ports tab. |
| `make pnr-gui` says it cannot open the display | Run `xhost +local:` in the terminal first, with the desktop tab open. |
| `make synth-sky130` cannot download the Liberty file | Check your network, then rerun: it is fetched once into `.cache/`. |
