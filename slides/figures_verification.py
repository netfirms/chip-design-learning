#!/usr/bin/env python3
"""figures_verification.py -- figures for the verification deck (slides/09-verification.md).

    python3 slides/figures_verification.py      # writes slides/images/verif_*.png

Uses the drawing helpers and colours of figures.py, and the filter design in
python/dsp_coeffs.py, so the numbers match the RTL and the cocotb tests.
"""
import os
import sys

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
sys.path.insert(0, os.path.join(HERE, "..", "python"))

import dsp_coeffs  # noqa: E402
from figures import ACCENT, ACCENT2, GREEN, GREY, RED, arrow, box, canvas, plt, save  # noqa: E402


def fig_tb_layers():
    """Driver, DUT, monitor, model and scoreboard: the shape of every cocotb test here."""
    fig, ax = canvas(13, 5.2)
    box(ax, 0.3, 3.3, 2.6, 1.2, "test\n(stimulus: random,\ncorner cases, sines)", fc="#fff4e6", ec=ACCENT2, fs=10)
    box(ax, 4.0, 3.3, 2.0, 1.2, "driver\nvalid / ready", fs=11, bold=True)
    box(ax, 7.1, 3.0, 2.4, 1.8, "DUT\nfir.v\n(Icarus)", fc="#ffffff", ec=ACCENT, fs=12, bold=True)
    box(ax, 10.4, 3.3, 2.3, 1.2, "monitor\nout_valid → sample", fs=11, bold=True)
    box(ax, 4.0, 0.5, 2.0, 1.2, "model\ndsp_coeffs.py", fs=11, bold=True)
    box(ax, 7.1, 0.5, 2.4, 1.2, "expected\nqueue", fs=11)
    box(ax, 10.4, 0.5, 2.3, 1.2, "scoreboard\ngot == expected ?", fc="#e8f6ee", ec=GREEN, fs=11, bold=True)
    arrow(ax, 2.9, 3.9, 4.0, 3.9, text="samples")
    arrow(ax, 6.0, 3.9, 7.1, 3.9, text="pins")
    arrow(ax, 9.5, 3.9, 10.4, 3.9, text="pins")
    arrow(ax, 1.6, 3.3, 1.6, 1.1, color=GREY)
    arrow(ax, 1.6, 1.1, 4.0, 1.1, text="same samples")
    arrow(ax, 6.0, 1.1, 7.1, 1.1)
    arrow(ax, 9.5, 1.1, 10.4, 1.1)
    arrow(ax, 11.55, 3.3, 11.55, 1.7, color=GREY, text="actual", tpos=0.5, toff=(0.45, -0.1))
    ax.text(8.3, 2.55, "Verilog (simulator)", ha="center", fontsize=9.5, color=GREY)
    ax.text(6.5, 0.05, "Python: everything except the DUT box", ha="center", fontsize=10, color=ACCENT)
    save(fig, "verif_tb_layers.png")


def biquad_fixed(x):
    """Bit-exact model of designs/iir (same as cocotb/test_iir.py)."""
    frac = dsp_coeffs.IIR_FRAC
    b, a = dsp_coeffs.design_biquad_lowpass()
    B = np.round(b * 2**frac).astype(int)
    A = np.round(a * 2**frac).astype(int)
    x1 = x2 = y1 = y2 = 0
    out = []
    for v in x:
        acc = int(B[0] * v + B[1] * x1 + B[2] * x2 - A[1] * y1 - A[2] * y2)
        y = max(-32768, min(32767, (acc + (1 << (frac - 1))) >> frac))
        x2, x1, y2, y1 = x1, v, y1, y
        out.append(y)
    return np.array(out)


def biquad_float(x):
    b, a = dsp_coeffs.design_biquad_lowpass()
    y = np.zeros(len(x))
    for n in range(len(x)):
        y[n] = (b[0] * x[n] + b[1] * (x[n - 1] if n else 0) + b[2] * (x[n - 2] if n > 1 else 0)
                - a[1] * (y[n - 1] if n else 0) - a[2] * (y[n - 2] if n > 1 else 0))
    return y


def fig_deadband():
    """What test_overload_recovers found: the biquad gets stuck at +6 LSB."""
    x = ([32767] * 40 + [-32768] * 40) * 4 + [0] * 400
    yq = biquad_fixed(x)
    yf = biquad_float(np.array(x, dtype=float))
    n = np.arange(len(x))
    fig, axs = plt.subplots(1, 2, figsize=(14, 3.8))
    ax = axs[0]
    ax.plot(n, np.array(x) / 32768, color=GREY, lw=1, alpha=0.5, label="input")
    ax.plot(n, yq / 32768, color=ACCENT, lw=1.6, label="hardware (bit-exact model)")
    ax.set_title("full-scale square wave, then silence")
    ax.set_xlabel("sample")
    ax.legend(fontsize=9, loc="upper right")
    ax = axs[1]
    t = n >= 340
    ax.plot(n[t], yf[t], color=GREY, lw=1.4, ls="--", label="floating point: decays to 0")
    ax.step(n[t], yq[t], color=RED, lw=1.8, where="post", label="Q2.14 hardware: stuck at +6 LSB")
    ax.axhspan(-6, 6, color=ACCENT2, alpha=0.12, label="dead band ±6 LSB")
    ax.set_ylim(-20, 40)
    ax.set_title("zoom: after the input stops (in LSBs)")
    ax.set_xlabel("sample")
    ax.legend(fontsize=9, loc="upper right")
    fig.tight_layout()
    save(fig, "verif_deadband.png")


def fig_mutation():
    """Bugs injected on purpose, and how many tests caught each one."""
    rows = [  # (design: bug, tests failed, tests total), measured with make cocotb
        ("counter: wrap ignores en", 1, 3),
        ("pwm: no double buffer on duty", 1, 7),
        ("fir: one coefficient off by 1", 4, 4),
        ("fir: wrap instead of saturate", 4, 4),
        ("iir: truncate instead of round", 4, 4),
        ("fft: twiddle constant 0.3 % low", 2, 3),
    ]
    fig, ax = plt.subplots(figsize=(12, 3.6))
    y = np.arange(len(rows))[::-1]
    ax.barh(y, [r[2] for r in rows], color="#e9ecef", height=0.6, label="tests run")
    ax.barh(y, [r[1] for r in rows], color=RED, height=0.6, label="tests that failed (bug caught)")
    ax.set_yticks(y, [r[0] for r in rows])
    ax.set_xlabel("tests")
    ax.set_title("mutation check: break the RTL on purpose, the testbench must notice")
    ax.legend(fontsize=9, loc="lower right")
    ax.grid(axis="y", visible=False)
    save(fig, "verif_mutation.png")


def main():
    for fn in (fig_tb_layers, fig_deadband, fig_mutation):
        fn()


if __name__ == "__main__":
    main()
