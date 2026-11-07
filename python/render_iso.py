#!/usr/bin/env python3
"""render_iso.py -- simple isometric picture of the counter chip and its pins.

Not a layout render (python/render_3d.py does that from the routed GDS):
this is a block-level drawing for the README that shows what goes in and
out of the chip, with the parts inside it that synthesis creates.

    python3 python/render_iso.py                    # docs/images/counter_iso.png
    python3 python/render_iso.py -o my.png

Needs matplotlib.
"""
import argparse
import math
import os

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt  # noqa: E402
from matplotlib.patches import Polygon, FancyArrowPatch  # noqa: E402

C30, S30 = math.cos(math.radians(30)), math.sin(math.radians(30))

INPUT_COL = "#e07a1f"
OUTPUT_COL = "#2e8b57"
INK = "#e6edf3"
MUTED = "#8b949e"


def P(x, y, z):
    """Isometric projection: x runs right-down, y runs left-down, z up."""
    return ((x - y) * C30, -(x + y) * S30 + z)


def shade(hex_col, f):
    h = hex_col.lstrip("#")
    r, g, b = (int(h[i:i + 2], 16) for i in (0, 2, 4))
    return "#%02x%02x%02x" % tuple(max(0, min(255, int(c * f))) for c in (r, g, b))


def cuboid(ax, x0, y0, z0, dx, dy, dz, col, ec=None, lw=0.6, zorder=1):
    """Draw the three visible faces of a box: top, +x side, +y side."""
    x1, y1, z1 = x0 + dx, y0 + dy, z0 + dz
    ec = ec or shade(col, 0.6)
    top = [P(x0, y0, z1), P(x1, y0, z1), P(x1, y1, z1), P(x0, y1, z1)]
    side_x = [P(x1, y0, z0), P(x1, y1, z0), P(x1, y1, z1), P(x1, y0, z1)]
    side_y = [P(x0, y1, z0), P(x1, y1, z0), P(x1, y1, z1), P(x0, y1, z1)]
    for pts, f in ((side_x, 0.72), (side_y, 0.86), (top, 1.0)):
        ax.add_patch(Polygon(pts, closed=True, fc=shade(col, f), ec=ec, lw=lw, zorder=zorder))


def text_on_top(ax, x, y, z, s, size, col, weight="normal", zorder=20):
    """Text lying on the top face, along the x axis."""
    px, py = P(x, y, z)
    ax.text(px, py, s, fontsize=size, color=col, ha="center", va="center", fontweight=weight,
            rotation=-30, rotation_mode="anchor", zorder=zorder)


