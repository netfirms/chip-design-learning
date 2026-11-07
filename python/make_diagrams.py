#!/usr/bin/env python3
"""make_diagrams.py -- draw the explanatory SVG diagrams in docs/images/.

    python3 python/make_diagrams.py

Pure Python, no dependencies: each diagram is written as SVG by hand so it
stays sharp at any size and is easy to tweak. Colours match the 3D renders.
"""
import math
import os

OUT = os.path.join(os.path.dirname(__file__), "..", "docs", "images")

BG = "#0d1117"
FG = "#e6edf3"
MUTED = "#8b949e"
ACCENT = "#58c4dc"
BOX = "#161b22"
EDGE = "#30363d"
FONT = "font-family='Inter, Segoe UI, Helvetica, Arial, sans-serif'"
MONO = "font-family='JetBrains Mono, Consolas, monospace'"


class Svg:
    def __init__(self, w, h):
        self.w, self.h, self.items = w, h, []
        self.items.append(f"<rect width='{w}' height='{h}' rx='14' fill='{BG}'/>")
        self.items.append(
            "<defs><marker id='arr' viewBox='0 0 10 10' refX='9' refY='5' markerWidth='7' "
            f"markerHeight='7' orient='auto-start-reverse'><path d='M0,0 L10,5 L0,10 z' fill='{MUTED}'/>"
            "</marker></defs>")

    def add(self, s):
        self.items.append(s)

    def text(self, x, y, s, size=15, color=FG, anchor="middle", weight=400, mono=False):
        f = MONO if mono else FONT
        self.add(f"<text x='{x}' y='{y}' {f} font-size='{size}' fill='{color}' "
                 f"text-anchor='{anchor}' font-weight='{weight}' dominant-baseline='middle' "
                 f"xml:space='preserve'>{s}</text>")

    def box(self, x, y, w, h, fill=BOX, stroke=EDGE, rx=8, sw=1.5):
        self.add(f"<rect x='{x}' y='{y}' width='{w}' height='{h}' rx='{rx}' fill='{fill}' "
                 f"stroke='{stroke}' stroke-width='{sw}'/>")

    def line(self, x1, y1, x2, y2, color=MUTED, arrow=True, sw=1.8, dash=None):
        m = " marker-end='url(#arr)'" if arrow else ""
        d = f" stroke-dasharray='{dash}'" if dash else ""
        self.add(f"<line x1='{x1}' y1='{y1}' x2='{x2}' y2='{y2}' stroke='{color}' "
                 f"stroke-width='{sw}'{m}{d}/>")

    def path(self, d, color=MUTED, arrow=True, sw=1.8):
        m = " marker-end='url(#arr)'" if arrow else ""
        self.add(f"<path d='{d}' fill='none' stroke='{color}' stroke-width='{sw}'{m}/>")

    def circle(self, x, y, r, label, fill=BOX, stroke=ACCENT):
        self.add(f"<circle cx='{x}' cy='{y}' r='{r}' fill='{fill}' stroke='{stroke}' stroke-width='1.8'/>")
        self.text(x, y + 1, label, size=int(r * 1.1), color=stroke, weight=600)

    def save(self, name):
        path = os.path.join(OUT, name)
        with open(path, "w") as f:
            f.write(f"<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 {self.w} {self.h}' "
                    f"width='{self.w}' height='{self.h}'>\n" + "\n".join(self.items) + "\n</svg>\n")
        print("Wrote", os.path.relpath(path))


