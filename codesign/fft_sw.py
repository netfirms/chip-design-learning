#!/usr/bin/env python3
"""fft_sw.py -- the 8-point FFT in software, five ways.

The same job as designs/fft (fft8.v), written as software, so the course can
compare the two:

    dft_naive(x)        the definition, a double loop: 64 complex multiplies
    fft_python(x)       radix-2 decimation in time, plain Python floats
    np.fft.fft(x)       NumPy: one call per frame
    np.fft.fft(X, axis=1)   NumPy: many frames in one call (batched)
    fft8_fixed(x)       BIT-EXACT model of the hardware: same widths, same
                        truncation, same twiddle constant, Python integers
    fft8_fixed_np(X)    the same bit-exact model, vectorised over many frames

The bit-exact model is the "golden model" of hardware/software co-design: a
software version that gives the same bits as the RTL, so you can test the
chip against it, explore widths and constants quickly in Python, and run the
algorithm in software when no chip is around.

    python3 codesign/fft_sw.py                 # self-test against floats
    python3 codesign/fft_sw.py --rtl-csv designs/fft/build/fft8_out.csv
                                               # compare with the RTL, bit for bit
"""
import argparse
import cmath
import csv
import math
import sys

import numpy as np

N = 8
W = 16            # input width, Q1.15
IW = W + 1        # internal and output width (fft8.v)
C = 23170         # sqrt(2)/2 in Q1.15 (fft_bfly.v)

# Bit-reversed order of a 3-bit index: 0 4 2 6 1 5 3 7
BITREV = [((i & 1) << 2) | (i & 2) | ((i >> 2) & 1) for i in range(N)]


# ---------------------------------------------------------------------------
# Floating point
# ---------------------------------------------------------------------------
def dft_naive(x):
    """X[k] = (1/8) sum x[n] exp(-j 2 pi n k / 8), straight from the formula."""
    out = []
    for k in range(N):
        acc = 0j
        for n in range(N):
            acc += x[n] * cmath.exp(-2j * math.pi * n * k / N)
        out.append(acc / N)
    return out