def render(out):
    fig, ax = plt.subplots(figsize=(13, 8.2))
    fig.patch.set_facecolor("#0d1117")
    ax.set_facecolor("#0d1117")
    ax.set_aspect("equal")
    ax.axis("off")

    D = 60.0   # die size in um, as in designs/counter/orfs/config.mk
    # Substrate / package slab and the die
    cuboid(ax, -14, -14, -6, D + 28, D + 28, 4, "#30363d", zorder=1)
    cuboid(ax, 0, 0, -2, D, D, 6, "#1f6f8b", zorder=2)

    # Inside the die: 8 flip-flops (dfrtp) in a row, incrementer + AND logic, clock buffer
    for i in range(8):
        cuboid(ax, 6 + i * 6.2, 34, 4, 5, 12, 3.2, "#7c4dff", lw=0.5, zorder=5)
    text_on_top(ax, 30.8, 50, 4, "8 × D flip-flop (dfrtp_1) = count[7:0]", 9, INK)
    cuboid(ax, 6, 16, 4, 34, 11, 2.2, "#c9733a", lw=0.5, zorder=5)
    text_on_top(ax, 23, 21.5, 6.2, "+1 incrementer", 9, "#1d2328", "bold")
    cuboid(ax, 44, 16, 4, 11, 11, 2.2, "#3fa36b", lw=0.5, zorder=5)
    text_on_top(ax, 49.5, 21.5, 6.2, "&count", 8.5, "#1d2328", "bold")
    cuboid(ax, 6, 6, 4, 8, 6, 4.2, "#d4b84a", lw=0.5, zorder=5)
    text_on_top(ax, 24, 9, 4, "clock buffer", 8.5, INK)

    # Title on the die
    text_on_top(ax, 30, 56.5, 4, "counter  ·  60 × 60 µm  ·  sky130", 11, INK, "bold")

    # Pins. Inputs on the left-front edge (y = D), outputs on the right-front edge (x = D).
    inputs = [("clk", 12), ("rst_n", 30), ("en", 48)]
    for name, x in inputs:
        cuboid(ax, x - 1.6, D, -2, 3.2, 11, 2.4, INPUT_COL, zorder=8)
        tip = P(x, D + 26, 0)
        base = P(x, D + 12, 0)
        ax.add_patch(FancyArrowPatch(tip, base, arrowstyle="-|>", mutation_scale=16, color=INPUT_COL, lw=2,
                                     zorder=9))
        lx, ly = P(x, D + 29, 0)
        ax.text(lx, ly, name, color=INPUT_COL, fontsize=13, ha="right", va="top", fontweight="bold",
                family="monospace", zorder=10)

    outputs = [(f"count[{i}]", 4 + i * 6.0) for i in range(8)] + [("wrap", 55)]
    for name, y in outputs:
        cuboid(ax, D, y - 1.2, -2, 11, 2.4, 2.4, OUTPUT_COL, zorder=8)
        base = P(D + 12, y, 0)
        tip = P(D + 24, y, 0)
        ax.add_patch(FancyArrowPatch(base, tip, arrowstyle="-|>", mutation_scale=12, color=OUTPUT_COL, lw=1.6,
                                     zorder=9))
        lx, ly = P(D + 26, y, 0)
        ax.text(lx, ly, name, color=OUTPUT_COL, fontsize=10, ha="left", va="center", family="monospace",
                fontweight="bold" if name == "wrap" else "normal", zorder=10)

    # Legend / caption
    ax.text(0.02, 0.97, "The counter chip: what goes in, what comes out", transform=ax.transAxes,
            color=INK, fontsize=16, fontweight="bold", va="top")
    ax.text(0.02, 0.92, "Hardware is the new Software", transform=ax.transAxes, color="#58a6ff",
            fontsize=12, va="top")
    ax.text(0.02, 0.06, "■ inputs: clk (100 MHz clock), rst_n (async reset, active low), en (count enable)",
            transform=ax.transAxes, color=INPUT_COL, fontsize=10.5)
    ax.text(0.02, 0.025, "■ outputs: count[7:0] (current value), wrap (high when the next edge rolls over to 0)",
            transform=ax.transAxes, color=OUTPUT_COL, fontsize=10.5)
    ax.text(0.98, 0.025, "simplified drawing, not to scale · python/render_iso.py", transform=ax.transAxes,
            color=MUTED, fontsize=8.5, ha="right")

    ax.autoscale_view()
    xs, ys = zip(*[P(x, y, z) for x in (-30, D + 40) for y in (-14, D + 40) for z in (-6, 10)])
    ax.set_xlim(min(xs) - 6, max(xs) + 14)
    ax.set_ylim(min(ys) - 2, max(ys) + 10)
    os.makedirs(os.path.dirname(os.path.abspath(out)), exist_ok=True)
    fig.savefig(out, dpi=150, bbox_inches="tight", facecolor=fig.get_facecolor())
    print("Wrote", out)


def main():
    here = os.path.dirname(os.path.abspath(__file__))
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("-o", "--out", default=os.path.join(here, "..", "docs", "images", "counter_iso.png"))
    render(ap.parse_args().out)


if __name__ == "__main__":
    main()
