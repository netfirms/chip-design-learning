#!/usr/bin/env python3
"""figures.py -- concept diagrams for the analog bridge deck and README.

    python3 analog/figures.py        # writes slides/images/analog_*.png

The simulation plots (DAC linearity, ADC transfer curve, the signal chain)
come from real ngspice and Icarus runs instead: `make -C analog plot`.
Needs numpy, matplotlib and Pillow.
"""
import os

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt  # noqa: E402
import numpy as np  # noqa: E402
from matplotlib.patches import FancyArrowPatch, FancyBboxPatch  # noqa: E402

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(HERE)
OUT = os.path.join(REPO, "slides", "images")
BLUE, ORANGE, GREY, GREEN, SOFT, RED = "#0f6e8c", "#e07a1f", "#5b6770", "#2e8b57", "#e3f1f5", "#c0392b"

plt.rcParams.update({
    "font.size": 12, "axes.spines.top": False, "axes.spines.right": False,
    "axes.grid": True, "grid.alpha": 0.3, "savefig.dpi": 150, "savefig.bbox": "tight",
})


def save(fig, name):
    os.makedirs(OUT, exist_ok=True)
    fig.savefig(os.path.join(OUT, name))
    plt.close(fig)
    print("wrote", os.path.relpath(os.path.join(OUT, name), REPO))


def box(ax, x, y, w, h, text, fc=SOFT, ec=BLUE, size=11):
    ax.add_patch(FancyBboxPatch((x, y), w, h, boxstyle="round,pad=0.02,rounding_size=0.08",
                                fc=fc, ec=ec, lw=1.6))
    ax.text(x + w / 2, y + h / 2, text, ha="center", va="center", fontsize=size)


def arrow(ax, x1, y1, x2, y2, color=GREY):
    ax.add_patch(FancyArrowPatch((x1, y1), (x2, y2), arrowstyle="-|>", mutation_scale=16,
                                 color=color, lw=1.6))


def bridge():
    """The real world, the bridge, and the digital chip in the middle."""
    from PIL import Image
    fig, ax = plt.subplots(figsize=(15, 5.2))
    ax.set(xlim=(0, 15), ylim=(0, 5.2))
    ax.axis("off")
    # analog zones and the digital zone
    ax.add_patch(FancyBboxPatch((0.1, 0.3), 4.6, 4.4, boxstyle="round,pad=0.02", fc="#fdf1e6",
                                ec="none"))
    ax.add_patch(FancyBboxPatch((10.3, 0.3), 4.6, 4.4, boxstyle="round,pad=0.02", fc="#fdf1e6",
                                ec="none"))
    ax.add_patch(FancyBboxPatch((4.9, 0.3), 5.2, 4.4, boxstyle="round,pad=0.02", fc="#eef6f9",
                                ec="none"))
    ax.text(2.4, 4.45, "analog: continuous time and value", ha="center", color=ORANGE, fontsize=11)
    ax.text(12.6, 4.45, "analog again", ha="center", color=ORANGE, fontsize=11)
    ax.text(7.5, 4.45, "digital: samples and numbers", ha="center", color=BLUE, fontsize=11)

    t = np.linspace(0, 1, 300)
    sig = 0.35 * np.sin(2 * np.pi * 2 * t) + 0.1 * np.sin(2 * np.pi * 15 * t)
    ax.plot(0.35 + 1.0 * t, 3.45 + 0.8 * sig, color=GREY)
    ax.text(0.85, 2.45, "sensor /\nmicrophone", ha="center", fontsize=10)
    box(ax, 1.65, 2.9, 1.25, 0.8, "anti-alias\nfilter", size=10)
    box(ax, 3.2, 2.9, 1.3, 0.8, "S&H + ADC\n8-bit flash", fc="#fde3cc", ec=ORANGE, size=10)
    arrow(ax, 1.4, 3.3, 1.65, 3.3)
    arrow(ax, 2.9, 3.3, 3.2, 3.3)
    arrow(ax, 4.5, 3.3, 5.25, 3.3, BLUE)

    img = Image.open(os.path.join(REPO, "docs", "images", "fir_iso_transistors.webp")).convert("RGB")
    ax.imshow(np.asarray(img), extent=(5.3, 9.7, 0.85, 4.15), zorder=1)
    ax.text(7.5, 0.5, "designs/fir: the 16-tap FIR chip (sky130)", ha="center", fontsize=10,
            color=BLUE)
    arrow(ax, 9.75, 3.3, 10.45, 3.3, BLUE)
    box(ax, 10.45, 2.9, 1.3, 0.8, "R-2R DAC\n8-bit", fc="#fde3cc", ec=ORANGE, size=10)
    box(ax, 12.05, 2.9, 1.4, 0.8, "reconstruction\nfilter", size=10)
    arrow(ax, 11.75, 3.3, 12.05, 3.3)
    arrow(ax, 13.45, 3.3, 13.7, 3.3)
    ax.plot(13.75 + 1.0 * t, 3.45 + 0.28 * np.sin(2 * np.pi * 2 * t - 0.6), color=GREY)
    ax.text(14.25, 2.45, "speaker /\nactuator", ha="center", fontsize=10)
    ax.text(2.4, 1.3, "ngspice + Xschem\nsch/adc_flash8.sch", ha="center", fontsize=10, color=GREY)
    ax.text(12.6, 1.3, "ngspice + Xschem\nsch/dac_r2r8.sch", ha="center", fontsize=10, color=GREY)
    save(fig, "analog_bridge.png")