# ---------------------------------------------------------------------------
def flow():
    """RTL -> GDS flow with the make target for each stage."""
    stages = [
        ("RTL", "Verilog", "you write", "#3fae49"),
        ("Simulate", "Icarus / Verilator", "make sim", "#3fae49"),
        ("Synthesise", "Yosys", "make synth", "#6d8fd8"),
        ("Floorplan", "OpenROAD", "", "#8c6bd6"),
        ("Place", "OpenROAD", "", "#8c6bd6"),
        ("Clock tree", "OpenROAD", "", "#8c6bd6"),
        ("Route", "OpenROAD", "", "#e05fa6"),
        ("GDS", "KLayout", "6_final.gds", "#e8c547"),
    ]
    w, h = 1280, 270
    s = Svg(w, h)
    s.text(40, 34, "From Verilog to silicon: the flow every design in this repo goes through",
           size=18, anchor="start", weight=600)
    bw, gap, y = 136, 20, 80
    x0 = (w - (len(stages) * bw + (len(stages) - 1) * gap)) / 2
    for i, (name, tool, tgt, col) in enumerate(stages):
        x = x0 + i * (bw + gap)
        s.box(x, y, bw, 88, stroke=col, sw=2)
        s.text(x + bw / 2, y + 28, name, size=17, weight=600)
        s.text(x + bw / 2, y + 58, tool, size=13, color=MUTED)
        if tgt:
            s.text(x + bw / 2, y + 116, tgt, size=13, color=ACCENT, mono=True)
        if i < len(stages) - 1:
            s.line(x + bw + 2, y + 44, x + bw + gap - 2, y + 44)
    # bracket for the pnr stages
    bx0 = x0 + 3 * (bw + gap)
    bx1 = x0 + 6 * (bw + gap) + bw
    s.path(f"M{bx0},{y + 104} L{bx0},{y + 110} L{bx1},{y + 110} L{bx1},{y + 104}", color=ACCENT,
           arrow=False, sw=1.2)
    s.text((bx0 + bx1) / 2, y + 128, "make pnr", size=13, color=ACCENT, mono=True)
    s.text(40, 244, "Static timing analysis (OpenSTA) checks every stage after synthesis "
                    "against the clock in orfs/constraint.sdc.", size=14, color=MUTED, anchor="start")
    s.save("flow.svg")


def stack():
    """Cross-section of the sky130 layers, same colours as python/render_3d.py."""
    layers = [  # name, z0, z1, colour, description
        ("met5", 5.37, 6.63, "#e8c547", "top metal: power grid"),
        ("met4", 4.02, 4.87, "#f29b38", "power straps"),
        ("met3", 2.79, 3.63, "#2fc3d6", "long signal routes"),
        ("met2", 2.01, 2.37, "#e05fa6", "vertical routing"),
        ("met1", 1.38, 1.74, "#8c6bd6", "horizontal routing, power rails"),
        ("li1", 0.94, 1.04, "#6d8fd8", "local interconnect inside cells"),
        ("poly", 0.33, 0.51, "#d6312b", "transistor gates"),
        ("diff", 0.00, 0.12, "#3fae49", "transistor source/drain"),
    ]
    w, h = 900, 520
    s = Svg(w, h)
    s.text(40, 36, "The sky130 layer stack (heights in um, roughly to scale)", size=18,
           anchor="start", weight=600)
    sx, sy, scale = 120, 470, 60  # x of stack, y of silicon surface, px per um
    s.box(sx - 20, sy, 340, 30, fill="#3a3f4a", stroke="#3a3f4a", rx=2)
    s.text(sx + 150, sy + 15, "silicon substrate", size=13, color=FG)
    for name, z0, z1, col, desc in layers:
        y0, y1 = sy - z1 * scale, sy - z0 * scale
        hh = max(y1 - y0, 4)
        s.box(sx, y0, 300, hh, fill=col, stroke=col, rx=2)
        s.text(sx - 30, (y0 + y1) / 2, name, size=14, anchor="end", mono=True, color=col)
        s.text(sx + 330, (y0 + y1) / 2, desc, size=14, anchor="start", color=MUTED)
        s.text(sx + 590, (y0 + y1) / 2, f"{z0:.2f}-{z1:.2f}", size=13, anchor="start",
               color=MUTED, mono=True)
    # vias as small grey pillars
    for name, z0, z1 in [("", 0.51, 0.94), ("", 1.04, 1.38), ("", 1.74, 2.01),
                         ("", 2.37, 2.79), ("", 3.63, 4.02), ("", 4.87, 5.37)]:
        for k in range(3):
            x = sx + 40 + k * 90 + (z0 * 13) % 40
            s.box(x, sy - z1 * scale, 8, (z1 - z0) * scale, fill="#c9c9c9", stroke="#c9c9c9", rx=1)
    s.text(sx + 590, 72, "z (um)", size=13, anchor="start", color=MUTED)
    s.save("sky130_stack.svg")


