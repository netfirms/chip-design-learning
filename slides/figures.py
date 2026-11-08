#!/usr/bin/env python3
"""figures.py -- draw the diagrams and plots used by the slide decks.

Every figure in slides/images/ that is not a layout render is made here, so
the decks can be regenerated (and corrected) from source:

    python3 slides/figures.py          # writes slides/images/*.png

Needs numpy and matplotlib (pip install -r python/requirements.txt).
The numbers match the RTL in designs/ (coefficients, widths, cycle counts).
"""
import os

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt  # noqa: E402
import numpy as np  # noqa: E402
from matplotlib.patches import FancyArrowPatch, FancyBboxPatch, Circle  # noqa: E402

OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "images")
ACCENT = "#0f6e8c"
ACCENT2 = "#e07a1f"
GREY = "#5b6770"
SOFT = "#e3f1f5"
GREEN = "#2e8b57"
RED = "#c0392b"

plt.rcParams.update({
    "font.size": 12,
    "axes.titlesize": 13,
    "axes.spines.top": False,
    "axes.spines.right": False,
    "axes.grid": True,
    "grid.alpha": 0.3,
    "savefig.dpi": 150,
    "savefig.bbox": "tight",
})


def save(fig, name):
    os.makedirs(OUT, exist_ok=True)
    fig.savefig(os.path.join(OUT, name))
    plt.close(fig)
    print("wrote", name)


# ---------------------------------------------------------------------------
# Drawing helpers for block diagrams
# ---------------------------------------------------------------------------
def canvas(w, h):
    fig, ax = plt.subplots(figsize=(w, h))
    ax.set_xlim(0, w)
    ax.set_ylim(0, h)
    ax.axis("off")
    ax.set_aspect("equal")
    return fig, ax


def box(ax, x, y, w, h, text, fc=SOFT, ec=ACCENT, fs=11, bold=False, tc="#1d2328"):
    ax.add_patch(FancyBboxPatch((x, y), w, h, boxstyle="round,pad=0.02,rounding_size=0.08",
                                fc=fc, ec=ec, lw=1.6))
    ax.text(x + w / 2, y + h / 2, text, ha="center", va="center", fontsize=fs,
            fontweight="bold" if bold else "normal", color=tc)


def arrow(ax, x0, y0, x1, y1, color=GREY, lw=1.5, style="-|>", text=None, tpos=0.5, toff=(0, 0.12), fs=10):
    ax.add_patch(FancyArrowPatch((x0, y0), (x1, y1), arrowstyle=style, mutation_scale=14,
                                 color=color, lw=lw, shrinkA=0, shrinkB=0))
    if text:
        ax.text(x0 + (x1 - x0) * tpos + toff[0], y0 + (y1 - y0) * tpos + toff[1], text,
                ha="center", va="bottom", fontsize=fs, color=color)


def op(ax, x, y, sym, r=0.22, fc="white"):
    ax.add_patch(Circle((x, y), r, fc=fc, ec=ACCENT, lw=1.6))
    ax.text(x, y, sym, ha="center", va="center", fontsize=13, color=ACCENT, fontweight="bold")


# ---------------------------------------------------------------------------
# Module 1: the flow
# ---------------------------------------------------------------------------
def fig_flow():
    fig, ax = canvas(14, 3.6)
    stages = [
        ("RTL\n.v", "you write it"),
        ("Simulate\nIcarus,\nVerilator", "does it work?"),
        ("Synthesis\nYosys", "netlist of cells"),
        ("Floorplan\nOpenROAD", "die, pins, power"),
        ("Placement\nOpenROAD", "cells get x,y"),
        ("CTS\nOpenROAD", "clock tree"),
        ("Routing\nOpenROAD", "metal wires"),
        ("GDS\nKLayout", "to the fab"),
    ]
    w, h, gap = 1.45, 1.25, 0.25
    x = 0.2
    for i, (name, sub) in enumerate(stages):
        fc = ACCENT if i in (0, 7) else SOFT
        tc = "white" if i in (0, 7) else "#1d2328"
        box(ax, x, 1.6, w, h, name, fc=fc, fs=10, bold=True, tc=tc)
        ax.text(x + w / 2, 1.3, sub, ha="center", va="top", fontsize=9.5, color=GREY, style="italic")
        if i < len(stages) - 1:
            arrow(ax, x + w + 0.02, 2.22, x + w + gap - 0.02, 2.22, color=ACCENT)
        x += w + gap
    # front end / back end braces
    ax.annotate("", xy=(0.2, 3.25), xytext=(4.8, 3.25),
                arrowprops=dict(arrowstyle="-", color=ACCENT2, lw=2))
    ax.text(2.5, 3.33, "front end: logic", ha="center", va="bottom", color=ACCENT2, fontsize=11, fontweight="bold")
    ax.annotate("", xy=(5.2, 3.25), xytext=(13.6, 3.25),
                arrowprops=dict(arrowstyle="-", color=GREEN, lw=2))
    ax.text(9.4, 3.33, "back end: physical (STA after every step)", ha="center", va="bottom",
            color=GREEN, fontsize=11, fontweight="bold")
    ax.text(7, 0.35, "Hardware is the new Software: every arrow is a command you run, every box writes a file you can read.",
            ha="center", fontsize=11, color=ACCENT)
    save(fig, "flow.png")


