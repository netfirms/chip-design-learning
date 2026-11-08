#!/usr/bin/env python3
"""figures_aes.py -- diagrams and plots for the encryption chip deck (Module 11).

    python3 slides/figures_aes.py     # writes slides/images/aes_*.png

Uses the drawing helpers and colours of figures.py and the AES model in
python/aes_model.py. The wire bytes and the avalanche plot are computed by
the model; the area split is from `make synth-sky130` in designs/aes.
"""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
sys.path.insert(0, os.path.join(HERE, "..", "python"))
import aes_model  # noqa: E402
from figures import (ACCENT, ACCENT2, GREEN, GREY, RED, SOFT, arrow, box,  # noqa: E402
                     canvas, op, plt, save)

WARM = "#fff4e6"
MINT = "#e8f5ee"
PINK = "#fdecea"

KEY = 0x436869702D636F757273652D6B657921      # "Chip-course-key!"
IV = 0x6C696E6B2D6E6F6E63652D0000000000       # "link-nonce-" + a 32-bit counter
MSG = b"Meet me in the lab at 9. Hardware is the new Software. Bring GDS"


def fig_link():
    """Alice -> wire -> Bob, with Eve listening on the wire."""
    wire = aes_model.ctr(KEY, IV, MSG)
    eve = aes_model.ctr(KEY ^ 1, IV, wire)
    fig, ax = canvas(14, 5.4)

    ax.text(1.4, 4.95, "Alice", ha="center", fontsize=13, fontweight="bold", color=ACCENT)
    box(ax, 0.2, 3.3, 2.4, 1.3, "aes_ctr chip\nkey K, counter N", fc=ACCENT, fs=12, bold=True, tc="white")
    ax.text(1.4, 2.0, '"Meet me in the\nlab at 9. ..."', ha="center", fontsize=10.5,
            family="monospace", color="#1d2328")
    arrow(ax, 1.4, 2.45, 1.4, 3.25, color=ACCENT)

    ax.text(12.6, 4.95, "Bob", ha="center", fontsize=13, fontweight="bold", color=GREEN)
    box(ax, 11.4, 3.3, 2.4, 1.3, "aes_ctr chip\nthe same K and N", fc=GREEN, ec=GREEN, fs=12, bold=True,
        tc="white")
    ax.text(12.6, 2.0, '"Meet me in the\nlab at 9. ..."', ha="center", fontsize=10.5,
            family="monospace", color="#1d2328")
    arrow(ax, 12.6, 3.25, 12.6, 2.45, color=GREEN)

    # The wire
    arrow(ax, 2.65, 3.95, 11.35, 3.95, color=GREY, lw=2.2)
    hexs = " ".join(f"{b:02x}" for b in wire[:12]) + " ..."
    ax.text(7.1, 4.15, hexs, ha="center", va="bottom", fontsize=11, family="monospace", color="#1d2328")
    ax.text(7.1, 4.7, "the wire (radio, cable, internet): anyone can listen", ha="center",
            fontsize=10.5, color=GREY, style="italic")

    # Eve
    ax.plot([7.1, 7.1], [3.95, 2.5], color=RED, lw=1.5, ls="--")
    box(ax, 5.4, 1.4, 3.4, 1.05, "Eve's chip\nkey K with 1 bit wrong", fc=PINK, ec=RED, fs=10.5)
    seen = "".join(chr(b) if 32 <= b < 127 else "." for b in eve[:22])
    ax.text(7.1, 1.0, f'"{seen}..."', ha="center", va="top", fontsize=10.5, family="monospace", color=RED)
    ax.text(7.1, 0.35, "without the exact key: noise", ha="center", fontsize=10, color=RED)
    save(fig, "aes_link.png")


def fig_ctr():
    """Counter mode: AES makes a keystream, XOR mixes it with the data."""
    fig, ax = canvas(14, 4.4)
    for i, x in enumerate((0.3, 4.9, 9.5)):
        box(ax, x, 3.0, 2.6, 0.75, f"counter N+{i}" if i else "counter N", fc=WARM, ec=ACCENT2, fs=11)
        arrow(ax, x + 1.3, 2.98, x + 1.3, 2.62, color=GREY)
        box(ax, x, 1.85, 2.6, 0.75, "AES-128 (key K)", fc=ACCENT, fs=11, bold=True, tc="white")
        arrow(ax, x + 1.3, 1.83, x + 1.3, 1.25, color=GREY, text="16 keystream bytes",
              tpos=0.5, toff=(1.05, -0.14), fs=9)
        op(ax, x + 1.3, 1.02, "⊕")
        ax.text(x + 0.7, 1.02, f"plain block {i}", ha="right", va="center", fontsize=9.5, color=GREY)
        arrow(ax, x + 0.76, 1.02, x + 1.07, 1.02, color=GREY)
        arrow(ax, x + 1.3, 0.79, x + 1.3, 0.35, color=GREY)
        ax.text(x + 1.3, 0.25, f"wire block {i}", ha="center", va="top", fontsize=10, color="#1d2328")
    ax.text(7.0, 4.15, "Counter (CTR) mode: encrypting and decrypting are the same XOR",
            ha="center", fontsize=12.5, color=ACCENT, fontweight="bold")
    save(fig, "aes_ctr_mode.png")