def qformat():
    """Bit layout of Q1.15 and the multiply rule."""
    w, h = 980, 300
    s = Svg(w, h)
    s.text(40, 34, "Fixed point: a 16-bit Q1.15 number", size=18, anchor="start", weight=600)
    x0, y0, bw = 60, 70, 52
    sup = "<tspan dy='-7' font-size='11'>{}</tspan>"
    weights = ["−2" + sup.format("0")] + ["2" + sup.format(f"−{i}") for i in range(1, 16)]
    for i in range(16):
        col = "#e05fa6" if i == 0 else "#6d8fd8"
        s.box(x0 + i * bw, y0, bw - 4, 46, stroke=col, sw=2)
        s.text(x0 + i * bw + (bw - 4) / 2, y0 + 23, weights[i], size=14)
        s.text(x0 + i * bw + (bw - 4) / 2, y0 + 62, str(15 - i), size=11, color=MUTED, mono=True)
    s.text(x0 + 24, y0 - 14, "sign", size=13, color="#e05fa6")
    s.text(x0 + bw + 7.5 * bw, y0 - 14, "15 fractional bits", size=13, color="#6d8fd8")
    s.add(f"<line x1='{x0 + bw - 2}' y1='{y0 - 6}' x2='{x0 + bw - 2}' y2='{y0 + 52}' "
          f"stroke='{ACCENT}' stroke-width='3' stroke-dasharray='4 3'/>")
    s.text(x0 + bw - 2, y0 + 86, "binary point", size=12, color=ACCENT)
    s.text(40, 200, "value = integer / 2¹⁵      range [-1, +1)      1 LSB = 3.05 × 10⁻⁵",
           size=16, anchor="start", mono=True)
    s.text(40, 240, "Q1.15 × Q1.15 = Q2.30 (32 bits)   →   round, then >>> 15   →   Q1.15",
           size=16, anchor="start", mono=True, color=ACCENT)
    s.text(40, 274, "0.5 = 16384      -1.0 = -32768      √2/2 ≈ 23170 (the FFT twiddle)",
           size=14, anchor="start", mono=True, color=MUTED)
    s.save("qformat.svg")


def fir():
    """Time-shared MAC FIR datapath."""
    w, h = 1120, 360
    s = Svg(w, h)
    s.text(40, 34, "designs/fir: one multiplier shared by 16 taps (17 clocks per sample)",
           size=18, anchor="start", weight=600)
    # delay line
    x0, y0 = 60, 80
    s.text(x0 - 10, y0 + 22, "x[n]", size=15, anchor="end", mono=True)
    for i in range(8):
        lab = "x[n]" if i == 0 else (f"x[n-{i}]" if i < 7 else "…x[n-15]")
        s.box(x0 + 10 + i * 92, y0, 82, 44, stroke="#3fae49", sw=2)
        s.text(x0 + 51 + i * 92, y0 + 22, lab, size=13, mono=True)
    s.text(x0 + 380, y0 - 18, "delay line: 16 registers × 16 bits (shifts once per new sample)",
           size=13, color=MUTED)
    # mux
    mx, my = 360, 170
    s.add(f"<polygon points='{mx},{my} {mx + 140},{my} {mx + 120},{my + 40} {mx + 20},{my + 40}' "
          f"fill='{BOX}' stroke='{ACCENT}' stroke-width='2'/>")
    s.text(mx + 70, my + 20, "mux x[n-k]", size=13)
    for i in range(0, 8, 2):
        s.line(x0 + 51 + i * 92, y0 + 46, mx + 30 + i * 12, my - 2, sw=1.2)
    # coefficient ROM
    s.box(610, 170, 150, 40, stroke="#d6312b", sw=2)
    s.text(685, 190, "ROM h[k]", size=14)
    # counter k
    s.box(800, 110, 120, 40, stroke=MUTED)
    s.text(860, 130, "k = 0…15", size=14, mono=True)
    s.path("M860,152 L860,190 L762,190")
    s.path("M800,140 L480,140 L480,166", sw=1.2)
    # multiplier
    s.circle(560, 270, 22, "×")
    s.line(430, 212, 542, 258)
    s.line(685, 212, 578, 258)
    # adder + accumulator
    s.circle(700, 300, 22, "+")
    s.line(582, 276, 678, 296)
    s.box(780, 280, 100, 40, stroke="#e8c547", sw=2)
    s.text(830, 300, "acc", size=14, mono=True)
    s.line(722, 300, 778, 300)
    s.path("M830,322 L830,340 L700,340 L700,324")
    s.line(882, 300, 940, 300)
    s.text(950, 290, "round,", size=13, anchor="start", color=MUTED)
    s.text(950, 310, "saturate → y[n]", size=13, anchor="start", color=MUTED)
    s.text(60, 300, "y[n] = Σ h[k] · x[n-k]", size=18, anchor="start", mono=True, color=ACCENT)
    s.text(60, 330, "1 multiplier instead of 16: ~16× smaller, 17× slower", size=13,
           anchor="start", color=MUTED)
    s.save("fir_arch.svg")


