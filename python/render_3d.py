#!/usr/bin/env python3
"""render_3d.py -- render a routed layout (GDS) as a 3D picture of the chip.

Each sky130 layer is extruded to its approximate height in the real process
stack: transistor diffusion and polysilicon gates at the bottom, then the
local interconnect (li1) and five metal layers. Vias are drawn as pillars.

    make pnr                               # in a design directory, first
    python3 python/render_3d.py designs/fft/build/orfs/results/sky130hd/fft8/base/6_final.gds \
        -o fft_3d.webp
    python3 python/render_3d.py <gds> -o zoom.png --region 20 20 45 35   # close-up (um)

Needs gdstk and pyvista (pip install gdstk pyvista). Headless machines also
need OSMesa or EGL (Ubuntu: apt install libosmesa6).
"""
import argparse

import numpy as np

# (layer, datatype): name, z bottom, z top (um, roughly the sky130 stack), colour, opacity
SKY130_STACK = [
    ((65, 20), "diff",  0.00, 0.12, "#3fae49", 1.0),
    ((66, 20), "poly",  0.33, 0.51, "#d6312b", 1.0),
    ((67, 20), "li1",   0.94, 1.04, "#6d8fd8", 1.0),
    ((67, 44), "mcon",  1.04, 1.38, "#c9c9c9", 1.0),
    ((68, 20), "met1",  1.38, 1.74, "#8c6bd6", 1.0),
    ((68, 44), "via",   1.74, 2.01, "#c9c9c9", 1.0),
    ((69, 20), "met2",  2.01, 2.37, "#e05fa6", 1.0),
    ((69, 44), "via2",  2.37, 2.79, "#c9c9c9", 1.0),
    ((70, 20), "met3",  2.79, 3.63, "#2fc3d6", 1.0),
    ((70, 44), "via3",  3.63, 4.02, "#c9c9c9", 1.0),
    ((71, 20), "met4",  4.02, 4.87, "#f29b38", 0.85),
    ((71, 44), "via4",  4.87, 5.37, "#c9c9c9", 1.0),
    ((72, 20), "met5",  5.37, 6.63, "#e8c547", 0.75),
]


def layer_mesh(polys, z0, z1, zscale):
    import pyvista as pv
    pts, faces, off = [], [], 0
    for p in polys:
        n = len(p)
        if n < 3:
            continue
        pts.append(np.column_stack([p, np.full(n, z0 * zscale)]))
        faces.append(np.concatenate([[n], np.arange(off, off + n)]))
        off += n
    if not pts:
        return None
    mesh = pv.PolyData(np.vstack(pts), np.concatenate(faces)).triangulate()
    return mesh.extrude((0, 0, (z1 - z0) * zscale), capping=True)


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("gds")
    ap.add_argument("-o", "--out", default="layout_3d.png")
    ap.add_argument("--region", nargs=4, type=float, metavar=("X0", "Y0", "X1", "Y1"),
                    help="only render this window (um)")
    ap.add_argument("--size", nargs=2, type=int, default=(2400, 900), metavar=("W", "H"))
    ap.add_argument("--zscale", type=float, default=3.0,
                    help="vertical exaggeration (the real stack is only ~7 um tall)")
    ap.add_argument("--elevation", type=float, default=32.0, help="camera elevation (deg)")
    ap.add_argument("--azimuth", type=float, default=-55.0, help="camera azimuth (deg)")
    ap.add_argument("--zoom", type=float, default=1.0)
    ap.add_argument("--skip", nargs="*", default=[], help="layer names to leave out, e.g. met5")
    ap.add_argument("--background", default="#0d1117")
    ap.add_argument("--title", help="overlay a title on the left (banner style)")
    ap.add_argument("--tagline", default="", help="accent-coloured line under the title")
    ap.add_argument("--subtitle", default="", help="smaller text under the title")
    ap.add_argument("--caption", default="", help="small caption, bottom right")
    args = ap.parse_args()

    import gdstk
    import pyvista as pv

    lib = gdstk.read_gds(args.gds)
    top = lib.top_level()[0]
    (bx0, by0), (bx1, by1) = top.bounding_box()
    if args.region:
        bx0, by0, bx1, by1 = args.region

    # Flatten once and bucket polygons by layer, clipped to the region
    wanted = {spec[0]: spec for spec in SKY130_STACK if spec[1] not in args.skip}
    by_layer = {k: [] for k in wanted}
    for poly in top.get_polygons():
        key = (poly.layer, poly.datatype)
        if key not in wanted:
            continue
        p = poly.points
        if (p[:, 0].max() < bx0 or p[:, 0].min() > bx1 or
                p[:, 1].max() < by0 or p[:, 1].min() > by1):
            continue
        if args.region:
            clipped = gdstk.boolean(poly, gdstk.rectangle((bx0, by0), (bx1, by1)), "and")
            by_layer[key].extend(c.points for c in clipped)
        else:
            by_layer[key].append(p)

    pl = pv.Plotter(off_screen=True, window_size=list(args.size))
    pl.set_background(args.background)
    pl.enable_depth_peeling()
    pl.enable_anti_aliasing("ssaa")

    # Silicon substrate slab under everything
    w, h = bx1 - bx0, by1 - by0
    pad = 0.02 * max(w, h)
    sub = pv.Box(bounds=(bx0 - pad, bx1 + pad, by0 - pad, by1 + pad,
                         -0.6 * args.zscale, -0.01))
    pl.add_mesh(sub, color="#3a3f4a", specular=0.2)

    for key, (_, name, z0, z1, color, opacity) in wanted.items():
        mesh = layer_mesh(by_layer[key], z0, z1, args.zscale)
        if mesh is None:
            continue
        print(f"{name:5s} {len(by_layer[key]):7d} polygons")
        pl.add_mesh(mesh, color=color, opacity=opacity, specular=0.35,
                    specular_power=20, smooth_shading=False)

    # Camera looking at the centre of the region from (azimuth, elevation)
    cx, cy = (bx0 + bx1) / 2, (by0 + by1) / 2
    dist = 1.6 * max(w, h)
    el, az = np.radians(args.elevation), np.radians(args.azimuth)
    pl.camera.focal_point = (cx, cy, 0)
    pl.camera.position = (cx + dist * np.cos(el) * np.cos(az),
                          cy + dist * np.cos(el) * np.sin(az),
                          dist * np.sin(el))
    pl.camera.up = (0, 0, 1)
    pl.camera.view_angle = 30
    pl.camera.zoom(args.zoom)
    from PIL import Image
    img = Image.fromarray(pl.screenshot(return_img=True))
    if args.title or args.caption:
        img = overlay_text(img, args.title, args.tagline, args.subtitle, args.caption,
                           args.background)
    img.save(args.out, quality=88)   # .png or .webp, chosen by the extension
    print(f"Wrote {args.out}")


