#!/usr/bin/env python3
"""dsp_coeffs.py -- design the FIR and IIR filters used in designs/fir and designs/iir.

This is the "algorithm" half of the DSP-to-hardware workflow:

  1. design the filter in floating point (here, with numpy only),
  2. quantise the coefficients to fixed point,
  3. check how much the quantisation changed the frequency response,
  4. paste the integer coefficients into the Verilog.

Run:  python3 python/dsp_coeffs.py            # print coefficients + response
      python3 python/dsp_coeffs.py --plot     # also save build/filters.png

Only numpy is required (matplotlib for --plot). Frequencies are normalised
to the sample rate: 0.5 is Nyquist.
"""
import argparse
import os

import numpy as np

# ---------------------------------------------------------------------------
# FIR: 16-tap windowed-sinc low-pass, coefficients in Q1.15
# ---------------------------------------------------------------------------
FIR_TAPS = 16
FIR_CUTOFF = 0.1     # -6 dB point, fraction of fs
FIR_FRAC = 15        # Q1.15


def design_fir(taps=FIR_TAPS, fc=FIR_CUTOFF):
    """Windowed-sinc low-pass (what scipy.signal.firwin does by default)."""
    n = np.arange(taps) - (taps - 1) / 2
    h = 2 * fc * np.sinc(2 * fc * n) * np.hamming(taps)
    return h / h.sum()                    # unity gain at DC


def quantise_fir(h, frac=FIR_FRAC):
    q = np.round(h * 2**frac).astype(int)
    # Nudge the centre taps so the integer coefficients still sum to exactly
    # 2^frac (DC gain of exactly 1.0), keeping the filter symmetric.
    err = 2**frac - q.sum()
    mid = len(q) // 2
    q[mid - 1] += err // 2
    q[mid] += err - err // 2
    return q


# ---------------------------------------------------------------------------
# IIR: 2nd-order Butterworth low-pass biquad, coefficients in Q2.14
# ---------------------------------------------------------------------------
IIR_CUTOFF = 0.05    # -3 dB point, fraction of fs
IIR_FRAC = 14        # Q2.14: a1 can be close to -2, so we need 2 integer bits


def design_biquad_lowpass(fc=IIR_CUTOFF, q=1 / np.sqrt(2)):
    """Bilinear-transform biquad (RBJ Audio EQ Cookbook). Returns b, a with a0 = 1."""
    w0 = 2 * np.pi * fc
    alpha = np.sin(w0) / (2 * q)
    cosw = np.cos(w0)
    b = np.array([(1 - cosw) / 2, 1 - cosw, (1 - cosw) / 2])
    a = np.array([1 + alpha, -2 * cosw, 1 - alpha])
    return b / a[0], a / a[0]


# ---------------------------------------------------------------------------
def freqz(b, a, n=512):
    """Frequency response H(e^jw) of b/a at n points from 0 to Nyquist."""
    f = np.linspace(0, 0.5, n)
    z = np.exp(-2j * np.pi * f)
    num = np.polyval(np.asarray(b)[::-1], z)
    den = np.polyval(np.asarray(a)[::-1], z)
    return f, num / den


def db(x):
    return 20 * np.log10(np.maximum(np.abs(x), 1e-12))


def report(name, f, h_float, h_fixed, probe):
    print(f"\n{name}: |H| in dB (float -> fixed point)")
    for p in probe:
        i = np.argmin(np.abs(f - p))
        print(f"  f = {p:5.3f} fs : {db(h_float[i]):7.2f} dB -> {db(h_fixed[i]):7.2f} dB")


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("--plot", action="store_true", help="save build/filters.png")
    args = ap.parse_args()

    # FIR
    h = design_fir()
    hq = quantise_fir(h)
    print(f"FIR: {FIR_TAPS} taps, cutoff {FIR_CUTOFF} fs, Q1.{FIR_FRAC}, sum = {hq.sum()}")
    print("Verilog (designs/fir/rtl/fir.v, function coef):")
    for i, c in enumerate(hq):
        print(f"            {i:2d}: coef = {c:6d};")
    f, Hf = freqz(h, [1])
    _, Hq = freqz(hq / 2**FIR_FRAC, [1])
    report("FIR", f, Hf, Hq, [0.0, 0.02, 0.1, 0.2, 0.3, 0.45])

    # IIR
    b, a = design_biquad_lowpass()
    bq = np.round(b * 2**IIR_FRAC).astype(int)
    aq = np.round(a * 2**IIR_FRAC).astype(int)
    print(f"\nIIR biquad: Butterworth, cutoff {IIR_CUTOFF} fs, Q2.{IIR_FRAC}")
    print(f"  float: b = {np.round(b, 6)}, a = {np.round(a, 6)}")
    print(f"  Verilog: B0 = {bq[0]}, B1 = {bq[1]}, B2 = {bq[2]}, A1 = {aq[1]}, A2 = {aq[2]}")
    poles = np.roots(aq / 2**IIR_FRAC)
    print(f"  pole radius after quantisation: {np.abs(poles).max():.5f} (must be < 1)")
    f, Hf2 = freqz(b, a)
    _, Hq2 = freqz(bq / 2**IIR_FRAC, aq / 2**IIR_FRAC)
    report("IIR", f, Hf2, Hq2, [0.0, 0.01, 0.05, 0.1, 0.2, 0.45])

    if args.plot:
        import matplotlib
        matplotlib.use("Agg")
        import matplotlib.pyplot as plt

        fig, ax = plt.subplots(1, 2, figsize=(11, 4))
        for axis, title, hf, hq_ in ((ax[0], "FIR (16 taps)", Hf, Hq),
                                     (ax[1], "IIR biquad", Hf2, Hq2)):
            axis.plot(f, db(hf), label="floating point")
            axis.plot(f, db(hq_), "--", label="fixed point")
            axis.set_title(title)
            axis.set_xlabel("frequency / fs")
            axis.set_ylabel("|H| (dB)")
            axis.set_ylim(-80, 5)
            axis.grid(True)
            axis.legend()
        fig.tight_layout()
        os.makedirs("build", exist_ok=True)
        fig.savefig("build/filters.png", dpi=120)
        print("\nWrote build/filters.png")


if __name__ == "__main__":
    main()