def iir():
    """Direct Form I biquad."""
    w, h = 960, 400
    s = Svg(w, h)
    s.text(40, 34, "designs/iir: Direct Form I biquad (all five products every clock)",
           size=18, anchor="start", weight=600)
    xl, xr, xa = 110, 760, 480
    ys = [100, 210, 320]
    s.text(40, ys[0], "x[n]", size=16, mono=True)
    s.line(68, ys[0], xl + 30, ys[0])
    s.text(910, ys[0], "y[n]", size=16, mono=True)
    for i, y in enumerate(ys):
        # feed-forward taps
        if i > 0:
            s.box(xl - 30, (ys[i - 1] + y) / 2 - 18, 60, 36, stroke="#3fae49", sw=2)
            s.text(xl, (ys[i - 1] + y) / 2, "z⁻¹", size=15)
            s.line(xl, ys[i - 1] + 2, xl, (ys[i - 1] + y) / 2 - 20)
            s.line(xl, (ys[i - 1] + y) / 2 + 20, xl, y - 2, arrow=False)
        s.line(xl, y, 260, y, arrow=False)
        s.circle(290, y, 26, f"b{i}", stroke="#d6312b")
        s.line(318, y, xa - 24, y if i == 0 else y, arrow=True)
        # feedback taps
        if i > 0:
            s.box(xr - 30, (ys[i - 1] + y) / 2 - 18, 60, 36, stroke="#3fae49", sw=2)
            s.text(xr, (ys[i - 1] + y) / 2, "z⁻¹", size=15)
            s.line(xr, ys[i - 1] + 2, xr, (ys[i - 1] + y) / 2 - 20)
            s.line(xr, (ys[i - 1] + y) / 2 + 20, xr, y - 2, arrow=False)
            s.line(xr, y, 700, y, arrow=False)
            s.circle(670, y, 26, f"-a{i}", stroke="#e8c547")
            s.line(642, y, xa + 24, y)
    # adder column
    s.circle(xa, ys[0], 22, "+")
    for y in ys[1:]:
        s.circle(xa, y, 22, "+")
    s.line(xa, ys[2] - 24, xa, ys[1] + 24)
    s.line(xa, ys[1] - 24, xa, ys[0] + 24)
    s.line(xa + 24, ys[0], 880, ys[0])
    s.path(f"M{xr},{ys[0]} L{xr},{ys[0] + 2}", arrow=False)
    s.add(f"<circle cx='{xr}' cy='{ys[0]}' r='4' fill='{MUTED}'/>")
    s.text(xa, 372, "feedback: y[n-1] → × → + → y[n] in one clock = the critical path",
           size=14, color=ACCENT)
    s.save("iir_arch.svg")


