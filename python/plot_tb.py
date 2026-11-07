#!/usr/bin/env python3
"""plot_tb.py -- plot a testbench output CSV next to it as a PNG.

    python3 python/plot_tb.py designs/fir/build/fir_out.csv
    (or `make plot` in a design directory)

Understands the CSVs written by the testbenches:
  pwm_out.csv   pwm, rc_filtered_x1000      -> PWM bits and the "RC-filtered" level
  fir/iir       n, x, y, phase              -> waveforms and measured |H(f)|
  fft8_out.csv  frame, k, ..., X_re, X_im   -> hardware FFT vs. exact DFT per frame

Needs numpy and matplotlib (pip install numpy matplotlib).
"""
import os
import sys

import numpy as np

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt  # noqa: E402

Q15 = 32768.0


def load(path):
    with open(path) as f:
        header = f.readline().strip().split(",")
    data = np.loadtxt(path, delimiter=",", skiprows=1, ndmin=2)
    return header, data


def plot_pwm(data, ax):
    n = np.arange(len(data))
    ax[0].step(n, data[:, 0], where="post", lw=0.6)
    ax[0].set_title("PWM output (bits)")
    ax[0].set_ylim(-0.2, 1.2)
    ax[1].plot(n, data[:, 1] / 1000.0)
    ax[1].set_title("after an RC low-pass: average = duty / 2^WIDTH")
    ax[1].set_xlabel("clock cycle")
    ax[1].set_ylabel("V / VDD")


def plot_filter(data, ax):
    n, x, y = data[:, 0], data[:, 1] / Q15, data[:, 2] / Q15
    phase = data[:, 3]
    ax[0].plot(n, x, lw=0.6, label="x (input)")
    ax[0].plot(n, y, lw=0.8, label="y (output)")
    ax[0].set_title("time domain: step/impulse, random, then sine tests")
    ax[0].set_xlabel("sample")
    ax[0].legend()
    # Random (white) input excites every frequency equally, so the ratio of
    # output to input spectra estimates the filter's frequency response.
    xr, yr = x[phase == 2], y[phase == 2]
    seg = 64
    nseg = len(xr) // seg
    win = np.hanning(seg)
    Sxx = np.zeros(seg // 2 + 1)
    Sxy = np.zeros(seg // 2 + 1, dtype=complex)
    for i in range(nseg):
        X = np.fft.rfft(xr[i * seg:(i + 1) * seg] * win)
        Y = np.fft.rfft(yr[i * seg:(i + 1) * seg] * win)
        Sxx += np.abs(X) ** 2
        Sxy += np.conj(X) * Y
    f = np.fft.rfftfreq(seg)
    H = np.abs(Sxy) / np.maximum(Sxx, 1e-12)
    ax[1].plot(f, 20 * np.log10(H + 1e-9), "o-", ms=3)
    ax[1].set_title("|H(f)| measured from the random-input test")
    ax[1].set_xlabel("frequency / fs")
    ax[1].set_ylabel("dB")
    ax[1].set_ylim(-80, 5)


def plot_fft(data, ax):
    frames = np.unique(data[:, 0]).astype(int)
    show = frames[:4]
    for fr in show:
        rows = data[data[:, 0] == fr]
        rows = rows[np.argsort(rows[:, 1])]
        mag_hw = np.hypot(rows[:, 4], rows[:, 5])
        mag_ref = np.hypot(rows[:, 6], rows[:, 7])
        ax[0].plot(rows[:, 1], mag_hw, "o-", label=f"frame {fr} (hw)")
        ax[0].plot(rows[:, 1], mag_ref, "kx", ms=4)
    ax[0].set_title("|X[k]|: hardware (o) vs. exact DFT/8 (x)")
    ax[0].set_xlabel("bin k")
    ax[0].legend(fontsize=7)
    err = np.concatenate([data[:, 4] - data[:, 6], data[:, 5] - data[:, 7]])
    ax[1].hist(err, bins=np.arange(-4, 4.5, 0.5))
    ax[1].set_title("fixed-point error (LSB), all frames")
    ax[1].set_xlabel("hardware - exact")


def main():
    if len(sys.argv) != 2:
        sys.exit(__doc__)
    path = sys.argv[1]
    header, data = load(path)
    fig, ax = plt.subplots(1, 2, figsize=(12, 4))
    if header[0] == "pwm":
        plot_pwm(data, ax)
    elif header[:4] == ["n", "x", "y", "phase"]:
        plot_filter(data, ax)
    elif header[0] == "frame":
        plot_fft(data, ax)
    else:
        sys.exit(f"don't know how to plot columns {header}")
    for a in ax:
        a.grid(True, alpha=0.3)
    fig.suptitle(os.path.basename(path))
    fig.tight_layout()
    out = os.path.splitext(path)[0] + ".png"
    fig.savefig(out, dpi=110)
    print(f"Wrote {out}")


if __name__ == "__main__":
    main()