_TW = [cmath.exp(-2j * math.pi * k / N) for k in range(N // 2)]


def fft_python(x):
    """Radix-2 DIT FFT in plain Python, scaled by 1/2 per stage like fft8.v."""
    a = [complex(x[r]) for r in BITREV]
    span = 1
    while span < N:
        step = N // (2 * span)            # twiddle stride for this stage
        for start in range(0, N, 2 * span):
            for j in range(span):
                t = _TW[j * step] * a[start + j + span]
                u = a[start + j]
                a[start + j] = (u + t) * 0.5
                a[start + j + span] = (u - t) * 0.5
        span *= 2
    return a


# ---------------------------------------------------------------------------
# Bit-exact model of rtl/fft_bfly.v and rtl/fft8.v
# ---------------------------------------------------------------------------
def _wrap(v, bits):
    """Keep the low `bits` bits of v as a signed number (what a Verilog wire does)."""
    m = 1 << bits
    v &= m - 1
    return v - m if v >= (m >> 1) else v


def bfly_fixed(a_re, a_im, b_re, b_im, k):
    """One butterfly with twiddle W8^k, exactly as fft_bfly.v computes it."""
    s = _wrap(b_re + b_im, IW + 1)
    d = _wrap(b_im - b_re, IW + 1)
    # c_sum[IW+15:15]: multiply by C, then an arithmetic shift right by 15
    cs = _wrap((s * C) >> 15, IW + 1)
    cd = _wrap((d * C) >> 15, IW + 1)
    if k == 0:
        t_re, t_im = b_re, b_im
    elif k == 1:
        t_re, t_im = cs, cd
    elif k == 2:
        t_re, t_im = b_im, -b_re
    else:
        t_re, t_im = cd, -cs
    # (a +/- t) with one extra bit, then keep bits [IW:1], i.e. >> 1
    y0 = (_wrap((a_re + t_re) >> 1, IW), _wrap((a_im + t_im) >> 1, IW))
    y1 = (_wrap((a_re - t_re) >> 1, IW), _wrap((a_im - t_im) >> 1, IW))
    return y0, y1


def fft8_fixed(x_re, x_im):
    """8 integer samples in Q1.15 -> 8 integer outputs, the same bits as fft8.v."""
    re = [x_re[r] for r in BITREV]
    im = [x_im[r] for r in BITREV]
    span = 1
    while span < N:
        step = N // (2 * span)
        for start in range(0, N, 2 * span):
            for j in range(span):
                p, q = start + j, start + j + span
                (re[p], im[p]), (re[q], im[q]) = bfly_fixed(
                    re[p], im[p], re[q], im[q], j * step)
        span *= 2
    return re, im


def _wrap_np(v, bits):
    m = np.int64(1 << bits)
    v = v & (m - 1)
    return np.where(v >= (m >> 1), v - m, v)


def fft8_fixed_np(x_re, x_im):
    """Bit-exact model over many frames at once: arrays of shape (frames, 8)."""
    re = np.asarray(x_re, dtype=np.int64)[:, BITREV]
    im = np.asarray(x_im, dtype=np.int64)[:, BITREV]
    span = 1
    while span < N:
        step = N // (2 * span)
        for start in range(0, N, 2 * span):
            for j in range(span):
                p, q = start + j, start + j + span
                a_re, a_im, b_re, b_im = re[:, p], im[:, p], re[:, q], im[:, q]
                k = j * step
                if k == 0:
                    t_re, t_im = b_re, b_im
                elif k == 2:
                    t_re, t_im = b_im, -b_re
                else:
                    cs = _wrap_np(((b_re + b_im) * C) >> 15, IW + 1)
                    cd = _wrap_np(((b_im - b_re) * C) >> 15, IW + 1)
                    t_re, t_im = (cs, cd) if k == 1 else (cd, -cs)
                y0r = _wrap_np((a_re + t_re) >> 1, IW)
                y0i = _wrap_np((a_im + t_im) >> 1, IW)
                y1r = _wrap_np((a_re - t_re) >> 1, IW)
                y1i = _wrap_np((a_im - t_im) >> 1, IW)
                re[:, p], im[:, p], re[:, q], im[:, q] = y0r, y0i, y1r, y1i
        span *= 2
    return re, im


# ---------------------------------------------------------------------------
# Checks
# ---------------------------------------------------------------------------
def random_frames(frames, seed=1):
    rng = np.random.default_rng(seed)
    lim = 1 << (W - 1)
    return (rng.integers(-lim, lim, size=(frames, N)),
            rng.integers(-lim, lim, size=(frames, N)))


def self_test(frames=2000):
    """All implementations agree; the fixed-point model is within 3 LSB of float."""
    xr, xi = random_frames(frames)
    xc = xr + 1j * xi
    ref = np.fft.fft(xc, axis=1) / N
    ok = True

    for name, f in (("dft_naive", dft_naive), ("fft_python", fft_python)):
        err = max(abs(np.asarray(f(list(xc[i]))) - ref[i]).max() for i in range(50))
        print(f"  {name:14s} max |error| vs NumPy = {err:.2e}")
        ok &= err < 1e-6

    fr, fi = fft8_fixed_np(xr, xi)
    worst = max(abs(fr - ref.real).max(), abs(fi - ref.imag).max())
    print(f"  {'fft8_fixed_np':14s} max error vs float = {worst:.2f} LSB (tolerance 3)")
    ok &= worst <= 3

    same = all(
        (list(fr[i]), list(fi[i])) == tuple(map(list, fft8_fixed(list(xr[i]), list(xi[i]))))
        for i in range(200))
    print(f"  {'fft8_fixed':14s} matches fft8_fixed_np: {same}")
    return ok and same


def compare_rtl(path):
    """Run the bit-exact model on the testbench inputs and compare every output bit."""
    frames = {}
    with open(path) as f:
        for row in csv.DictReader(f):
            fr = frames.setdefault(int(row["frame"]), {})
            fr[int(row["k"])] = row
    outputs = mismatches = 0
    for fnum, rows in sorted(frames.items()):
        x_re = [int(rows[n]["x_re"]) for n in range(N)]
        x_im = [int(rows[n]["x_im"]) for n in range(N)]
        y_re, y_im = fft8_fixed(x_re, x_im)
        for k in range(N):
            outputs += 1
            if (y_re[k], y_im[k]) != (int(rows[k]["X_re"]), int(rows[k]["X_im"])):
                mismatches += 1
                print(f"  frame {fnum} X[{k}]: model {y_re[k]},{y_im[k]}"
                      f"  rtl {rows[k]['X_re']},{rows[k]['X_im']}")
    print(f"  {len(frames)} frames, {outputs} outputs, {mismatches} mismatches")
    return mismatches == 0


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("--rtl-csv", help="fft8_out.csv written by `make sim` in designs/fft")
    args = ap.parse_args()
    print("Self-test:")
    ok = self_test()
    if args.rtl_csv:
        print(f"Bit-exact model vs RTL ({args.rtl_csv}):")
        ok &= compare_rtl(args.rtl_csv)
    print("PASS" if ok else "FAIL")
    sys.exit(0 if ok else 1)


if __name__ == "__main__":
    main()