def fig_round():
    """One round of the iterative core, next to the key expansion."""
    fig, ax = canvas(14, 5.0)
    # Data path, left to right
    box(ax, 0.2, 2.6, 1.6, 1.2, "state\n128 FFs", fc=ACCENT2, ec=ACCENT2, fs=11.5, bold=True, tc="white")
    steps = [("SubBytes\n16 S-boxes", WARM), ("ShiftRows\nwires only", SOFT),
             ("MixColumns\nXORs, x2 in GF(2⁸)", SOFT)]
    x = 2.4
    arrow(ax, 1.82, 3.2, x - 0.02, 3.2, color=GREY)
    for name, fc in steps:
        box(ax, x, 2.6, 2.1, 1.2, name, fc=fc, ec=ACCENT2 if fc == WARM else ACCENT, fs=11)
        arrow(ax, x + 2.12, 3.2, x + 2.48, 3.2, color=GREY)
        x += 2.5
    ax.text(8.65, 2.35, "skipped in round 10", ha="center", va="top", fontsize=9.5, color=GREY, style="italic")
    op(ax, x + 0.25, 3.2, "⊕")
    ax.text(x + 0.25, 3.65, "AddRoundKey", ha="center", fontsize=9.5, color=ACCENT)
    # feedback to the state register
    ax.plot([x + 0.47, x + 0.9, x + 0.9], [3.2, 3.2, 4.4], color=GREY, lw=1.5)
    ax.plot([x + 0.9, 1.0], [4.4, 4.4], color=GREY, lw=1.5)
    arrow(ax, 1.0, 4.4, 1.0, 3.82, color=GREY)
    ax.text(5.7, 4.5, "back into the state register: 10 clocks, one round each", ha="center",
            va="bottom", fontsize=10.5, color=GREY)

    # Key path underneath
    box(ax, 0.2, 0.4, 1.6, 1.2, "round key\n128 FFs", fc=ACCENT2, ec=ACCENT2, fs=11.5, bold=True, tc="white")
    arrow(ax, 1.82, 1.0, 2.38, 1.0, color=GREY)
    box(ax, 2.4, 0.4, 2.1, 1.2, "RotWord +\n4 S-boxes", fc=WARM, ec=ACCENT2, fs=11)
    arrow(ax, 4.52, 1.0, 4.88, 1.0, color=GREY)
    box(ax, 4.9, 0.4, 2.1, 1.2, "⊕ rcon\n01 02 04 ... 36", fc=SOFT, fs=11)
    arrow(ax, 7.02, 1.0, 7.38, 1.0, color=GREY)
    box(ax, 7.4, 0.4, 2.6, 1.2, "XOR chain\nw0' w1' w2' w3'", fc=SOFT, fs=11)
    ax.plot([10.02, x + 0.25], [1.0, 1.0], color=GREY, lw=1.5)
    arrow(ax, x + 0.25, 1.0, x + 0.25, 2.97, color=GREY, text="next round key", tpos=0.45,
          toff=(0.85, 0), fs=9.5)
    ax.plot([10.4, 10.4, 1.0], [1.0, 0.15, 0.15], color=GREY, lw=1.2, ls=":")
    arrow(ax, 1.0, 0.15, 1.0, 0.38, color=GREY, lw=1.2)
    save(fig, "aes_round.png")


