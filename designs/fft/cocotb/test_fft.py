"""test_fft.py -- cocotb testbench for rtl/fft8.v

The reference is one line: numpy.fft.fft(x) / 8. The hardware truncates in
each of its 3 butterfly stages, so it is not bit-exact with a floating
point FFT; instead the test measures the error over many frames and checks
it stays within a few LSBs, and reports the signal-to-quantisation-noise
ratio (SQNR) the way a DSP engineer would.

Run:  make cocotb            (in designs/fft)
"""
import random

import numpy as np

import cocotb
from cocotb.triggers import FallingEdge, ReadOnly, RisingEdge

from cocotb_util import start

N = 8
TOL = 3   # LSBs, same as tb/fft8_tb.v


async def run_frame(dut, x):
    """Load 8 complex samples, collect the 8 results, return them in bin order."""
    for v in x:
        while True:
            await FallingEdge(dut.clk)
            if dut.in_ready.value == 1:
                break
        dut.in_re.value = int(v.real)
        dut.in_im.value = int(v.imag)
        dut.in_valid.value = 1
    await FallingEdge(dut.clk)
    dut.in_valid.value = 0

    X = [None] * N
    order = []
    while len(order) < N:
        await RisingEdge(dut.clk)
        await ReadOnly()
        if dut.out_valid.value == 1:
            k = int(dut.out_idx.value)
            X[k] = complex(dut.out_re.value.to_signed(), dut.out_im.value.to_signed())
            order.append(k)
    assert order == list(range(N)), f"bins came out in order {order}"
    return np.array(X)


async def check(dut, x, stats):
    X = await run_frame(dut, np.asarray(x))
    ref = np.fft.fft(np.asarray(x, dtype=complex)) / N
    err = np.concatenate([np.abs(X.real - ref.real), np.abs(X.imag - ref.imag)])
    stats["max"] = max(stats.get("max", 0), err.max())
    stats["sig"] = stats.get("sig", 0) + np.sum(np.abs(ref) ** 2)
    stats["noise"] = stats.get("noise", 0) + np.sum(np.abs(X - ref) ** 2)
    assert err.max() <= TOL, f"X = {X}\nref = {np.round(ref, 1)}"
    return X


async def setup(dut):
    dut.in_valid.value = 0
    dut.in_re.value = 0
    dut.in_im.value = 0
    await start(dut)


@cocotb.test()
async def test_known_spectra(dut):
    """Inputs whose spectrum you can work out by hand."""
    await setup(dut)
    s = {}
    n = np.arange(N)
    X = await check(dut, [16384] + [0] * 7, s)                        # impulse: flat
    assert np.allclose(X, 2048, atol=1)
    X = await check(dut, [10000] * 8, s)                              # DC: bin 0 only
    assert abs(X[0] - 10000) <= 1 and np.all(np.abs(X[1:]) <= 1)
    X = await check(dut, np.round(20000 * np.cos(2 * np.pi * n / N)), s)   # cos: bins 1, 7
    assert abs(X[1] - 10000) <= TOL and abs(X[7] - 10000) <= TOL
    X = await check(dut, np.round(20000 * np.exp(2j * np.pi * 3 * n / N)), s)  # bin 3 only
    assert abs(X[3] - 20000) <= TOL


@cocotb.test()
async def test_full_scale(dut):
    """Corner cases: the largest values that fit must not overflow."""
    await setup(dut)
    s = {}
    await check(dut, [complex(32767, 32767)] * 8, s)
    await check(dut, [complex(32767 if i % 2 else -32768, -32768) for i in range(8)], s)
    await check(dut, [complex(-32768, -32768)] * 8, s)


@cocotb.test()
async def test_random_sqnr(dut):
    """200 random frames: error within TOL LSBs, and SQNR above 75 dB."""
    await setup(dut)
    s = {}
    for _ in range(200):
        x = [complex(random.randint(-32768, 32767), random.randint(-32768, 32767))
             for _ in range(N)]
        await check(dut, x, s)
    sqnr = 10 * np.log10(s["sig"] / s["noise"])
    dut._log.info("200 frames: max error %.2f LSB, SQNR %.1f dB", s["max"], sqnr)
    assert sqnr > 75