def overlay_text(img, title, tagline, subtitle, caption, background):
    """Fade the left side into the background and write text on it."""
    from PIL import Image, ImageColor, ImageDraw, ImageFont

    def font(names, size):
        for n in names:
            try:
                return ImageFont.truetype(n, size)
            except OSError:
                continue
        return ImageFont.load_default()

    img = img.convert("RGB")
    W, H = img.size
    bg = ImageColor.getrgb(background)
    if title:
        # Horizontal gradient: solid background on the left, clear by 65% width
        mask = Image.linear_gradient("L").rotate(90, expand=True).resize((W, H))
        ramp = mask.point(lambda v: int(255 * min(1.0, max(0.0, (1.0 - v / 255.0 - 0.35) / 0.4))))
        img = Image.composite(Image.new("RGB", (W, H), bg), img, ramp)
    d = ImageDraw.Draw(img)
    bold = ["/usr/share/fonts/opentype/inter/InterDisplay-Bold.otf", "DejaVuSans-Bold.ttf"]
    reg = ["/usr/share/fonts/opentype/inter/Inter-Regular.otf", "DejaVuSans.ttf"]
    x = int(0.05 * W)
    if title:
        y = int(H * (0.24 if tagline else 0.30))
        ft = font(bold, int(H * 0.12))
        d.text((x, y), title, font=ft, fill=(240, 246, 252))
        y += int(H * 0.17)
        if tagline:
            fa = font(bold, int(H * 0.06))
            d.text((x, y), tagline, font=fa, fill=(88, 196, 220))
            y += int(H * 0.10)
        fs = font(reg, int(H * 0.042))
        for line in subtitle.split("\\n"):
            d.text((x, y), line, font=fs, fill=(173, 186, 199))
            y += int(H * 0.06)
    if caption:
        fc = font(reg, int(H * 0.028))
        tw = d.textlength(caption, font=fc)
        x0, y0 = W - tw - int(0.02 * W), H - int(H * 0.06)
        pad = int(H * 0.012)
        d.rectangle((x0 - pad, y0 - pad, x0 + tw + pad, y0 + int(H * 0.028) + 2 * pad),
                    fill=bg)
        d.text((x0, y0), caption, font=fc, fill=(139, 148, 158))
    return img


if __name__ == "__main__":
    main()
