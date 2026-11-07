#!/usr/bin/env python3
"""render_transistors_iso.py -- isometric render of a routed chip: transistors, wiring and I/O pins.

Draws the transistor layers (diffusion, polysilicon gates, local
interconnect and contacts) and the signal wiring on metal 1 to 3 with their
vias, in a true isometric view. The power straps on metal 4 and 5 are left
out so you can see down to the transistors. The I/O pins are drawn as
coloured posts at their real positions on the die edge (read from the DEF)
and labelled: inputs in orange, outputs in green. --no-wiring keeps only the
transistor layers.

    make pnr                                    # in designs/counter, first
    python3 python/render_transistors_iso.py \\
        designs/counter/build/orfs/results/sky130hd/counter/base/6_final.gds \\
        designs/counter/build/orfs/results/sky130hd/counter/base/6_final.def \\
        -o docs/images/counter_iso_transistors.png

Needs gdstk, pyvista and Pillow (headless: apt install libosmesa6).
"""
import argparse
import os
import re
import sys

import numpy as np

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from render_3d import SKY130_STACK, layer_mesh  # noqa: E402

TRANSISTOR_LAYERS = ("diff", "poly", "li1", "mcon")
WIRING_LAYERS = ("met1", "via", "met2", "via2", "met3")
INPUT = (224, 122, 31)
OUTPUT = (63, 185, 105)
BG = "#0d1117"