def fft():
    """8-point radix-2 DIT butterfly network."""
    w, h = 1040, 610
    s = Svg(w, h)
    s.text(40, 34, "designs/fft: 8-point radix-2 decimation-in-time FFT", size=18,
           anchor="start", weight=600)
    order = [0, 4, 2, 6, 1, 5, 3, 7]
    cols = [120, 340, 560, 780]
    y0, dy = 90, 58
    ys = [y0 + i * dy for i in range(8)]
    stage_col = ["#3fae49", "#6d8fd8", "#e05fa6"]
    for i in range(8):
        s.text(cols[0] - 50, ys[i], f"x[{order[i]}]", size=15, mono=True)
        s.text(cols[3] + 60, ys[i], f"X[{i}]", size=15, mono=True)
        for c in cols:
            s.add(f"<circle cx='{c}' cy='{ys[i]}' r='4' fill='{FG}'/>")
    for st, span in enumerate([1, 2, 4]):
        xa, xb = cols[st], cols[st + 1]
        for g in range(0, 8, 2 * span):
            for j in range(span):
                a, b = g + j, g + j + span
                k = j * (4 // span)
                col = stage_col[st]
                s.line(xa, ys[a], xb, ys[a], color=col, arrow=False, sw=1.6)
                s.line(xa, ys[b], xb, ys[b], color=col, arrow=False, sw=1.6)
                s.line(xa, ys[a], xb, ys[b], color=col, arrow=False, sw=1.6)
                s.line(xa, ys[b], xb, ys[a], color=col, arrow=False, sw=1.6)
                if k:
                    s.text(xa + 34, ys[b] + 16, f"W{k}", size=12, color=ACCENT, mono=True)
                s.text(xb - 22, ys[b] + 16, "−", size=15, color=col)
    for st in range(3):
        s.text((cols[st] + cols[st + 1]) / 2, 66, f"stage {st + 1} (span {2 ** st})", size=14,
               color=stage_col[st], weight=600)
    s.text(40, 562, "Each X is one butterfly: (a + W·b)/2 and (a − W·b)/2.  W⁰ = 1, "
                    "W² = −j (free), W¹, W³ = √2/2·(±1 − j) (one constant multiply).",
           size=14, color=MUTED, anchor="start")
    s.text(40, 588, "Inputs arrive in bit-reversed order (1 = 001 → 100 = 4); outputs come out "
                    "in natural order.", size=14, color=MUTED, anchor="start")
    s.save("fft_butterfly.svg")


def pwm():
    """PWM waveform and average level."""
    w, h = 1000, 260
    s = Svg(w, h)
    s.text(40, 34, "designs/pwm: duty cycle sets the average voltage", size=18, anchor="start",
           weight=600)
    x0, period = 140, 200
    for row, (duty, lab) in enumerate([(0.25, "duty = 25%"), (0.75, "duty = 75%")]):
        ybase, yhigh = 120 + row * 100, 80 + row * 100
        d = f"M{x0},{ybase}"
        for p in range(4):
            xs = x0 + p * period
            d += f" L{xs},{yhigh} L{xs + duty * period},{yhigh} L{xs + duty * period},{ybase} " \
                 f"L{xs + period},{ybase}"
        s.path(d, color="#3fae49", arrow=False, sw=2.2)
        yavg = ybase - duty * (ybase - yhigh)
        s.line(x0, yavg, x0 + 4 * period, yavg, color="#e8c547", arrow=False, sw=2, dash="6 4")
        s.text(x0 - 10, (ybase + yhigh) / 2, lab, size=13, anchor="end", color=MUTED)
    s.text(x0 + 4 * period - 4, 240, "dashed: after an RC low-pass, V = VDD × duty / 2^WIDTH",
           size=13, anchor="end", color="#e8c547")
    s.save("pwm_wave.svg")


if __name__ == "__main__":
    os.makedirs(OUT, exist_ok=True)
    for fn in (flow, stack, qformat, fir, iir, fft, pwm):
        fn()
