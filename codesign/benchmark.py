#!/usr/bin/env python3
"""benchmark.py -- the 8-point FFT in software vs in hardware: speed, energy, area.

    python3 codesign/benchmark.py                 # measure, write results + charts
    python3 codesign/benchmark.py --cpu-watts 15  # your CPU's power per busy core
    python3 codesign/benchmark.py --charts-only   # redraw charts from results/bench.json

Software numbers are measured on the machine you run this on. Hardware
numbers come from the RTL (cycles per frame) and from `make pnr` of
designs/fft (clock, slack, power, area), listed in HW below.

Energy for software is an ESTIMATE: time x the power of one busy CPU core
(--cpu-watts). Measure your own core power if you can (on Linux:
`perf stat -e power/energy-pkg/ ...`, or a USB power meter on a board).

Writes codesign/results/bench.json and docs/images/codesign_*.png.
"""
import argparse
import json
import os
import platform
import shutil
import subprocess
import sys
import timeit

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
sys.path.insert(0, HERE)
import fft_sw  # noqa: E402

RESULTS = os.path.join(HERE, "results", "bench.json")
IMAGES = os.path.join(ROOT, "docs", "images")

# ---------------------------------------------------------------------------
# The hardware: designs/fft after `make pnr` (sky130hd, typical corner).
# Same numbers as the Module 7 table in docs/learning-path.md.
# ---------------------------------------------------------------------------
HW = {
    "clock_mhz": 50.0,            # orfs/constraint.sdc: 20 ns
    "worst_slack_ns": 5.77,       # 6_finish.rpt
    "power_mw": 2.7,              # 6_finish.rpt, at 50 MHz, default switching activity
    "cell_area_um2": 79800,       # after place and route (buffers, clock tree included)
    "die_um": 449,
    "cells": 9073,
    # rtl/fft8.v: 8 cycles LOAD + 1 cycle COMPUTE + 8 cycles UNLOAD
    "load_cycles": 8,
    "compute_cycles": 1,
    "unload_cycles": 8,
    # Synthesis onto sky130 cells (make synth-sky130 and `make area` here),
    # before place and route, in um^2:
    "synth_area_um2": 62575,
    "area_registers_um2": 587 * 25.024,                  # 587 dfrtp_1 flip-flops
    "area_bfly_mult_um2": 10135 + 10510,                 # 2 butterflies with sqrt(2)/2 (K=1, K=3)
    "area_bfly_other_um2": 7 * 1702 + 3 * 2016,          # 10 butterflies with 1 or -j (K=0, K=2)
}
HW["fmax_mhz"] = 1e3 / (1e3 / HW["clock_mhz"] - HW["worst_slack_ns"])
HW["cycles_per_fft"] = HW["load_cycles"] + HW["compute_cycles"] + HW["unload_cycles"]


def hw_rows():
    """Time and energy per FFT for the hardware at a few operating points."""
    p = HW["power_mw"] * 1e-3
    cyc = HW["cycles_per_fft"]
    t50 = cyc * 1e3 / HW["clock_mhz"]                       # ns
    tmax = cyc * 1e3 / HW["fmax_mhz"]
    # At a higher clock the dynamic power scales with f: energy per cycle stays
    # the same, so energy per FFT is the same at 50 and 70 MHz.
    e = p * t50 * 1e-9                                       # J
    tcomp = HW["compute_cycles"] * 1e3 / HW["clock_mhz"]
    return [
        {"name": "Hardware, 50 MHz (17 cycles)", "kind": "hw", "ns": t50, "J": e},
        {"name": f"Hardware, {HW['fmax_mhz']:.0f} MHz (17 cycles)", "kind": "hw", "ns": tmax, "J": e},
        {"name": "Hardware, butterflies only (1 cycle)", "kind": "hw", "ns": tcomp,
         "J": e * HW["compute_cycles"] / cyc},
    ]


# ---------------------------------------------------------------------------
# Software measurements
# ---------------------------------------------------------------------------
def best_ns(stmt, number, repeat=5):
    """Best of `repeat` runs, in ns per call: the least disturbed by other work."""
    return min(timeit.repeat(stmt, number=number, repeat=repeat)) / number * 1e9


def lcg_frames(frames):
    """Same pseudo-random inputs as fft8_fixed.c."""
    s = 12345
    re = np.zeros((frames, 8), dtype=np.int64)
    im = np.zeros((frames, 8), dtype=np.int64)
    for f in range(frames):
        for n in range(8):
            s = (s * 1103515245 + 12345) & 0xFFFFFFFF
            re[f, n] = ((s >> 16) & 0xFFFF) - 32768
            s = (s * 1103515245 + 12345) & 0xFFFFFFFF
            im[f, n] = ((s >> 16) & 0xFFFF) - 32768
    return re, im