def fig_avalanche():
    """Flip one plaintext bit: how many of the 128 state bits differ after each round."""
    import random
    random.seed(11)
    fig, ax = plt.subplots(figsize=(12, 4.2))
    rounds = list(range(11))
    curves = []
    for _ in range(40):
        k, p = random.getrandbits(128), random.getrandbits(128)
        bit = 1 << random.randrange(128)
        a, b = aes_model.encrypt_rounds(k, p), aes_model.encrypt_rounds(k, p ^ bit)
        d = [bin(x ^ y).count("1") for x, y in zip(a, b)]
        curves.append(d)
        ax.plot(rounds, d, color=ACCENT, alpha=0.12, lw=1)
    mean = [sum(c[r] for c in curves) / len(curves) for r in rounds]
    ax.plot(rounds, mean, color=ACCENT2, lw=3, marker="o", label="average of 40 tries")
    ax.axhline(64, color=GREY, ls="--", lw=1.2)
    ax.text(10.1, 66, "64 = half the bits: as different as two random blocks", ha="right",
            fontsize=10, color=GREY)
    ax.set_xticks(rounds)
    ax.set_xlabel("after round (0 = the first AddRoundKey)")
    ax.set_ylabel("bits that differ (of 128)")
    ax.set_ylim(0, 100)
    ax.set_title("The avalanche: flip 1 bit of the plaintext and half the state has changed by round 2")
    ax.legend(loc="lower right")
    save(fig, "aes_avalanche.png")


def fig_timing():
    """Byte stream and keystream refill: 16 bytes, then the core makes the next block."""
    fig, ax = canvas(14, 3.8)
    x0, dx = 1.9, 0.27
    sigs = [("clk", 3.3), ("core busy", 2.6), ("in_ready", 1.9), ("in_valid · bytes", 1.2), ("out_valid", 0.5)]
    for name, y in sigs:
        ax.text(x0 - 0.15, y + 0.15, name, ha="right", va="center", fontsize=10.5, family="monospace")
    n = 44
    for i in range(n):  # clock
        x = x0 + i * dx
        ax.plot([x, x, x + dx / 2, x + dx / 2, x + dx], [3.3, 3.6, 3.6, 3.3, 3.3], color=GREY, lw=1)

    def level(y, pattern, color):
        xs, ys = [], []
        for i, v in enumerate(pattern):
            xs += [x0 + i * dx, x0 + (i + 1) * dx]
            ys += [y + 0.3 * v] * 2
        ax.plot(xs, ys, color=color, lw=1.8)

    # 12 clocks of refill, 16 bytes, 12 clocks refill, 4 bytes
    busy = [0] + [1] * 10 + [0] * 18 + [1] * 10 + [0] * 5
    ready = [0] * 12 + [1] * 16 + [0] * 12 + [1] * 4
    outv = [0] * 13 + [1] * 16 + [0] * 12 + [1] * 3
    level(2.6, busy, ACCENT2)
    level(1.9, ready, GREEN)
    level(0.5, outv, ACCENT)
    for i in range(n):
        if ready[i]:
            ax.add_patch(plt.Rectangle((x0 + i * dx + 0.02, 1.2), dx - 0.04, 0.3, fc=SOFT, ec=ACCENT, lw=0.8))
    ax.text(x0 + 6 * dx, 2.95, "10 rounds", ha="center", fontsize=9.5, color=ACCENT2)
    ax.text(x0 + 20 * dx, 1.62, "16 bytes, one per clock", ha="center", fontsize=9.5, color=GREEN)
    ax.text(x0 + 34 * dx, 2.95, "next keystream block", ha="center", fontsize=9.5, color=ACCENT2)
    save(fig, "aes_timing.png")


def fig_area():
    """Where the 85,119 um^2 of cells go (make synth-sky130). The S-box share
    is one aes_sbox synthesised alone (2,487 um^2, 380 cells) times 20."""
    parts = [("20 S-boxes\n(16 for the state, 4 for the key)", 49748, ACCENT2),
             ("668 flip-flops\n5 registers of 128 bits", 16717, "#7fb4c6"),
             ("MixColumns, AddRoundKey,\nkey XORs, muxes, control", 18654, ACCENT)]
    fig, ax = plt.subplots(figsize=(12, 2.6))
    left, total = 0, sum(p[1] for p in parts)
    for name, a, c in parts:
        ax.barh(0, a, left=left, color=c, edgecolor="white", height=0.6)
        ax.text(left + a / 2, 0, "%d%%" % round(100 * a / total), ha="center", va="center",
                color="white", fontsize=13, fontweight="bold")
        ax.text(left + a / 2, -0.48, name, ha="center", va="top", fontsize=9.5)
        left += a
    ax.set_xlim(-total * 0.01, total * 1.04)
    ax.set_ylim(-1.0, 0.45)
    ax.axis("off")
    ax.set_title("aes_ctr in sky130: 11,095 cells, 85,119 µm² of cell area", fontsize=13)
    save(fig, "aes_area.png")


def main():
    for fn in (fig_link, fig_ctr, fig_round, fig_avalanche, fig_timing, fig_area):
        fn()


if __name__ == "__main__":
    main()