def read_def_pins(path):
    """Return [(name, direction, x_um, y_um)] for signal pins in a DEF file."""
    text = open(path).read()
    units = float(re.search(r"UNITS DISTANCE MICRONS (\d+)", text).group(1))
    block = text[text.index("\nPINS"):text.index("END PINS")]
    pins = []
    for m in re.finditer(r"- (\S+) \+ NET \S+(.*?);", block, re.S):
        name, body = m.group(1), m.group(2)
        if "USE SIGNAL" not in body:
            continue
        direction = re.search(r"DIRECTION (\w+)", body).group(1)
        x, y = re.search(r"(?:PLACED|FIXED) \( (-?\d+) (-?\d+) \)", body).groups()
        pins.append((name, direction, int(x) / units, int(y) / units))
    return pins


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("gds")
    ap.add_argument("deffile", help="the matching DEF (for pin positions and directions)")
    ap.add_argument("-o", "--out", default="iso_transistors.png")
    ap.add_argument("--size", nargs=2, type=int, default=(1800, 1300))
    ap.add_argument("--zscale", type=float, default=2.0)
    ap.add_argument("--title", default="The counter chip: transistors and wiring")
    ap.add_argument("--no-wiring", action="store_true",
                    help="transistor layers only (no met1..met3 signal wiring)")
    args = ap.parse_args()

    import gdstk
    import pyvista as pv
    from PIL import Image, ImageDraw, ImageFont

    top = gdstk.read_gds(args.gds).top_level()[0]
    (bx0, by0), (bx1, by1) = top.bounding_box()
    W, H = bx1 - bx0, by1 - by0

    layers = TRANSISTOR_LAYERS + (() if args.no_wiring else WIRING_LAYERS)
    wanted = {spec[0]: spec for spec in SKY130_STACK if spec[1] in layers}
    by_layer = {k: [] for k in wanted}
    for poly in top.get_polygons():
        key = (poly.layer, poly.datatype)
        if key in by_layer:
            by_layer[key].append(poly.points)

    pl = pv.Plotter(off_screen=True, window_size=list(args.size))
    pl.set_background(BG)
    pl.enable_anti_aliasing("ssaa")
    pl.add_mesh(pv.Box(bounds=(bx0, bx1, by0, by1, -0.8 * args.zscale, -0.01)), color="#2b313b")
    for key, (_, name, z0, z1, color, opacity) in wanted.items():
        mesh = layer_mesh(by_layer[key], z0, z1, args.zscale)
        if mesh is not None:
            pl.add_mesh(mesh, color=color, opacity=opacity, specular=0.3, smooth_shading=False)

    # Pins: a coloured post at each pin's real position
    pins = read_def_pins(args.deffile)
    post_h = 4.0 * args.zscale
    for name, direction, x, y in pins:
        col = "#%02x%02x%02x" % (INPUT if direction == "INPUT" else OUTPUT)
        pl.add_mesh(pv.Box(bounds=(x - 0.5, x + 0.5, y - 0.5, y + 0.5, 0, post_h)), color=col)

    # True isometric view: parallel projection, 45 deg azimuth, 35.26 deg elevation
    cx, cy = (bx0 + bx1) / 2, (by0 + by1) / 2
    el, az = np.radians(35.264), np.radians(-135.0)   # looking from the south-west corner
    d = 3 * max(W, H)
    pl.camera.focal_point = (cx, cy, 0)
    pl.camera.position = (cx + d * np.cos(el) * np.cos(az), cy + d * np.cos(el) * np.sin(az), d * np.sin(el))
    pl.camera.up = (0, 0, 1)
    pl.enable_parallel_projection()
    pl.camera.parallel_scale = 0.56 * max(W, H)
    shot = Image.fromarray(pl.screenshot(return_img=True)).convert("RGB")
    # Extra canvas on the sides so labels of edge pins are never clipped
    ML, MR = 260, 140
    img = Image.new("RGB", (shot.width + ML + MR, shot.height), BG)
    img.paste(shot, (ML, 0))

    # World -> pixel, using the renderer's own transform
    ren = pl.renderer

    def to_px(x, y, z):
        ren.SetWorldPoint(x, y, z, 1.0)
        ren.WorldToDisplay()
        px, py, _ = ren.GetDisplayPoint()
        return px + ML, args.size[1] - py

    # Labels: spread the pins on each side evenly so names never overlap
    def side(x, y):
        dists = {"W": x - bx0, "E": bx1 - x, "S": y - by0, "N": by1 - y}
        return min(dists, key=dists.get)

    groups = {}
    for p in pins:
        groups.setdefault(side(p[2], p[3]), []).append(p)
    out = 0.14 * max(W, H)
    labels = []
    for s, ps in groups.items():
        along = (lambda p: p[3]) if s in "WE" else (lambda p: p[2])
        ps.sort(key=along)
        n = len(ps)
        lo, hi = (by0, by1) if s in "WE" else (bx0, bx1)
        span = (hi - lo) * min(0.8, 0.16 * n)
        mid = (lo + hi) / 2
        for i, p in enumerate(ps):
            t = mid if n == 1 else mid - span / 2 + span * i / (n - 1)
            lx, ly = {"W": (bx0 - out, t), "E": (bx1 + out, t), "S": (t, by0 - out), "N": (t, by1 + out)}[s]
            labels.append((p, s, (lx, ly)))

    dr = ImageDraw.Draw(img)

    def font(names, size):
        for nm in names:
            try:
                return ImageFont.truetype(nm, size)
            except OSError:
                continue
        return ImageFont.load_default()

    mono = font(["DejaVuSansMono-Bold.ttf", "/usr/share/fonts/truetype/dejavu/DejaVuSansMono-Bold.ttf"], 26)
    bold = font(["/usr/share/fonts/opentype/inter/InterDisplay-Bold.otf", "DejaVuSans-Bold.ttf"], 44)
    reg = font(["/usr/share/fonts/opentype/inter/Inter-Regular.otf", "DejaVuSans.ttf"], 26)
    small = font(["/usr/share/fonts/opentype/inter/Inter-Regular.otf", "DejaVuSans.ttf"], 20)

    for (name, direction, x, y), s, (lx, ly) in labels:
        col = INPUT if direction == "INPUT" else OUTPUT
        top_px = to_px(x, y, post_h)
        lab_px = to_px(lx, ly, post_h)
        dr.line([top_px, lab_px], fill=col, width=3)
        dr.ellipse([lab_px[0] - 5, lab_px[1] - 5, lab_px[0] + 5, lab_px[1] + 5], fill=col)
        arrow = "→ " if direction == "INPUT" else "← "
        txt = (arrow + name) if direction == "INPUT" else (name + " →")
        tw = dr.textlength(txt, font=mono)
        centre_px = to_px(cx, cy, 0)[0]
        tx = lab_px[0] - tw - 10 if lab_px[0] < centre_px else lab_px[0] + 10
        dr.text((tx, lab_px[1] - 15), txt, font=mono, fill=col)

    dr.text((50, 40), args.title, font=bold, fill=(240, 246, 252))
    dr.text((50, 100), "Hardware is the new Software", font=reg, fill=(88, 196, 220))
    dr.text((50, args.size[1] - 150), "■ inputs: clk, rst_n, en", font=reg, fill=INPUT)
    dr.text((50, args.size[1] - 115), "■ outputs: count[7:0], wrap", font=reg, fill=OUTPUT)
    legend1 = ("diffusion (green) · polysilicon gates (red) · local interconnect (blue) · contacts and vias (grey)"
               + ("" if args.no_wiring else
                  " · metal 1 (purple: cell power rails, short wires) · metal 2 (pink) · metal 3 (cyan)"))
    legend2 = ("Power straps on metal 4 and 5 removed. Coloured posts mark the pins at their real positions "
               "on the %.0f × %.0f µm die." % (W, H))
    dr.text((50, img.height - 70), legend1, font=small, fill=(139, 148, 158))
    dr.text((50, img.height - 42), legend2, font=small, fill=(139, 148, 158))

    os.makedirs(os.path.dirname(os.path.abspath(args.out)), exist_ok=True)
    img.save(args.out)
    print("Wrote", args.out)


if __name__ == "__main__":
    main()