def fig_counter_wave():
    """Waveform of the 4-bit counter as in the testbench (WIDTH=4)."""
    n = 22
    en = np.array([0, 0, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1])
    rst_n = np.array([0, 0] + [1] * (n - 2))
    count = np.zeros(n, dtype=int)
    c = 0
    for i in range(n):
        count[i] = c
        if rst_n[i] and en[i]:
            c = (c + 1) % 16
    # re-run so counting starts at 10 near the end to show a wrap
    count = np.zeros(n, dtype=int)
    c = 9
    for i in range(n):
        if not rst_n[i]:
            c = 0
        count[i] = c
        if rst_n[i] and en[i]:
            c = (c + 1) % 16
    wrap = ((count == 15) & (en == 1)).astype(int)

    fig, ax = plt.subplots(figsize=(13, 3.8))
    ax.grid(False)
    rows = [("clk", None), ("rst_n", rst_n), ("en", en), ("count", count), ("wrap", wrap)]
    t = np.arange(n + 1)
    for r, (name, sig) in enumerate(rows):
        y0 = (len(rows) - 1 - r) * 1.3
        ax.text(-0.5, y0 + 0.4, name, ha="right", va="center", fontsize=12, family="monospace")
        if name == "clk":
            tt = np.repeat(np.arange(0, n + 0.5, 0.5), 2)[1:-1]
            vv = np.tile([1, 1, 0, 0], len(tt) // 4 + 1)[:len(tt)]
            ax.plot(tt, y0 + 0.8 * vv, color=GREY, lw=1.2)
        elif name == "count":
            for i in range(n):
                ax.plot([i + 0.1, i + 0.9], [y0 + 0.8, y0 + 0.8], color=ACCENT, lw=1.4)
                ax.plot([i + 0.1, i + 0.9], [y0, y0], color=ACCENT, lw=1.4)
                ax.plot([i, i + 0.1], [y0 + 0.4, y0 + 0.8], color=ACCENT, lw=1.4)
                ax.plot([i, i + 0.1], [y0 + 0.4, y0], color=ACCENT, lw=1.4)
                ax.plot([i + 0.9, i + 1], [y0 + 0.8, y0 + 0.4], color=ACCENT, lw=1.4)
                ax.plot([i + 0.9, i + 1], [y0, y0 + 0.4], color=ACCENT, lw=1.4)
                ax.text(i + 0.5, y0 + 0.4, str(count[i]), ha="center", va="center", fontsize=10)
        else:
            col = ACCENT2 if name == "wrap" else ACCENT
            ax.step(t, y0 + 0.8 * np.append(sig, sig[-1]), where="post", color=col, lw=1.8)
    for i in np.where(wrap)[0]:
        ax.axvspan(i, i + 1, color=ACCENT2, alpha=0.12)
        ax.annotate("wrap: count = 15 and en = 1\nso the next edge goes to 0", xy=(i + 0.5, 0.85),
                    xytext=(i - 8.5, 0.15), fontsize=10, color=ACCENT2,
                    arrowprops=dict(arrowstyle="->", color=ACCENT2))
    ax.set_xlim(-0.2, n)
    ax.set_ylim(-0.3, len(rows) * 1.3)
    ax.axis("off")
    save(fig, "counter_wave.png")


def fig_ff_timing():
    """Setup/hold and slack on a reg -> logic -> reg path."""
    fig, axs = plt.subplots(1, 2, figsize=(13, 3.9), gridspec_kw=dict(width_ratios=[1.05, 1]))
    ax = axs[0]
    ax.axis("off")
    ax.set_xlim(0, 7)
    ax.set_ylim(0, 3.2)
    box(ax, 0.2, 1.1, 1.2, 1.2, "FF1\nD    Q", fs=11)
    box(ax, 2.4, 1.1, 2.0, 1.2, "combinational\nlogic\n(adder, mux...)", fc="#fff4e6", ec=ACCENT2, fs=10)
    box(ax, 5.4, 1.1, 1.2, 1.2, "FF2\nD    Q", fs=11)
    arrow(ax, 1.4, 1.7, 2.4, 1.7, color=ACCENT, text="t_clk→q", toff=(0, 0.1))
    arrow(ax, 4.4, 1.7, 5.4, 1.7, color=ACCENT, text="t_logic", toff=(0, 0.1))
    ax.plot([0.1, 0.1, 5.3], [0.3, 0.75, 0.75], color=GREY, lw=1.3)
    arrow(ax, 0.8, 0.75, 0.8, 1.1, color=GREY)
    arrow(ax, 6.0, 0.75, 6.0, 1.1, color=GREY)
    ax.plot([5.3, 6.0], [0.75, 0.75], color=GREY, lw=1.3)
    ax.text(3.0, 0.45, "clk  (same edge reaches both, up to the skew)", ha="center", fontsize=10, color=GREY)
    ax.text(3.5, 2.85, "setup slack = T_clk − (t_clk→q + t_logic + t_setup) − skew",
            ha="center", fontsize=11, color=ACCENT, fontweight="bold")

    ax = axs[1]
    ax.grid(False)
    T = 10.0
    t = np.linspace(0, 2 * T, 2000)
    clk = ((t % T) < T / 2).astype(float)
    ax.plot(t, 3 + 0.7 * clk, color=GREY)
    ax.text(-0.5, 3.35, "clk", ha="right", va="center", family="monospace")
    # data arriving at FF2
    arr = 6.3
    ax.fill_between([0, arr], 1.6, 2.3, color="#fff4e6", ec=ACCENT2)
    ax.text(arr / 2, 1.95, "data travelling\n(clk→q + logic)", ha="center", va="center", fontsize=9.5)
    ax.fill_between([arr, 2 * T], 1.6, 2.3, color=SOFT, ec=ACCENT)
    ax.text(-0.5, 1.95, "D of FF2", ha="right", va="center", family="monospace")
    tsu = 0.8
    ax.axvspan(T - tsu, T, ymin=0.05, ymax=0.95, color=RED, alpha=0.15)
    ax.text(T - tsu / 2, 0.6, "t_setup", ha="center", fontsize=9.5, color=RED)
    ax.annotate("", xy=(arr, 1.2), xytext=(T - tsu, 1.2), arrowprops=dict(arrowstyle="<->", color=GREEN, lw=1.8))
    ax.text((arr + T - tsu) / 2, 0.95, "slack > 0", ha="center", fontsize=10, color=GREEN, fontweight="bold")
    ax.axvline(T, color=GREY, ls="--", lw=1)
    ax.text(T, 4.0, "capture edge", ha="center", fontsize=9.5, color=GREY)
    ax.text(0, 4.0, "launch edge", ha="left", fontsize=9.5, color=GREY)
    ax.set_xlim(-0.2, 2 * T)
    ax.set_ylim(0.3, 4.3)
    ax.set_yticks([])
    ax.set_xlabel("time (ns), T_clk = 10 ns")
    save(fig, "setup_slack.png")


# ---------------------------------------------------------------------------
# Module 2: PWM
# ---------------------------------------------------------------------------
def fig_pwm():
    W = 4
    P = 2 ** W
    duties = [4] * 6 + [12] * 6
    cyc = np.arange(P * len(duties))
    cnt = cyc % P
    duty_q = np.repeat(duties, P)
    out = (cnt < duty_q).astype(float)
    # RC filter (one-pole IIR) on a fine time grid
    fine = np.repeat(out, 20)
    alpha = 0.003
    rc = np.zeros_like(fine)
    for i in range(1, len(fine)):
        rc[i] = rc[i - 1] + alpha * (fine[i] - rc[i - 1])
    tf = np.arange(len(fine)) / 20

    fig, axs = plt.subplots(3, 1, figsize=(13, 5.6), sharex=True,
                            gridspec_kw=dict(height_ratios=[1.3, 0.8, 1.1]))
    ax = axs[0]
    ax.step(cyc, cnt, where="post", color=ACCENT, label="cnt (sawtooth)")
    ax.step(cyc, duty_q, where="post", color=ACCENT2, lw=2, label="duty_q (latched at wrap)")
    ax.set_ylabel("value")
    ax.legend(loc="upper left", fontsize=9, ncol=2)
    ax.set_title(f"WIDTH = {W}: pwm_out = (cnt < duty_q).  duty changes 4 → 12 only at a period boundary")
    ax = axs[1]
    ax.step(cyc, out, where="post", color=GREEN, lw=2)
    ax.set_yticks([0, 1])
    ax.set_ylabel("pwm_out")
    ax = axs[2]
    ax.plot(tf, rc, color=RED, lw=2, label="after RC low-pass")
    for k, d in enumerate(duties):
        ax.hlines(d / P, k * P, (k + 1) * P, color=GREY, ls="--", lw=1)
    ax.text(2, 4 / P + 0.06, "VDD·4/16 = 25 %", fontsize=9.5, color=GREY)
    ax.text(6 * P + 2, 12 / P + 0.06, "VDD·12/16 = 75 %", fontsize=9.5, color=GREY)
    ax.set_ylim(0, 1.05)
    ax.set_ylabel("V / VDD")
    ax.set_xlabel("clock cycle")
    ax.legend(loc="lower right", fontsize=9)
    save(fig, "pwm_wave.png")


def fig_pwm_glitch():
    """Why double-buffering: changing duty mid-period without a latch."""
    P = 16
    cyc = np.arange(2 * P)
    cnt = cyc % P
    duty_raw = np.where(cyc < 6, 10, 3)            # software writes 3 at cycle 6
    no_buf = (cnt < duty_raw).astype(float)
    duty_q = np.where(cyc < P, 10, 3)
    buf = (cnt < duty_q).astype(float)
    fig, axs = plt.subplots(2, 1, figsize=(12, 3.4), sharex=True)
    for ax, sig, title, col in ((axs[0], no_buf, "compare against duty directly: period 1 is cut short (6 instead of 10 or 3)", RED),
                                (axs[1], buf, "compare against duty_q (latched at wrap): every period is exactly 10 or 3", GREEN)):
        ax.step(cyc, sig, where="post", color=col, lw=2)
        ax.set_title(title, fontsize=11, loc="left")
        ax.set_yticks([0, 1])
        ax.axvline(6, color=GREY, ls=":", lw=1)
        ax.axvline(P, color=GREY, ls="--", lw=1)
    axs[0].text(6.2, 0.45, "CPU writes duty = 3", fontsize=9.5, color=GREY)
    axs[1].set_xlabel("clock cycle")
    save(fig, "pwm_glitch.png")


def fig_pwm_block():
    fig, ax = canvas(11, 3.4)
    box(ax, 0.2, 1.9, 1.7, 0.9, "cnt\n+1 register", fs=10)
    box(ax, 0.2, 0.4, 1.7, 0.9, "duty input\n(from CPU)", fc="white", fs=10)
    box(ax, 3.0, 0.4, 1.7, 0.9, "duty_q\nregister", fs=10)
    box(ax, 3.0, 1.9, 1.7, 0.9, "cnt == max?\n(wrap)", fc="#fff4e6", ec=ACCENT2, fs=10)
    box(ax, 5.8, 1.15, 1.6, 0.9, "cnt < duty_q", fc="#fff4e6", ec=ACCENT2, fs=10)
    box(ax, 8.4, 1.15, 1.4, 0.9, "pwm_out\nflip-flop", fs=10)
    arrow(ax, 1.9, 2.35, 3.0, 2.35)
    arrow(ax, 1.9, 0.85, 3.0, 0.85)
    arrow(ax, 3.85, 1.9, 3.85, 1.3, color=ACCENT2, text="load", tpos=0.5, toff=(0.35, -0.1))
    arrow(ax, 2.4, 2.35, 2.4, 3.05, style="-")
    ax.plot([2.4, 6.6], [3.05, 3.05], color=GREY, lw=1.5)
    arrow(ax, 6.6, 3.05, 6.6, 2.05)
    arrow(ax, 4.7, 0.85, 6.0, 1.15)
    arrow(ax, 7.4, 1.6, 8.4, 1.6)
    arrow(ax, 9.8, 1.6, 10.8, 1.6)
    ax.text(9.1, 0.8, "glitch-free pin", ha="center", fontsize=10, color=GREY)
    save(fig, "pwm_block.png")


# ---------------------------------------------------------------------------
# Module 3: fixed point
# ---------------------------------------------------------------------------
def fig_qformat():
    fig, ax = canvas(13, 2.9)
    bits = 16
    w = 0.72
    x0 = 0.6
    for i in range(bits):
        b = bits - 1 - i
        fc = ACCENT2 if i == 0 else (SOFT if i < 1 else "white")
        ax.add_patch(FancyBboxPatch((x0 + i * w, 1.2), w - 0.06, 0.8, boxstyle="square,pad=0", fc=fc, ec=ACCENT, lw=1.3))
        weight = "−2⁰" if i == 0 else f"2⁻{i}"
        ax.text(x0 + i * w + w / 2 - 0.03, 1.6, weight, ha="center", va="center", fontsize=10,
                color="white" if i == 0 else "#1d2328")
        ax.text(x0 + i * w + w / 2 - 0.03, 2.15, str(b), ha="center", fontsize=9, color=GREY)
    ax.plot([x0 + w - 0.03] * 2, [1.0, 2.25], color=RED, lw=2.5)
    ax.text(x0 + w, 0.8, "binary point", color=RED, fontsize=10, ha="left")
    ax.text(x0, 0.35, "Q1.15: 1 integer bit (the sign, weight −1) + 15 fraction bits.  value = v / 2¹⁵,  range [−1, 1 − 2⁻¹⁵],  1 LSB = 3.05·10⁻⁵",
            fontsize=11, color="#1d2328")
    ax.text(x0, 2.55, "bit index", fontsize=9, color=GREY)
    save(fig, "qformat.png")


def fig_rounding():
    fig, axs = plt.subplots(1, 3, figsize=(14, 4))
    x = np.linspace(-4, 4, 801)
    ax = axs[0]
    ax.plot(x, x, color=GREY, lw=1, ls="--", label="exact")
    ax.step(x, np.floor(x), where="post", color=RED, lw=1.8, label="truncate (>>>)")
    ax.step(x, np.floor(x + 0.5), where="post", color=GREEN, lw=1.8, label="round to nearest")
    ax.set_title("dropping fraction bits (units: output LSB)")
    ax.legend(fontsize=9)
    ax.set_xlabel("exact value")

    rng = np.random.default_rng(1)
    v = rng.uniform(-100, 100, 20000)
    ax = axs[1]
    ax.hist(np.floor(v) - v, bins=40, range=(-1, 1), color=RED, alpha=0.6, label="truncate: mean −0.5")
    ax.hist(np.floor(v + 0.5) - v, bins=40, range=(-1, 1), color=GREEN, alpha=0.6, label="round: mean 0")
    ax.set_title("error histogram")
    ax.set_xlabel("error (LSB)")
    ax.legend(fontsize=9)

    ax = axs[2]
    t = np.arange(200)
    s = 1.4 * np.sin(2 * np.pi * t / 100)
    wrap = ((s + 1) % 2) - 1
    sat = np.clip(s, -1, 1 - 2 ** -15)
    ax.plot(t, s, color=GREY, ls="--", lw=1, label="ideal (does not fit)")
    ax.plot(t, wrap, color=RED, lw=1.6, label="wrap-around (Verilog default)")
    ax.plot(t, sat, color=GREEN, lw=2, label="saturate")
    ax.set_title("overflow in Q1.15 (range [−1, 1))")
    ax.legend(fontsize=9, loc="lower left")
    ax.set_xlabel("sample")
    save(fig, "rounding.png")


def fig_bitgrowth():
    fig, ax = canvas(13, 3.6)
    items = [
        ("x[n]\nQ1.15\n16 b", 0.3),
        ("× h[k]\nQ1.15", None),
        ("product\nQ2.30\n32 b", 3.3),
        ("Σ of 16\n+4 guard bits", None),
        ("acc\nQ6.30\n36 b", 6.3),
        ("round,\n>>> 15", None),
        ("Q6.15\n21 b", 9.0),
        ("saturate", None),
        ("y[n]\nQ1.15\n16 b", 11.5),
    ]
    xs = [0.3, 1.75, 3.3, 4.8, 6.3, 7.8, 9.0, 10.35, 11.5]
    for (txt, _), x in zip(items, xs):
        if "\n" in txt and ("b" in txt.split("\n")[-1]):
            nb = int(txt.split("\n")[-1].split()[0])
            box(ax, x, 1.8 - nb * 0.02, 1.2, 0.6 + nb * 0.04, txt, fs=10)
        else:
            ax.text(x + 0.4, 2.75, txt, ha="center", va="bottom", fontsize=10, color=ACCENT2)
    for a, b in zip(xs[:-1], xs[1:]):
        pass
    for x0, x1 in ((1.5, 3.3), (4.5, 6.3), (7.5, 9.0), (10.2, 11.5)):
        arrow(ax, x0, 2.2, x1, 2.2, color=ACCENT)
    ax.text(6.5, 0.25, "FIR datapath width at every point: multiply adds formats, sums add guard bits, rounding and saturation bring it back",
            ha="center", fontsize=10.5, color=GREY)
    save(fig, "bitgrowth.png")


# ---------------------------------------------------------------------------
# Module 4: FIR
# ---------------------------------------------------------------------------
FIR_H = np.array([-114, -159, -139, 291, 1450, 3284, 5246, 6525,
                  6525, 5246, 3284, 1450, 291, -139, -159, -114])


def freqz(b, a, n=1024):
    f = np.linspace(0, 0.5, n)
    z = np.exp(-2j * np.pi * f)
    return f, np.polyval(np.asarray(b, float)[::-1], z) / np.polyval(np.asarray(a, float)[::-1], z)


def db(x):
    return 20 * np.log10(np.maximum(np.abs(x), 1e-12))


def fig_fir_response():
    h = FIR_H / 2 ** 15
    nn = np.arange(16) - 7.5
    hf = 0.2 * np.sinc(0.2 * nn) * np.hamming(16)
    hf /= hf.sum()
    fig, axs = plt.subplots(1, 2, figsize=(13, 4))
    ax = axs[0]
    ax.stem(np.arange(16), FIR_H, linefmt=ACCENT, markerfmt="o", basefmt=GREY)
    ax.set_title("h[k] as integers (Q1.15), symmetric: h[k] = h[15−k]")
    ax.set_xlabel("tap k")
    ax.set_ylabel("coef (sum = 32768 → DC gain 1)")
    ax = axs[1]
    f, H = freqz(hf, [1])
    _, Hq = freqz(h, [1])
    ax.plot(f, db(H), color=GREY, lw=2, label="floating point")
    ax.plot(f, db(Hq), color=ACCENT, ls="--", lw=2, label="Q1.15 coefficients")
    ax.axvspan(0, 0.05, color=GREEN, alpha=0.08)
    ax.axvspan(0.2, 0.5, color=RED, alpha=0.06)
    ax.text(0.01, -75, "pass band", color=GREEN, fontsize=10)
    ax.text(0.27, -72, "stop band ≈ −50…−60 dB", color=RED, fontsize=10)
    ax.axvline(0.1, color=ACCENT2, ls=":", lw=1.4)
    ax.text(0.11, -22, "cutoff 0.1 fs (−6 dB)", color=ACCENT2, fontsize=10)
    ax.set_ylim(-80, 5)
    ax.set_xlabel("frequency / fs")
    ax.set_ylabel("|H| (dB)")
    ax.set_title("frequency response")
    ax.legend(fontsize=9, loc="upper right", bbox_to_anchor=(1, 0.88))
    save(fig, "fir_response.png")


def fig_fir_arch():
    fig, axs = plt.subplots(1, 2, figsize=(14, 4.6))
    # Left: direct form, parallel
    ax = axs[0]
    ax.axis("off")
    ax.set_xlim(0, 8)
    ax.set_ylim(0, 4.6)
    ax.set_aspect("equal")
    ax.set_title("fully parallel: 16 multipliers, 1 sample / clock", color=GREY)
    xs = [0.9, 2.6, 4.3, 6.6]
    labels = ["x[n]", "x[n−1]", "x[n−2]", "x[n−15]"]
    ax.text(0.1, 3.7, "x[n] →", fontsize=11, va="center")
    for i, x in enumerate(xs):
        if i > 0:
            if i == 3:
                ax.text((xs[2] + x) / 2 + 0.3, 3.7, "· · ·", fontsize=14, ha="center", va="center")
            else:
                box(ax, x - 0.75, 3.4, 0.6, 0.6, "z⁻¹", fs=10)
                arrow(ax, xs[i - 1], 3.7, x - 0.75, 3.7)
                ax.plot([x - 0.15, x], [3.7, 3.7], color=GREY, lw=1.5)
        arrow(ax, x, 3.7, x, 2.62)
        op(ax, x, 2.4, "×")
        ax.text(x + 0.3, 2.5, f"h{[0, 1, 2, 15][i]}", fontsize=10, color=ACCENT2)
        arrow(ax, x, 2.18, x, 1.32)
        ax.text(x + 0.08, 3.25, labels[i], fontsize=9, ha="left", color=GREY)
    for i, x in enumerate(xs):
        op(ax, x, 1.1, "+") if i > 0 else None
    ax.plot([xs[0], xs[0]], [1.32, 1.1], color=GREY, lw=1.5)
    for i in range(3):
        arrow(ax, xs[i] + (0.22 if i > 0 else 0), 1.1, xs[i + 1] - 0.22, 1.1)
    arrow(ax, xs[3] + 0.22, 1.1, 7.8, 1.1, text="y[n]", toff=(0.2, 0.1))
    ax.text(4, 0.25, "area: 16 × multiplier + 15 adders + 16 registers", ha="center", fontsize=10, color=RED)

    # Right: time-shared MAC (what designs/fir does)
    ax = axs[1]
    ax.axis("off")
    ax.set_xlim(0, 8)
    ax.set_ylim(0, 4.6)
    ax.set_aspect("equal")
    ax.set_title("time-shared MAC (designs/fir): 1 multiplier, 17 clocks / sample", color=GREY)
    box(ax, 0.2, 2.9, 2.2, 1.1, "delay line\n16 × 16-bit regs", fs=10)
    box(ax, 0.2, 1.0, 2.2, 1.1, "coef ROM\ncase (k)", fs=10)
    box(ax, 3.2, 3.95, 1.4, 0.55, "k counter", fc="#fff4e6", ec=ACCENT2, fs=9.5)
    op(ax, 3.4, 2.5, "×")
    op(ax, 4.9, 2.5, "+")
    box(ax, 5.6, 2.15, 1.2, 0.7, "acc\n36 b", fs=10)
    box(ax, 5.6, 0.75, 2.2, 0.75, "round, sat\n→ y[n]", fc="white", fs=10)
    arrow(ax, 2.4, 3.45, 3.25, 2.65, text="x[n−k]", tpos=0.4, toff=(-0.15, 0.08))
    arrow(ax, 2.4, 1.55, 3.25, 2.35, text="h[k]", tpos=0.4, toff=(-0.3, 0.05))
    arrow(ax, 3.62, 2.5, 4.68, 2.5)
    arrow(ax, 5.12, 2.5, 5.6, 2.5)
    ax.plot([6.8, 7.2, 7.2, 4.9], [2.5, 2.5, 1.85, 1.85], color=GREY, lw=1.5)
    arrow(ax, 4.9, 1.85, 4.9, 2.28)
    arrow(ax, 7.2, 1.85, 7.2, 1.5)
    ax.plot([3.9, 3.9, 1.3], [3.95, 3.75, 3.75], color=ACCENT2, lw=1.2, ls="--")
    ax.plot([3.9, 3.9, 2.5], [3.75, 2.0, 2.0], color=ACCENT2, lw=1.2, ls="--")
    ax.text(4, 0.25, "area: 1 multiplier + 1 adder; throughput ÷ 17", ha="center", fontsize=10, color=GREEN)
    fig.tight_layout()
    save(fig, "fir_arch.png")


def fig_fir_timeline():
    fig, ax = plt.subplots(figsize=(13, 2.6))
    ax.grid(False)
    for s in range(3):
        base = s * 17
        ax.broken_barh([(base, 1)], (1.1, 0.8), color=ACCENT2)
        ax.broken_barh([(base + 1, 16)], (1.1, 0.8), color=SOFT, ec=ACCENT)
        ax.text(base + 0.5, 1.5, "load", ha="center", va="center", fontsize=8, rotation=90, color="white")
        ax.text(base + 9, 1.5, f"MAC k = 0 … 15  (sample {s})", ha="center", va="center", fontsize=10)
        ax.annotate("out_valid", xy=(base + 17, 1.1), xytext=(base + 17, 0.25), ha="center", fontsize=9,
                    color=GREEN, arrowprops=dict(arrowstyle="->", color=GREEN))
    ax.set_xlim(0, 51.5)
    ax.set_ylim(0, 2.2)
    ax.set_yticks([])
    ax.set_xlabel("clock cycle: in_ready is high only in the load cycle; 100 MHz / 17 ≈ 5.9 Msample/s")
    save(fig, "fir_timeline.png")


# ---------------------------------------------------------------------------
# Module 5: IIR
# ---------------------------------------------------------------------------
IIR_B = np.array([329, 658, 329]) / 2 ** 14
IIR_A = np.array([16384, -25576, 10508]) / 2 ** 14


def fig_iir_df1():
    fig, ax = canvas(12, 4.6)
    xL, xS, xR = 1.6, 5.4, 9.2
    ax.text(0.2, 3.8, "x[n]", fontsize=12, va="center")
    ax.text(11.0, 3.8, "y[n]", fontsize=12, va="center")
    ys = [3.8, 2.5, 1.2]
    for i, y in enumerate(ys):
        if i > 0:
            box(ax, xL - 0.35, y + 0.35, 0.7, 0.55, "z⁻¹", fs=10)
            box(ax, xR - 0.35, y + 0.35, 0.7, 0.55, "z⁻¹", fs=10)
        op(ax, 3.3, y, "×")
        ax.text(3.3, y + 0.3, f"b{i}", fontsize=10, color=ACCENT2, ha="center")
        arrow(ax, xL, y, 3.08, y)
        arrow(ax, 3.52, y, xS - 0.22, ys[0] if i == 0 else y)
        if i > 0:
            op(ax, 7.5, y, "×")
            ax.text(7.5, y + 0.3, f"−a{i}", fontsize=10, color=ACCENT2, ha="center")
            arrow(ax, xR, y, 7.72, y)
            arrow(ax, 7.28, y, xS + 0.22, y)
    ax.plot([0.8, xL], [3.8, 3.8], color=GREY, lw=1.5)
    ax.plot([xL, xL], [3.8, 0.9 + 0.35 + 0.55], color=GREY, lw=1.5)
    ax.plot([xR, xR], [3.8, 0.9 + 0.35 + 0.55], color=GREY, lw=1.5)
    # adder column
    for y in ys:
        op(ax, xS, y, "+")
    arrow(ax, xS, 1.42, xS, 2.28)
    arrow(ax, xS, 2.72, xS, 3.58)
    arrow(ax, xS + 0.22, 3.8, 10.9, 3.8)
    ax.add_patch(FancyBboxPatch((6.9, 0.6), 2.9, 3.6, boxstyle="round,pad=0.05", fc="none", ec=RED, ls="--", lw=1.5))
    ax.text(8.35, 0.25, "feedback loop: y[n−1] → × → + → y[n] in ONE clock", ha="center", fontsize=10, color=RED)
    ax.text(3.0, 0.25, "feed-forward: can be pipelined freely", ha="center", fontsize=10, color=GREEN)
    save(fig, "iir_df1.png")


def fig_iir_pz():
    fig, axs = plt.subplots(1, 3, figsize=(15, 4.4))
    ax = axs[0]
    th = np.linspace(0, 2 * np.pi, 400)
    ax.plot(np.cos(th), np.sin(th), color=GREY, lw=1)
    poles = np.roots(IIR_A)
    zeros = np.roots(IIR_B)
    ax.plot(poles.real, poles.imag, "x", ms=12, mew=2.5, color=RED, label=f"poles |p| = {abs(poles[0]):.3f}")
    ax.plot(zeros.real, zeros.imag, "o", ms=10, mfc="none", mew=2, color=ACCENT, label="double zero at z = −1")
    # A much narrower low-pass (0.002 fs) has poles right next to z = 1:
    # rounding its coefficients to Q2.8 pushes them onto the unit circle.
    w0 = 2 * np.pi * 0.002
    al = np.sin(w0) / np.sqrt(2)
    an = np.array([1 + al, -2 * np.cos(w0), 1 - al])
    an /= an[0]
    for bits, col, mk in ((14, ACCENT2, "+"), (8, "#8e44ad", "1")):
        pq = np.roots(np.round(an * 2 ** bits) / 2 ** bits)
        ax.plot(pq.real, pq.imag, mk, ms=13, mew=2, color=col,
                label=f"0.002 fs filter, Q2.{bits}: |p| = {abs(pq).max():.4f}")
    ax.set_aspect("equal")
    ax.set_xlim(-1.3, 1.3)
    ax.set_ylim(-1.3, 1.3)
    ax.set_title("z-plane: stable ⇔ all poles inside |z| = 1")
    ax.legend(fontsize=8, loc="lower left")
    ax.set_xlabel("Re z")
    ax.set_ylabel("Im z")

    ax = axs[1]
    f, H = freqz(IIR_B, IIR_A)
    nn = np.arange(16) - 7.5
    hf = 0.2 * np.sinc(0.2 * nn) * np.hamming(16)
    hf /= hf.sum()
    _, Hfir = freqz(hf, [1])
    ax.plot(f, db(H), color=ACCENT, lw=2, label="IIR biquad (5 multipliers)")
    ax.plot(f, db(Hfir), color=GREY, lw=1.5, ls="--", label="16-tap FIR (16 multiplies)")
    ax.axvline(0.05, color=ACCENT2, ls=":")
    ax.text(0.055, -60, "−3 dB at 0.05 fs", color=ACCENT2, fontsize=10)
    ax.set_ylim(-80, 5)
    ax.set_xlabel("frequency / fs")
    ax.set_ylabel("|H| (dB)")
    ax.set_title("frequency response")
    ax.legend(fontsize=9)

    ax = axs[2]
    n = 80
    x = np.ones(n)
    y = np.zeros(n)
    for i in range(n):
        y[i] = (IIR_B[0] * x[i] + IIR_B[1] * (x[i - 1] if i >= 1 else 0) + IIR_B[2] * (x[i - 2] if i >= 2 else 0)
                - IIR_A[1] * (y[i - 1] if i >= 1 else 0) - IIR_A[2] * (y[i - 2] if i >= 2 else 0))
    hfir = np.convolve(x, hf)[:n]
    ax.plot(np.arange(n), y, color=ACCENT, lw=2, label="IIR step response")
    ax.plot(np.arange(n), hfir, color=GREY, ls="--", lw=1.5, label="FIR step response")
    ax.axhline(1, color=GREY, lw=0.8)
    ax.set_title("step response: IIR settles to exactly 1")
    ax.set_xlabel("sample")
    ax.legend(fontsize=9)
    save(fig, "iir_pz.png")


def fig_iir_limit_cycle():
    """Wrap-around vs saturation in a resonant biquad driven hard."""
    # Resonant biquad, poles at r = 0.995: hit with a large pulse train
    r, w = 0.995, 2 * np.pi * 0.02
    a1, a2 = -2 * r * np.cos(w), r * r
    n = 400
    x = np.zeros(n)
    x[0:3] = 0.9
    def run(mode):
        y = np.zeros(n)
        for i in range(n):
            v = 0.3 * x[i] - a1 * (y[i - 1] if i else 0) - a2 * (y[i - 2] if i > 1 else 0)
            if mode == "wrap":
                v = ((v + 1) % 2) - 1
            elif mode == "sat":
                v = min(max(v, -1), 1 - 2 ** -15)
            y[i] = v
        return y
    fig, ax = plt.subplots(figsize=(12, 3.3))
    ax.plot(run("wrap"), color=RED, lw=1.2, label="wrap-around: overflow corrupts the state")
    ax.plot(run("sat"), color=GREEN, lw=1.6, label="saturate: clipped, then decays normally")
    ax.set_xlabel("sample")
    ax.set_title("resonant biquad (poles at r = 0.995) hit by a large input: why IIR outputs saturate")
    ax.legend(fontsize=9, loc="upper right")
    save(fig, "iir_overflow.png")


# ---------------------------------------------------------------------------
# Module 6: FFT
# ---------------------------------------------------------------------------
def fig_fft_butterfly():
    fig, ax = plt.subplots(figsize=(13, 6.2))
    ax.axis("off")
    ax.set_xlim(-1.4, 10.6)
    ax.set_ylim(-1.5, 8.0)
    rev = [0, 4, 2, 6, 1, 5, 3, 7]
    xs = [0, 3, 6, 9]
    y = lambda i: 7 - i
    for i in range(8):
        ax.text(-0.3, y(i), f"x[{rev[i]}]", ha="right", va="center", fontsize=11, family="monospace")
        ax.text(9.3, y(i), f"X[{i}]", ha="left", va="center", fontsize=11, family="monospace")
        for x in xs:
            ax.plot(x, y(i), "o", color=ACCENT, ms=5)
    cols = [ACCENT, ACCENT2, GREEN]
    for s, span in enumerate([1, 2, 4]):
        x0, x1 = xs[s], xs[s + 1]
        for g in range(0, 8, 2 * span):
            for j in range(span):
                a, b = g + j, g + j + span
                k = j * (4 // span)
                c = cols[s]
                ax.plot([x0, x1], [y(a), y(a)], color=c, lw=1.4)
                ax.plot([x0, x1], [y(b), y(b)], color=c, lw=1.4)
                ax.plot([x0, x1], [y(a), y(b)], color=c, lw=1.0, alpha=0.8)
                ax.plot([x0, x1], [y(b), y(a)], color=c, lw=1.0, alpha=0.8)
                ax.text(x0 + 0.35, y(b) - 0.28, f"W{k}" if k else "W0", fontsize=8.5, color=c)
    for s, txt in enumerate(["stage 1: span 1\nW⁰ only (add/sub)", "stage 2: span 2\nW⁰, W² = −j (free)",
                             "stage 3: span 4\nW⁰…W³ (√2/2 multiplies)"]):
        ax.text(xs[s] + 1.5, -1.0, txt, ha="center", fontsize=10.5, color=cols[s], fontweight="bold")
    ax.text(-1.3, 7.75, "bit-reversed input", fontsize=10, color=GREY)
    ax.text(9.0, 7.75, "natural-order output", fontsize=10, color=GREY)
    save(fig, "fft_butterfly.png")


def fig_twiddles():
    fig, axs = plt.subplots(1, 2, figsize=(13, 4.6), gridspec_kw=dict(width_ratios=[1, 1.3]))
    ax = axs[0]
    th = np.linspace(0, 2 * np.pi, 400)
    ax.plot(np.cos(th), np.sin(th), color=GREY, lw=1)
    labels = ["W⁰ = 1\n(free)", "W¹ = c(1 − j)\n1 const mult", "W² = −j\n(swap, negate)", "W³ = c(−1 − j)\n1 const mult"]
    for k in range(8):
        w = np.exp(-2j * np.pi * k / 8)
        col = ACCENT if k < 4 else "#bbbbbb"
        ax.plot([0, w.real], [0, w.imag], color=col, lw=1.5)
        ax.plot(w.real, w.imag, "o", color=col, ms=8)
        if k < 4:
            ax.text(1.45 * w.real + (0.05 if k == 0 else 0), 1.45 * w.imag - (0.05 if k == 2 else 0), labels[k],
                    ha="center", va="center", fontsize=9.5, color=ACCENT)
    ax.set_aspect("equal")
    ax.set_xlim(-2.0, 2.1)
    ax.set_ylim(-1.9, 1.4)
    ax.set_title("W₈ᵏ = e^(−j2πk/8);  c = √2/2 ≈ 23170 / 2¹⁵")

    ax = axs[1]
    ax.axis("off")
    ax.set_xlim(0, 8)
    ax.set_ylim(0, 4.9)
    ax.set_title("one butterfly (fft_bfly.v)")
    ax.text(0.2, 3.6, "a", fontsize=14, va="center")
    ax.text(0.2, 1.0, "b", fontsize=14, va="center")
    op(ax, 2.0, 1.0, "×")
    ax.text(2.0, 0.45, "W^K", ha="center", fontsize=10, color=ACCENT2)
    arrow(ax, 0.5, 1.0, 1.78, 1.0)
    op(ax, 4.6, 3.6, "+")
    op(ax, 4.6, 1.0, "−")
    ax.plot([0.5, 3.4], [3.6, 3.6], color=GREY, lw=1.5)
    arrow(ax, 3.4, 3.6, 4.38, 3.6)
    ax.plot([2.22, 3.4], [1.0, 1.0], color=GREY, lw=1.5)
    arrow(ax, 3.4, 1.0, 4.38, 1.0)
    arrow(ax, 3.4, 3.6, 4.42, 1.15)
    arrow(ax, 3.4, 1.0, 4.42, 3.45)
    box(ax, 5.3, 3.3, 0.9, 0.6, "÷2", fs=11)
    box(ax, 5.3, 0.7, 0.9, 0.6, "÷2", fs=11)
    arrow(ax, 4.82, 3.6, 5.3, 3.6)
    arrow(ax, 4.82, 1.0, 5.3, 1.0)
    arrow(ax, 6.2, 3.6, 6.8, 3.6)
    arrow(ax, 6.2, 1.0, 6.8, 1.0)
    ax.text(6.9, 3.6, "y0 = (a + Wb)/2", fontsize=10.5, va="center")
    ax.text(6.9, 1.0, "y1 = (a − Wb)/2", fontsize=10.5, va="center")
    ax.text(4.0, 4.2, "÷2 per stage → ÷8 total:\noutputs can never overflow", ha="center", fontsize=10, color=GREEN)
    save(fig, "fft_twiddles.png")


def fig_fft_cost():
    N = 2 ** np.arange(3, 13)
    fig, ax = plt.subplots(figsize=(10, 4))
    ax.loglog(N, N.astype(float) ** 2, "o-", color=RED, label="direct DFT: N² complex multiplies")
    ax.loglog(N, N / 2 * np.log2(N), "o-", color=GREEN, label="radix-2 FFT: (N/2)·log₂N")
    for n in (8, 1024):
        ax.annotate(f"N = {n}: {n * n:,} vs {int(n / 2 * np.log2(n)):,}", xy=(n, n / 2 * np.log2(n)),
                    xytext=(n * 0.6, n / 2 * np.log2(n) / 12), fontsize=10, color=GREEN,
                    arrowprops=dict(arrowstyle="->", color=GREEN))
    ax.set_xlabel("FFT size N")
    ax.set_ylabel("complex multiplies")
    ax.legend()
    save(fig, "fft_cost.png")


# ---------------------------------------------------------------------------
# Module 7: trade-offs (numbers from make synth-sky130 / orfs constraints)
# ---------------------------------------------------------------------------
DESIGNS = [
    # name, cells, cell area um^2, SDC clock MHz, cycles per sample
    # (after make pnr: the Module 7 table in docs/learning-path.md)
    ("counter", 27, 339, 100, None),
    ("pwm", 71, 908, 100, None),
    ("fir", 2123, 25200, 100, 17),
    ("iir", 1560, 19000, 50, 1),
    ("fft8", 9073, 79800, 50, 17 / 8),   # 8 load + 1 compute + 8 unload cycles per 8 samples
]


def fig_tradeoff():
    fig, axs = plt.subplots(1, 2, figsize=(13, 4.3))
    ax = axs[0]
    names = [d[0] for d in DESIGNS]
    area = [d[2] for d in DESIGNS]
    bars = ax.barh(names, area, color=[GREY, GREY, ACCENT, ACCENT2, GREEN])
    ax.set_xscale("log")
    ax.set_xlabel("standard-cell area (µm²), sky130hd, log scale")
    ax.set_title("after make pnr")
    for b, a, d in zip(bars, area, DESIGNS):
        ax.text(a * 1.1, b.get_y() + b.get_height() / 2, f"{a:,} µm²  ({d[1]:,} cells)", va="center", fontsize=9.5)
    ax.set_xlim(100, 1e6)
    ax.invert_yaxis()

    ax = axs[1]
    dsp = [d for d in DESIGNS if d[4]]
    for (name, cells, a, mhz, cps), col in zip(dsp, [ACCENT, ACCENT2, GREEN]):
        rate = mhz / cps
        eff = rate / (a / 1e6)
        ax.scatter(a / 1e6, rate, s=160, color=col, zorder=3)
        ax.annotate(f"{name}\n{rate:.1f} MS/s\n{eff:,.0f} MS/s per mm²", (a / 1e6, rate),
                    xytext=(8, -4), textcoords="offset points", fontsize=9.5)
    ax.set_xlabel("area (mm²)")
    ax.set_ylabel("samples per second (M)")
    ax.set_yscale("log")
    ax.set_xlim(0, 0.12)
    ax.set_ylim(1, 200)
    ax.set_title("throughput vs. area at the SDC clock")
    save(fig, "tradeoff.png")


def fig_power():
    fig, ax = plt.subplots(figsize=(11, 3.6))
    v = np.linspace(1.2, 1.95, 50)
    f = 100e6
    C = 20e-12
    alpha = 0.15
    pdyn = alpha * C * v ** 2 * f * 1e3
    ax.plot(v, pdyn, color=ACCENT, lw=2, label="dynamic: α·C·V²·f  (α = 0.15, C = 20 pF, f = 100 MHz)")
    ax.axvline(1.8, color=GREY, ls="--")
    ax.text(1.79, pdyn.max() * 0.75, "sky130 nominal 1.8 V", fontsize=10, color=GREY, ha="right")
    ax.set_xlabel("supply voltage (V)")
    ax.set_ylabel("power (mW)")
    ax.legend(fontsize=10, loc="upper left")
    ax.set_title("power scales with V²: lowering VDD is the strongest knob (but makes gates slower)")
    save(fig, "power.png")


def fig_pipeline():
    fig, ax = canvas(13, 3.6)
    box(ax, 0.2, 2.1, 0.7, 1.0, "FF", fs=10)
    box(ax, 1.3, 2.1, 4.0, 1.0, "logic: 12 ns", fc="#fff4e6", ec=ACCENT2, fs=11)
    box(ax, 5.7, 2.1, 0.7, 1.0, "FF", fs=10)
    ax.text(7.0, 2.6, "f_max ≈ 1 / 12 ns ≈ 83 MHz, latency 1", fontsize=11, va="center", color=RED)
    box(ax, 0.2, 0.4, 0.7, 1.0, "FF", fs=10)
    box(ax, 1.3, 0.4, 1.9, 1.0, "6 ns", fc="#fff4e6", ec=ACCENT2, fs=11)
    box(ax, 3.45, 0.4, 0.7, 1.0, "FF", fc=ACCENT, tc="white", fs=10)
    box(ax, 4.4, 0.4, 1.9, 1.0, "6 ns", fc="#fff4e6", ec=ACCENT2, fs=11)
    box(ax, 6.55, 0.4, 0.7, 1.0, "FF", fs=10)
    ax.text(7.6, 0.9, "pipelined: f_max ≈ 166 MHz, latency 2\n(+1 register stage of area)", fontsize=11, va="center",
            color=GREEN)
    for y in (2.6,):
        arrow(ax, 0.9, y, 1.3, y)
        arrow(ax, 5.3, y, 5.7, y)
    for x0, x1 in ((0.9, 1.3), (3.2, 3.45), (4.15, 4.4), (6.3, 6.55)):
        arrow(ax, x0, 0.9, x1, 0.9)
    save(fig, "pipeline.png")


# ---------------------------------------------------------------------------
# Module 8: project ideas
# ---------------------------------------------------------------------------
def fig_nco():
    fs = 1.0
    N = 16
    fcw = 1200
    acc = (np.arange(120) * fcw) % 2 ** N
    idx = acc >> (N - 8)
    sine = np.round(127 * np.sin(2 * np.pi * idx / 256))
    fig, axs = plt.subplots(2, 1, figsize=(12, 3.8), sharex=True)
    axs[0].step(np.arange(120), acc, where="post", color=ACCENT)
    axs[0].set_ylabel("phase acc")
    axs[0].set_title(f"NCO: phase += {fcw} each clock (16-bit) → f_out = {fcw}/65536 · f_clk; top 8 bits index a sine ROM")
    axs[1].step(np.arange(120), sine, where="post", color=ACCENT2)
    axs[1].set_ylabel("sine ROM out")
    axs[1].set_xlabel("clock cycle")
    save(fig, "nco.png")


# ---------------------------------------------------------------------------
# Module 10: Tiny Tapeout capstone (designs/tt_fir)
# ---------------------------------------------------------------------------
def fig_tt_pinout():
    fig, ax = canvas(13, 6.2)
    # The tile
    ax.add_patch(FancyBboxPatch((4.2, 0.6), 4.6, 5.0, boxstyle="round,pad=0.02,rounding_size=0.1",
                                fc="#f6f8fa", ec=GREY, lw=2))
    ax.text(6.5, 5.25, "tt_um_..._fir  (Tiny Tapeout tiles: 1x2)", ha="center", fontsize=11, color=GREY)
    box(ax, 4.5, 3.3, 1.3, 1.2, "2-FF sync\n+ edge", fs=10)
    box(ax, 6.5, 2.3, 1.9, 2.4, "fir.v\nW = 8\n16 taps\n1 MAC", fs=11, bold=True)
    box(ax, 4.5, 1.2, 1.3, 1.0, "TOGGLE\nflip-flop", fs=10)
    arrow(ax, 5.8, 3.9, 6.5, 3.9, color=ACCENT)
    ax.text(6.15, 3.75, "in_valid", ha="center", va="top", fontsize=8, color=ACCENT)
    arrow(ax, 6.5, 2.5, 5.8, 1.9, color=GREEN)
    # Inputs, left
    arrow(ax, 1.6, 3.9, 4.5, 3.9, color=ACCENT2, text="uio[0]  STROBE", tpos=0.35)
    arrow(ax, 1.6, 2.9, 6.5, 2.9, color=ACCENT2, text="ui[7:0]  X (Q1.7)", tpos=0.25)
    ax.text(1.4, 2.9, "sample\nin", ha="right", va="center", fontsize=10, color=ACCENT2)
    ax.text(1.4, 3.9, "load", ha="right", va="center", fontsize=10, color=ACCENT2)
    for y, t in ((5.0, "clk  (50 MHz)"), (4.55, "rst_n")):
        arrow(ax, 1.6, y, 4.2, y, color=GREY, text=t, tpos=0.45, fs=9)
    # Outputs, right
    arrow(ax, 8.4, 4.2, 11.6, 4.2, color=GREEN, text="uo[7:0]  Y (Q1.7)", tpos=0.6)
    arrow(ax, 8.4, 3.4, 11.6, 3.4, color=GREEN, text="uio[1]  READY", tpos=0.6)
    arrow(ax, 8.4, 2.6, 11.6, 2.6, color=GREEN, text="uio[2]  VALID", tpos=0.6)
    arrow(ax, 5.8, 1.5, 11.6, 1.5, color=GREEN, text="uio[3]  TOGGLE", tpos=0.78)
    ax.text(11.75, 4.2, "filtered\nout", ha="left", va="center", fontsize=10, color=GREEN)
    ax.text(6.5, 0.25, "uio[7:4] unused (inputs)   ·   uio_oe = 0000_1110", ha="center", fontsize=10, color=GREY)
    save(fig, "tt_pinout.png")


def fig_tt_handshake():
    # Cycle-accurate: these edges come from simulating designs/tt_fir
    # (STROBE raised just before clock 3, ready drops after 5, valid at 21).
    n = 26
    fig, ax = plt.subplots(figsize=(13, 3.8))
    ax.grid(False)
    rows = [
        ("clk", None),
        ("STROBE  uio[0]", [(3, 7)]),
        ("in_valid (inside)", [(4, 5)]),
        ("READY  uio[1]", [(0, 5), (21, n)]),
        ("VALID  uio[2]", [(21, 22)]),
        ("TOGGLE  uio[3]", [(22, n)]),
    ]
    for i, (name, highs) in enumerate(rows):
        y0 = (len(rows) - 1 - i) * 1.0
        ax.text(-0.5, y0 + 0.3, name, ha="right", va="center", fontsize=10)
        if highs is None:
            xs, ys = [], []
            for c in range(n):
                xs += [c, c, c + 0.5, c + 0.5]
                ys += [y0, y0 + 0.6, y0 + 0.6, y0]
            ax.plot(xs, ys, color=GREY, lw=1)
            continue
        xs, ys = [0], [y0]
        for a, b in highs:
            xs += [a, a, b, b]
            ys += [y0, y0 + 0.6, y0 + 0.6, y0]
        xs.append(n)
        ys.append(y0)
        col = ACCENT2 if "STROBE" in name else (ACCENT if "inside" in name else GREEN)
        ax.plot(xs, ys, color=col, lw=2)
    ax.axvspan(5, 21, color=SOFT, zorder=0)
    ax.text(13, 5.75, "busy: 16 multiply-accumulate cycles", ha="center", fontsize=10, color=ACCENT)
    ax.text(5.3, -0.55, "2 clocks to synchronise STROBE, 1 to load X, 16 to compute: Y is ready ~19 clocks after STROBE",
            fontsize=10, color=GREY)
    ax.set_xlim(-0.2, n)
    ax.set_ylim(-0.8, 6.1)
    ax.set_yticks([])
    ax.set_xticks(range(0, n, 2))
    ax.set_xlabel("clock cycle (20 ns each at 50 MHz)")
    for sp in ("left", "bottom"):
        ax.spines[sp].set_visible(False)
    save(fig, "tt_handshake.png")


def fig_tt_fit():
    # Numbers from `make synth-sky130` and `make pnr` in designs/tt_fir and designs/fir
    fig, axs = plt.subplots(1, 2, figsize=(13, 4.2))
    ax = axs[0]
    ff, mux = 25.02, 11.26          # dfrtp_1 and mux2_1 area in the sky130hd Liberty file
    parts = [("delay line\n128 flip-flops", 128 * ff),
             ("their load\nmuxes", 128 * mux),
             ("other flip-flops\n(acc, k, Y, sync)", 46 * ff),
             ("multiplier, tap select,\nadders, round, saturate", 12033 - 174 * ff - 128 * mux)]
    left = 0
    cols = [ACCENT, "#5fa8c0", ACCENT2, GREEN]
    for (name, a), c in zip(parts, cols):
        ax.barh([0], [a], left=left, color=c, ec="white", label=f"{name.replace(chr(10), ' ')}: {a:,.0f} µm²")
        ax.text(left + a / 2, 0, f"{100 * a / 12033:.0f}%", ha="center", va="center", fontsize=10, color="white")
        left += a
    ax.legend(loc="upper center", fontsize=9, frameon=False, ncol=1)
    ax.set_ylim(-0.6, 2.2)
    ax.set_yticks([])
    ax.set_xlabel("cell area (µm²), Yosys onto sky130 cells, 12,033 µm² in total")
    ax.set_title("where the 8-bit FIR's area goes")
    ax.grid(False)

    ax = axs[1]
    names = ["fir (16-bit), sized\nfor 40%: 253 × 253 µm", "tt_fir in 1x1\n161 × 112 µm", "tt_fir in 1x2\n161 × 226 µm"]
    util = [40, 85, 42]
    bars = ax.bar(names, util, color=[GREY, ACCENT2, GREEN])
    ax.axhline(60, color=RED, ls="--", lw=1)
    ax.text(2.45, 61.5, "Tiny Tapeout default\nplacement density 60%", ha="right", fontsize=9, color=RED)
    for b, u in zip(bars, util):
        ax.text(b.get_x() + b.get_width() / 2, u + 1.5, f"{u}%", ha="center", fontsize=11)
    ax.set_ylim(0, 100)
    ax.set_ylabel("core utilisation after P&R (%)")
    ax.set_title("all route: 0 DRC, timing met; 1x2 leaves headroom")
    save(fig, "tt_fit.png")


def main():
    for fn in (fig_flow, fig_counter_wave, fig_ff_timing, fig_pwm, fig_pwm_glitch, fig_pwm_block,
               fig_qformat, fig_rounding, fig_bitgrowth, fig_fir_response, fig_fir_arch, fig_fir_timeline,
               fig_iir_df1, fig_iir_pz, fig_iir_limit_cycle, fig_fft_butterfly, fig_twiddles, fig_fft_cost,
               fig_tradeoff, fig_power, fig_pipeline, fig_nco, fig_tt_pinout, fig_tt_handshake, fig_tt_fit):
        fn()


if __name__ == "__main__":
    main()