def measure_c():
    """Compile fft8_fixed.c with -O2, check it against the Python model, time it."""
    cc = shutil.which("cc") or shutil.which("gcc") or shutil.which("clang")
    if not cc:
        print("  no C compiler found, skipping the C version")
        return None
    exe = os.path.join(HERE, "build", "fft8_fixed")
    os.makedirs(os.path.dirname(exe), exist_ok=True)
    subprocess.run([cc, "-O2", "-o", exe, os.path.join(HERE, "fft8_fixed.c")], check=True)
    runs = [subprocess.run([exe, "20000000"], check=True, capture_output=True, text=True).stdout
            for _ in range(3)]
    vals = [dict(line.split() for line in r.strip().splitlines()) for r in runs]

    re, im = lcg_frames(1024)
    yr, yi = fft_sw.fft8_fixed_np(re, im)
    k = np.arange(8)
    expect = int(((k + 1) * yr - (k + 3) * yi).sum())
    got = int(vals[0]["checksum"])
    print(f"  C checksum {got}, Python model {expect}: {'match' if got == expect else 'MISMATCH'}")
    if got != expect:
        sys.exit("C and Python bit-exact models disagree")
    return min(float(v["ns_per_fft"]) for v in vals)


def measure_software():
    xr, xi = fft_sw.random_frames(1)
    x = list(xr[0] + 1j * xi[0])
    xn = np.asarray(x)
    r0, i0 = list(xr[0]), list(xi[0])
    rows = []

    def add(name, ns, note=""):
        print(f"  {name:38s} {ns:12.1f} ns per FFT {note}")
        rows.append({"name": name, "kind": "sw", "ns": ns})

    print("Measuring software (best of 5 runs):")
    add("Python, DFT formula (64 multiplies)", best_ns(lambda: fft_sw.dft_naive(x), 2000))
    add("Python, radix-2 FFT", best_ns(lambda: fft_sw.fft_python(x), 5000))
    add("Python, bit-exact model", best_ns(lambda: fft_sw.fft8_fixed(r0, i0), 5000))
    add("NumPy, one frame per call", best_ns(lambda: np.fft.fft(xn), 20000))

    big = 1 << 16
    br, bi = fft_sw.random_frames(big)
    bc = br + 1j * bi
    add("NumPy, 65,536 frames per call", best_ns(lambda: np.fft.fft(bc, axis=1), 5) / big)
    add("NumPy, bit-exact model, 65,536 frames", best_ns(lambda: fft_sw.fft8_fixed_np(br, bi), 3) / big)
    c = measure_c()
    if c is not None:
        add("C -O2, bit-exact model", c)

    print("Batch size sweep (NumPy):")
    batch = []
    for b in [1, 4, 16, 64, 256, 1024, 4096, 16384, 65536]:
        sub = bc[:b]
        number = max(3, 20000 // b)
        ns = best_ns(lambda: np.fft.fft(sub, axis=1), number) / b
        nsx = best_ns(lambda: fft_sw.fft8_fixed_np(br[:b], bi[:b]), max(3, 2000 // b)) / b
        batch.append({"batch": b, "numpy_ns": ns, "fixed_np_ns": nsx})
        print(f"  batch {b:6d}: NumPy {ns:10.1f} ns/FFT   bit-exact NumPy {nsx:10.1f} ns/FFT")
    return rows, batch


def cpu_name():
    try:
        with open("/proc/cpuinfo") as f:
            for line in f:
                if line.startswith("model name"):
                    return line.split(":", 1)[1].strip()
    except OSError:
        pass
    return platform.processor() or platform.machine()


# ---------------------------------------------------------------------------
# Charts
# ---------------------------------------------------------------------------
SW_COLOR = "#1279a8"   # software: blue   (palette checked for colour-blind
HW_COLOR = "#c9601a"   # hardware: orange  separation and contrast)
INK = "#1d2328"
MUTED = "#5b6770"


def fmt_ns(ns):
    if ns >= 1e6:
        return f"{ns / 1e6:.1f} ms"
    if ns >= 1e3:
        return f"{ns / 1e3:.1f} µs"
    return f"{ns:.0f} ns"


def fmt_j(j):
    for unit, s in (("mJ", 1e-3), ("µJ", 1e-6), ("nJ", 1e-9), ("pJ", 1e-12)):
        if j >= s:
            return f"{j / s:.3g} {unit}"
    return f"{j:.2g} J"


def note(ax, text, y=-0.16):
    """A small grey footnote under the plot, aligned with the plot's left edge."""
    import textwrap
    ax.text(0, y, "\n".join(textwrap.wrap(text, 115)), transform=ax.transAxes,
            fontsize=9, color=MUTED, ha="left", va="top")


def charts(res):
    import matplotlib
    matplotlib.use("Agg")
    import matplotlib.pyplot as plt
    from matplotlib.patches import Patch

    plt.rcParams.update({
        "font.size": 12, "axes.titlesize": 14, "axes.titleweight": "bold",
        "axes.spines.top": False, "axes.spines.right": False,
        "axes.edgecolor": MUTED, "xtick.color": MUTED, "ytick.color": INK,
        "axes.labelcolor": INK, "savefig.dpi": 150, "savefig.bbox": "tight",
    })
    os.makedirs(IMAGES, exist_ok=True)
    rows = res["software"] + res["hardware"]
    legend = [Patch(color=SW_COLOR, label="software (measured)"),
              Patch(color=HW_COLOR, label="hardware (sky130, after make pnr)")]

    def bar_chart(key, fmt, title, xlabel, name, footnote):
        data = sorted(rows, key=lambda r: r[key])
        fig, ax = plt.subplots(figsize=(10, 0.55 * len(data) + 1.6))
        y = np.arange(len(data))
        ax.barh(y, [r[key] for r in data], height=0.62,
                color=[SW_COLOR if r["kind"] == "sw" else HW_COLOR for r in data])
        ax.set_xscale("log")
        ax.set_yticks(y, [r["name"] for r in data])
        ax.invert_yaxis()
        for yi, r in zip(y, data):
            ax.text(r[key] * 1.15, yi, fmt(r[key]), va="center", fontsize=11, color=INK)
        lo = min(r[key] for r in data)
        hi = max(r[key] for r in data)
        ax.set_xlim(lo / 3, hi * 12)
        ax.grid(axis="x", alpha=0.25, which="major")
        ax.set_axisbelow(True)
        ax.set_title(title, loc="left")
        ax.set_xlabel(xlabel)
        ax.legend(handles=legend, loc="upper right", frameon=False, fontsize=10)
        note(ax, footnote, -0.1 - 0.6 / len(data))
        fig.savefig(os.path.join(IMAGES, name))
        plt.close(fig)
        print("wrote docs/images/" + name)

    cpu = res["machine"]["cpu"]
    bar_chart("ns", fmt_ns, "Time for one 8-point FFT (shorter is faster)",
              "nanoseconds per FFT (log scale: each grid line is 10x)",
              "codesign_speed.png",
              f"Software measured on {cpu}, one core. Hardware: 17 clock cycles per frame "
              "(8 load, 1 compute, 8 unload) at the 50 MHz constraint and at the estimated "
              "maximum clock.")

    for r in res["software"]:
        r["J"] = r["ns"] * 1e-9 * res["machine"]["cpu_watts"]
    rows = res["software"] + res["hardware"]
    bar_chart("J", fmt_j, "Energy for one 8-point FFT (shorter is better)",
              "joules per FFT (log scale)", "codesign_energy.png",
              f"Software energy is an estimate: time x {res['machine']['cpu_watts']:.0f} W for "
              "one busy CPU core (change with --cpu-watts). Hardware: 2.7 mW from make pnr x "
              "time; different process nodes (sky130 is 130 nm).")

    # Batch size: the cost of calling into NumPy is paid once per call
    b = res["batch"]
    fig, ax = plt.subplots(figsize=(10, 5.2))
    xs = [d["batch"] for d in b]
    ax.plot(xs, [d["numpy_ns"] for d in b], "-o", color=SW_COLOR, lw=2, ms=8,
            label="NumPy np.fft.fft (float)")
    ax.plot(xs, [d["fixed_np_ns"] for d in b], "--s", color=SW_COLOR, lw=2, ms=8,
            label="NumPy bit-exact model (integer)")
    hw = res["hardware"]
    for r, ls in ((hw[0], "-"), (hw[2], ":")):
        ax.axhline(r["ns"], color=HW_COLOR, lw=2, ls=ls)
        ax.text(xs[0], r["ns"] * 1.15, r["name"], color=INK, ha="left", va="bottom",
                fontsize=10)
    ax.set_xscale("log", base=2)
    ax.set_yscale("log")
    ax.set_xlabel("frames per call (batch size)")
    ax.set_ylabel("nanoseconds per FFT")
    ax.set_title("Software gets faster per FFT when you give it many frames at once",
                 loc="left")
    ax.grid(alpha=0.25, which="major")
    ax.legend(frameon=False, loc="upper right", fontsize=10)
    note(ax, "One call has a fixed cost (Python, argument checks, memory) of "
             "a few µs. Batching spreads it over many frames. The hardware has no such "
             "cost, but it handles one frame at a time.", -0.17)
    fig.savefig(os.path.join(IMAGES, "codesign_batch.png"))
    plt.close(fig)
    print("wrote docs/images/codesign_batch.png")

    # Where the hardware's 17 cycles go, and two ways to shorten them
    hwp = res["hw_params"]
    variants = [
        ("As built (fft8.v)", hwp["load_cycles"], hwp["compute_cycles"], hwp["unload_cycles"]),
        ("Overlap: unload while the next frame loads", hwp["load_cycles"], 0, 0),
        ("Load and unload 4 samples per clock", 2, hwp["compute_cycles"], 2),
    ]
    seg = [("load (1 sample per clock)", "#7fb4cf"), ("compute", HW_COLOR),
           ("unload (1 result per clock)", "#a9c9da")]
    fig, ax = plt.subplots(figsize=(10, 3.6))
    for yi, (name, *parts) in enumerate(variants):
        left = 0
        for (lab, col), w in zip(seg, parts):
            if w:
                ax.barh(yi, w, left=left, color=col, height=0.6, edgecolor="white", lw=2,
                        label=lab if yi == 0 else None)
                ax.text(left + w / 2, yi, str(w), ha="center", va="center", fontsize=11,
                        color=INK)
            left += w
        ax.text(left + 0.3, yi, f"{left} cycles per FFT", va="center", fontsize=11, color=INK)
    ax.set_yticks(range(len(variants)), [v[0] for v in variants])
    ax.invert_yaxis()
    ax.set_xlim(0, 22)
    ax.set_xticks(range(0, 21, 2))
    ax.set_xlabel("clock cycles per FFT")
    ax.set_title("The butterflies take 1 cycle; moving data takes 16", loc="left")
    ax.legend(frameon=False, ncol=3, loc="upper center", bbox_to_anchor=(0.5, -0.32), fontsize=10)
    ax.grid(False)
    fig.savefig(os.path.join(IMAGES, "codesign_cycles.png"))
    plt.close(fig)
    print("wrote docs/images/codesign_cycles.png")

    # Where the hardware's area goes
    regs = hwp["area_registers_um2"]
    mult = hwp["area_bfly_mult_um2"]
    other = hwp["area_bfly_other_um2"]
    glue = hwp["synth_area_um2"] - regs - mult - other
    pnr = hwp["cell_area_um2"] - hwp["synth_area_um2"]
    parts = [
        ("2 butterflies with x √2/2 (K=1, 3)", mult),
        ("10 butterflies with x 1 or x -j", other),
        ("587 flip-flops (sample + result buffers)", regs),
        ("load/unload multiplexers, control", glue),
        ("added by place and route (buffers, clock tree)", pnr),
    ]
    fig, ax = plt.subplots(figsize=(10, 4.2))
    y = np.arange(len(parts))
    ax.barh(y, [p[1] for p in parts], color=HW_COLOR, height=0.6)
    ax.set_yticks(y, [p[0] for p in parts])
    ax.invert_yaxis()
    total = hwp["cell_area_um2"]
    for yi, (_, v) in zip(y, parts):
        ax.text(v + 300, yi, f"{v / 1e3:.1f}k µm²  ({100 * v / total:.0f}%)", va="center",
                fontsize=11, color=INK)
    ax.set_xlim(0, max(p[1] for p in parts) * 1.45)
    ax.set_xlabel("cell area, µm²")
    ax.set_title(f"Where the FFT's {total / 1e3:.1f}k µm² of cells go", loc="left")
    ax.grid(axis="x", alpha=0.25)
    ax.set_axisbelow(True)
    note(ax, "Butterfly areas from synthesising fft_bfly.v alone for each twiddle "
             "(make area); flip-flops are 587 x 25.0 µm². The two constant multipliers cost "
             "more than the other ten butterflies together.", -0.22)
    fig.savefig(os.path.join(IMAGES, "codesign_area.png"))
    plt.close(fig)
    print("wrote docs/images/codesign_area.png")


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("--cpu-watts", type=float, default=10.0,
                    help="power of one busy CPU core, for the software energy estimate")
    ap.add_argument("--charts-only", action="store_true",
                    help="redraw the charts from codesign/results/bench.json")
    args = ap.parse_args()

    if args.charts_only:
        with open(RESULTS) as f:
            res = json.load(f)
    else:
        sw, batch = measure_software()
        res = {
            "machine": {"cpu": cpu_name(), "python": platform.python_version(),
                        "numpy": np.__version__, "cpu_watts": args.cpu_watts},
            "software": sw,
            "batch": batch,
            "hardware": hw_rows(),
            "hw_params": HW,
        }
        os.makedirs(os.path.dirname(RESULTS), exist_ok=True)
        with open(RESULTS, "w") as f:
            json.dump(res, f, indent=2)
        print("wrote codesign/results/bench.json")

    print("Hardware (from make pnr):")
    for r in res["hardware"]:
        print(f"  {r['name']:38s} {r['ns']:12.1f} ns per FFT   {fmt_j(r['J'])}")
    charts(res)


if __name__ == "__main__":
    main()