def sampling():
    """Sampling in time, quantising in value, and what aliasing does."""
    fig, ax = plt.subplots(1, 2, figsize=(13, 3.9))
    t = np.linspace(0, 1, 1000)
    x = 0.42 * np.sin(2 * np.pi * t) + 0.5
    ts = np.arange(0, 1, 1 / 16)
    xs = 0.42 * np.sin(2 * np.pi * ts) + 0.5
    q = np.clip(np.floor(xs * 8 + 0.5), 0, 7) / 8
    ax[0].plot(t, x, color=GREY, label="analog input")
    ax[0].step(ts, q, where="post", color=BLUE, lw=2, label="3-bit codes, held")
    ax[0].plot(ts, xs, "o", color=ORANGE, ms=5, label="samples")
    ax[0].set_yticks(np.arange(9) / 8, [str(i) for i in range(8)] + [""])
    ax[0].set(title="sample in time, quantise in value", xlabel="time (periods)",
              ylabel="code")
    ax[0].legend(fontsize=9, loc="lower left")

    fs = 20.0
    t = np.linspace(0, 1, 2000)
    ts = np.arange(0, 1, 1 / fs)
    ax[1].plot(t, np.sin(2 * np.pi * 15 * t), color=GREY, lw=0.8, label="15 kHz input")
    ax[1].plot(t, np.sin(2 * np.pi * -5 * t), "--", color=RED, label="what the samples say: 5 kHz")
    ax[1].plot(ts, np.sin(2 * np.pi * 15 * ts), "o", color=ORANGE, ms=6, label="samples at 20 kS/s")
    ax[1].set(title="aliasing: above fs/2, a tone folds back", xlabel="time (ms)",
              ylim=(-1.4, 2.2))
    ax[1].legend(fontsize=9, loc="upper right", ncol=3)
    save(fig, "analog_sampling.png")


def r2r_weights():
    """Each bit adds VREF / 2^(8-i): binary weights from equal resistors."""
    fig, ax = plt.subplots(figsize=(8, 3.6))
    bits = np.arange(8)
    w = 1.8 / 2 ** (8 - bits)
    ax.bar([f"b{i}" for i in bits], w * 1e3, color=[BLUE] * 7 + [ORANGE])
    for i, v in enumerate(w):
        ax.text(i, v * 1e3 + 15, f"{v * 1e3:.1f}", ha="center", fontsize=9)
    ax.set(title="R-2R: bit i adds VREF / 2^(8-i) to the output",
           ylabel="mV", ylim=(0, 1000))
    save(fig, "analog_r2r_weights.png")


def architectures():
    """Why flash ADCs stop at about 8 bits: comparators vs conversion steps."""
    n = np.arange(1, 17)
    fig, ax = plt.subplots(figsize=(8.5, 3.9))
    ax.semilogy(n, 2 ** n - 1, "o-", color=ORANGE, label="flash: 2^N - 1 comparators, 1 step")
    ax.semilogy(n, n, "s-", color=BLUE, label="SAR: 1 comparator + DAC, N steps")
    ax.axvline(8, color=GREY, lw=0.8, ls="--")
    ax.text(8.2, 2e4, "this module: 8 bits\n255 comparators", fontsize=9, color=GREY)
    ax.set(title="cost of an N-bit ADC", xlabel="bits N", ylabel="comparators / steps")
    ax.legend(fontsize=9, loc="upper left")
    save(fig, "analog_adc_cost.png")


def snr():
    """Ideal quantisation SNR = 6.02 N + 1.76 dB for a full-scale sine."""
    n = np.arange(4, 17)
    fig, ax = plt.subplots(figsize=(8, 3.6))
    ax.plot(n, 6.02 * n + 1.76, "o-", color=BLUE)
    ax.plot([8], [6.02 * 8 + 1.76], "o", color=ORANGE, ms=10)
    ax.annotate("8 bits: 49.9 dB", (8, 49.9), xytext=(9, 38), color=ORANGE,
                arrowprops=dict(arrowstyle="->", color=ORANGE))
    ax.annotate("16 bits (fir.v's Q1.15): 98 dB", (16, 98.1), xytext=(10.2, 92), color=GREY,
                arrowprops=dict(arrowstyle="->", color=GREY))
    ax.set(title="ideal SNR of an N-bit converter", xlabel="bits N", ylabel="SNR (dB)")
    save(fig, "analog_snr.png")


if __name__ == "__main__":
    bridge()
    sampling()
    r2r_weights()
    architectures()
    snr()
