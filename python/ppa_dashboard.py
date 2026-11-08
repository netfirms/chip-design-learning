#!/usr/bin/env python3
"""ppa_dashboard.py -- collect area, timing and power for every design and
draw them as one HTML dashboard.

Reads what the flow already writes under designs/<name>/build/:

  synth_sky130_stat.txt          Yosys `stat -liberty` (cell count, cell area, cell mix)
  orfs/logs/sky130hd/<top>/base/*.json
                                 OpenROAD-flow-scripts metrics (after `make pnr`):
                                 die/core area, utilisation, setup/hold slack, power

and the clock period from designs/<name>/orfs/constraint.sdc.

Writes into the output folder (default: ppa/):

  index.html     the dashboard (charts are inline SVG, no JavaScript libraries)
  metrics.json   every number on the page, one entry per design
  metrics.csv    the same as a table

Usage:
  python3 python/ppa_dashboard.py                 # scan designs/, write ppa/
  python3 python/ppa_dashboard.py --out site      # another output folder

Designs that have only been synthesised still appear; the timing and power
charts fill in once `make pnr` has run for them. Only the standard library is
used, so it runs anywhere Python 3.8+ does.
"""
import argparse
import csv
import datetime
import glob
import html
import json
import os
import re
import subprocess

REPO = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))

# Course order (docs/learning-path.md); anything else is appended alphabetically
ORDER = ["counter", "pwm", "fir", "iir", "fft", "riscv", "tt_fir", "aes"]

# How standard cells are grouped in the "cell mix" chart. First match wins.
CELL_GROUPS = [
    ("Flip-flops", re.compile(r"__(df|dl|sdf|edf)")),
    ("Adders & XOR", re.compile(r"__(xor|xnor|maj|fa|ha)\d")),
    ("Multiplexers", re.compile(r"__mux")),
    ("Inverters & buffers", re.compile(r"__(inv|clkinv|buf|clkbuf|lpflow_isobufsrc)")),
    ("Logic gates", re.compile(r"__(and|nand|or|nor|a\d|o\d|lpflow_inputiso)")),
]
OTHER = "Other (tie, fill, ...)"
GROUP_NAMES = [g for g, _ in CELL_GROUPS] + [OTHER]


# ---------------------------------------------------------------------------
# Collecting
# ---------------------------------------------------------------------------
def read_top(design_dir):
    """TOP from the design Makefile (`TOP := fir`), falling back to the folder name."""
    try:
        with open(os.path.join(design_dir, "Makefile")) as f:
            m = re.search(r"^TOP\s*:?=\s*(\S+)", f.read(), re.M)
            if m:
                return m.group(1)
    except OSError:
        pass
    return os.path.basename(design_dir)


def read_clock_period(design_dir):
    """Clock period in ns from `set clk_period 10.0` or `create_clock -period 10`."""
    try:
        with open(os.path.join(design_dir, "orfs", "constraint.sdc")) as f:
            sdc = f.read()
    except OSError:
        return None
    m = re.search(r"set\s+clk_period\s+([\d.]+)", sdc) or re.search(
        r"create_clock[^\n]*-period\s+([\d.]+)", sdc)
    return float(m.group(1)) if m else None


def read_synth(design_dir):
    """Parse Yosys `stat -liberty` output: cells, area and the cell mix."""
    path = os.path.join(design_dir, "build", "synth_sky130_stat.txt")
    try:
        with open(path) as f:
            text = f.read()
    except OSError:
        return None

    out = {"cells": None, "area_um2": None, "flops": 0,
           "mix": {g: 0 for g in GROUP_NAMES}}
    m = re.search(r"Number of cells:\s+(\d+)", text)
    if m:
        out["cells"] = int(m.group(1))
    m = re.search(r"Chip area for (?:top )?module '[^']*':\s+([\d.]+)", text)
    if m:
        out["area_um2"] = float(m.group(1))

    # Cell lines look like "  sky130_fd_sc_hd__dfrtp_1   314" (Yosys <= 0.4x) or
    # "  314  1.2E+04  sky130_fd_sc_hd__dfrtp_1" (newer Yosys). Accept both.
    for line in text.splitlines():
        m = re.match(r"\s+(sky130\w+)\s+(\d+)\s*$", line) or re.match(
            r"\s+(\d+)\s+[\d.Ee+-]+\s+(sky130\w+)\s*$", line)
        if not m:
            continue
        a, b = m.groups()
        cell, n = (a, int(b)) if a.startswith("sky130") else (b, int(a))
        group = next((g for g, rx in CELL_GROUPS if rx.search(cell)), OTHER)
        out["mix"][group] += n
        if group == "Flip-flops":
            out["flops"] += n
    return out


def first(metrics, *keys):
    for k in keys:
        v = metrics.get(k)
        if isinstance(v, (int, float)):
            return float(v)
    return None


def read_pnr(design_dir, top):
    """Merge every ORFS metrics JSON for the design; later steps override earlier ones."""
    logs = glob.glob(os.path.join(design_dir, "build", "orfs", "logs", "*", top, "*", "*.json"))
    if not logs:
        return None
    metrics = {}
    for path in sorted(logs):
        try:
            with open(path) as f:
                data = json.load(f)
        except (OSError, ValueError):
            continue
        if isinstance(data, dict):
            metrics.update({k: v for k, v in data.items() if not isinstance(v, (dict, list))})
    if not any(k.startswith("finish__") for k in metrics):
        return None  # the flow did not reach the final report

    def power_w(part):
        return first(metrics, f"finish__power__{part}__total")

    return {
        "die_area_um2": first(metrics, "finish__design__die__area"),
        "core_area_um2": first(metrics, "finish__design__core__area"),
        "cell_area_um2": first(metrics, "finish__design__instance__area"),
        "instances": first(metrics, "finish__design__instance__count"),
        "utilization": first(metrics, "finish__design__instance__utilization"),
        "setup_ws_ns": first(metrics, "finish__timing__setup__ws"),
        "setup_tns_ns": first(metrics, "finish__timing__setup__tns"),
        "hold_ws_ns": first(metrics, "finish__timing__hold__ws"),
        "power_total_w": first(metrics, "finish__power__total"),
        "power_internal_w": power_w("internal"),
        "power_switching_w": power_w("switching"),
        "power_leakage_w": power_w("leakage"),
        "drc_errors": first(metrics, "finish__route__drc_errors", "detailedroute__route__drc_errors"),
        "wirelength_um": first(metrics, "detailedroute__route__wirelength"),
    }


def collect(designs_root):
    dirs = [d for d in glob.glob(os.path.join(designs_root, "*")) if os.path.isdir(d)]
    names = sorted((os.path.basename(d) for d in dirs),
                   key=lambda n: (ORDER.index(n) if n in ORDER else len(ORDER), n))
    rows = []
    for name in names:
        d = os.path.join(designs_root, name)
        top = read_top(d)
        row = {"design": name, "top": top, "clock_period_ns": read_clock_period(d),
               "synth": read_synth(d), "pnr": read_pnr(d, top)}
        p = row["pnr"]
        if p and p["setup_ws_ns"] is not None and row["clock_period_ns"]:
            # Worst setup slack says how much shorter the period could be.
            # ORFS clips positive slack to 0 in some versions, so treat this as a lower bound.
            crit = row["clock_period_ns"] - p["setup_ws_ns"]
            row["fmax_mhz"] = 1000.0 / crit if crit > 0 else None
        else:
            row["fmax_mhz"] = None
        if row["synth"] or row["pnr"]:
            rows.append(row)
    return rows


# ---------------------------------------------------------------------------
# Drawing: small inline-SVG charts styled by CSS variables (light + dark)
# ---------------------------------------------------------------------------
ESC = html.escape


def fmt(v, unit="", digits=3):
    if v is None:
        return "–"
    a = abs(v)
    if float(v).is_integer() and a >= 1 and not unit:
        return f"{int(v):,}"
    if a >= 1e5:
        s = f"{v:,.0f}"
    elif a >= 100:
        s = f"{v:,.0f}" if digits <= 3 else f"{v:,.1f}"
    elif a >= 1:
        s = f"{v:.{max(digits - 1, 1)}g}" if a < 10 else f"{v:.1f}"
    else:
        s = f"{v:.{digits}g}"
    return f"{s} {unit}".strip()


def nice_max(v):
    if v <= 0:
        return 1.0
    import math
    e = 10 ** math.floor(math.log10(v))
    for m in (1, 1.2, 1.5, 2, 2.5, 3, 4, 5, 6, 8, 10):
        if v <= m * e:
            return m * e
    return 10 * e


LABEL_W, VALUE_W, BAR_H, GAP, PAD_T = 70, 86, 20, 12, 8
CHART_W = 520


def hbar_chart(items, unit, title, series_class="s1", zero_center=False):
    """One series of horizontal bars. items: [(label, value, tooltip)]. None = no data."""
    items = [(l, v, t) for l, v, t in items]
    plot_w = CHART_W - LABEL_W - VALUE_W
    vals = [v for _, v, _ in items if v is not None]
    if not vals:
        return '<p class="empty">No data yet: run <code>make pnr</code> for a design.</p>'
    lo = min(0.0, min(vals))
    hi = nice_max(max(0.0, max(vals))) if max(vals) > 0 else 0.0
    if lo < 0:
        lo = -nice_max(-lo)
    span = (hi - lo) or 1.0
    x0 = LABEL_W + plot_w * (-lo / span)
    h = PAD_T + len(items) * (BAR_H + GAP) + 18
    out = [f'<svg viewBox="0 0 {CHART_W} {h}" role="img" aria-label="{ESC(title)}">']
    # recessive grid: 0, mid, max
    for frac in (0.0, 0.5, 1.0):
        gv = lo + span * frac
        gx = LABEL_W + plot_w * frac
        out.append(f'<line class="grid" x1="{gx:.1f}" x2="{gx:.1f}" y1="{PAD_T - 4}" y2="{h - 18}"/>')
        out.append(f'<text class="axis" x="{gx:.1f}" y="{h - 4}" text-anchor="middle">{ESC(fmt(gv))}</text>')
    for i, (label, v, tip) in enumerate(items):
        y = PAD_T + i * (BAR_H + GAP)
        out.append(f'<g class="row"><title>{ESC(tip)}</title>')
        out.append(f'<rect class="hit" x="0" y="{y - GAP / 2}" width="{CHART_W}" height="{BAR_H + GAP}"/>')
        out.append(f'<text class="label" x="{LABEL_W - 10}" y="{y + BAR_H / 2 + 4}" text-anchor="end">{ESC(label)}</text>')
        if v is None:
            out.append(f'<text class="muted" x="{x0 + 6:.1f}" y="{y + BAR_H / 2 + 4}">not placed &amp; routed yet</text>')
        else:
            x1 = LABEL_W + plot_w * ((v - lo) / span)
            xa, xb = sorted((x0, x1))
            w = max(xb - xa, 1.5)
            cls = series_class
            if zero_center:
                cls = "good" if v >= 0 else "bad"
            # 4px rounded data end, square at the baseline
            r = min(4, w / 2)
            if v >= 0:
                d = (f"M{xa:.1f},{y} H{xa + w - r:.1f} Q{xa + w:.1f},{y} {xa + w:.1f},{y + r} "
                     f"V{y + BAR_H - r} Q{xa + w:.1f},{y + BAR_H} {xa + w - r:.1f},{y + BAR_H} H{xa:.1f} Z")
            else:
                d = (f"M{xb:.1f},{y} H{xa + r:.1f} Q{xa:.1f},{y} {xa:.1f},{y + r} "
                     f"V{y + BAR_H - r} Q{xa:.1f},{y + BAR_H} {xa + r:.1f},{y + BAR_H} H{xb:.1f} Z")
            out.append(f'<path class="bar {cls}" d="{d}"/>')
            out.append(f'<text class="value" x="{CHART_W - 4}" y="{y + BAR_H / 2 + 4}" text-anchor="end">{ESC(fmt(v, unit))}</text>')
        out.append("</g>")
    out.append(f'<line class="baseline" x1="{x0:.1f}" x2="{x0:.1f}" y1="{PAD_T - 4}" y2="{h - 18}"/>')
    out.append("</svg>")
    return "\n".join(out)


def stacked_chart(rows, parts, title, unit="", percent=False):
    """100% (or absolute) stacked horizontal bars. rows: [(label, {part: value})]."""
    plot_w = CHART_W - LABEL_W - VALUE_W
    totals = [sum(v for v in vals.values() if v) if vals else 0 for _, vals in rows]
    if not any(totals):
        return '<p class="empty">No data yet: run <code>make pnr</code> for a design.</p>'
    hi = 100.0 if percent else nice_max(max(totals))
    h = PAD_T + len(rows) * (BAR_H + GAP) + 18
    out = [f'<svg viewBox="0 0 {CHART_W} {h}" role="img" aria-label="{ESC(title)}">']
    for frac in (0.0, 0.5, 1.0):
        gx = LABEL_W + plot_w * frac
        lab = f"{hi * frac:.0f}%" if percent else fmt(hi * frac)
        out.append(f'<line class="grid" x1="{gx:.1f}" x2="{gx:.1f}" y1="{PAD_T - 4}" y2="{h - 18}"/>')
        out.append(f'<text class="axis" x="{gx:.1f}" y="{h - 4}" text-anchor="middle">{lab}</text>')
    for i, ((label, vals), total) in enumerate(zip(rows, totals)):
        y = PAD_T + i * (BAR_H + GAP)
        out.append(f'<text class="label" x="{LABEL_W - 10}" y="{y + BAR_H / 2 + 4}" text-anchor="end">{ESC(label)}</text>')
        if not total:
            out.append(f'<text class="muted" x="{LABEL_W + 6}" y="{y + BAR_H / 2 + 4}">not placed &amp; routed yet</text>')
            continue
        x = LABEL_W
        for j, part in enumerate(parts):
            v = (vals or {}).get(part) or 0
            if v <= 0:
                continue
            share = v / total
            w = plot_w * ((share * 100) / hi if percent else v / hi)
            tip = f"{label} · {part}: {fmt(v, unit)} ({share * 100:.1f}%)"
            # 2px surface gap between segments
            out.append(f'<rect class="bar s{j + 1}" x="{x:.1f}" y="{y}" width="{max(w - 2, 1):.1f}" height="{BAR_H}" rx="1"><title>{ESC(tip)}</title></rect>')
            x += w
        right = "100%" if percent else fmt(total, unit)
        out.append(f'<text class="value" x="{CHART_W - 4}" y="{y + BAR_H / 2 + 4}" text-anchor="end">{ESC(right)}</text>')
    out.append("</svg>")
    legend = "".join(f'<span><i class="sw s{j + 1}"></i>{ESC(p)}</span>' for j, p in enumerate(parts))
    return f'<div class="legend">{legend}</div>\n' + "\n".join(out)


# ---------------------------------------------------------------------------
# Page
# ---------------------------------------------------------------------------
CSS = """
:root{color-scheme:light;
 --surface:#fcfcfb;--card:#ffffff;--border:#e4e3df;--text-primary:#0b0b0b;--text-secondary:#52514e;--text-muted:#7a7974;
 --grid:#ecebe7;--axis:#8a8984;
 --s1:#2a78d6;--s2:#eb6834;--s3:#1baf7a;--s4:#eda100;--s5:#e87ba4;--s6:#008300;
 --good:#2a78d6;--bad:#e34948}
@media (prefers-color-scheme:dark){:root:not([data-theme="light"]){color-scheme:dark;
 --surface:#141413;--card:#1a1a19;--border:#2e2e2c;--text-primary:#f0efec;--text-secondary:#c3c2b7;--text-muted:#8f8e86;
 --grid:#2a2a28;--axis:#6f6e68;
 --s1:#3987e5;--s2:#d95926;--s3:#199e70;--s4:#c98500;--s5:#d55181;--s6:#008300;--good:#3987e5;--bad:#e66767}}
:root[data-theme="dark"]{color-scheme:dark;
 --surface:#141413;--card:#1a1a19;--border:#2e2e2c;--text-primary:#f0efec;--text-secondary:#c3c2b7;--text-muted:#8f8e86;
 --grid:#2a2a28;--axis:#6f6e68;
 --s1:#3987e5;--s2:#d95926;--s3:#199e70;--s4:#c98500;--s5:#d55181;--s6:#008300;--good:#3987e5;--bad:#e66767}
*{box-sizing:border-box}
body{margin:0;background:var(--surface);color:var(--text-primary);
 font:15px/1.5 system-ui,-apple-system,"Segoe UI",Roboto,sans-serif}
main{max-width:1180px;margin:0 auto;padding:28px 16px 48px}
h1{font-size:26px;margin:0 0 4px}h2{font-size:17px;margin:0 0 2px}
.sub{color:var(--text-secondary);margin:0 0 20px}
.tiles{display:grid;grid-template-columns:repeat(auto-fit,minmax(160px,1fr));gap:12px;margin-bottom:20px}
.tile{background:var(--card);border:1px solid var(--border);border-radius:10px;padding:12px 14px}
.tile b{display:block;font-size:22px;font-variant-numeric:tabular-nums}
.tile span{color:var(--text-secondary);font-size:13px}
.grid2{display:grid;grid-template-columns:repeat(auto-fit,minmax(min(100%,520px),1fr));gap:16px}
.card{background:var(--card);border:1px solid var(--border);border-radius:12px;padding:16px 18px;min-width:0}
.card p.note{color:var(--text-secondary);font-size:13px;margin:0 0 10px}
svg{width:100%;height:auto;display:block;font-size:13px}
svg .grid{stroke:var(--grid);stroke-width:1}
svg .baseline{stroke:var(--axis);stroke-width:1}
svg .axis{fill:var(--text-muted);font-size:11px}
svg .label{fill:var(--text-primary)}
svg .value{fill:var(--text-secondary);font-variant-numeric:tabular-nums}
svg .muted{fill:var(--text-muted);font-style:italic}
svg .hit{fill:transparent}
svg .row:hover .hit{fill:var(--grid)}
svg .bar{transition:opacity .15s}
svg rect.bar:hover,svg .row:hover .bar{opacity:.8}
.s1{fill:var(--s1);background:var(--s1)}.s2{fill:var(--s2);background:var(--s2)}.s3{fill:var(--s3);background:var(--s3)}
.s4{fill:var(--s4);background:var(--s4)}.s5{fill:var(--s5);background:var(--s5)}.s6{fill:var(--s6);background:var(--s6)}
.good{fill:var(--good)}.bad{fill:var(--bad)}
.legend{display:flex;flex-wrap:wrap;gap:6px 14px;color:var(--text-secondary);font-size:13px;margin-bottom:8px}
.legend span{display:inline-flex;align-items:center;gap:6px}
.legend .sw{width:10px;height:10px;border-radius:2px;display:inline-block}
.empty{color:var(--text-muted);font-style:italic}
.tablewrap{overflow-x:auto;margin-top:16px}
table{border-collapse:collapse;width:100%;font-size:13px;font-variant-numeric:tabular-nums}
th,td{padding:7px 10px;border-bottom:1px solid var(--border);text-align:right;white-space:nowrap}
th:first-child,td:first-child{text-align:left}
th{color:var(--text-secondary);font-weight:600}
footer{color:var(--text-muted);font-size:12px;margin-top:22px}
a{color:var(--s1)}
code{font-size:12.5px}
"""


def build_html(rows, meta):
    names = [r["design"] for r in rows]

    def s(r):
        return r["synth"] or {}

    def p(r):
        return r["pnr"] or {}

    area = hbar_chart(
        [(r["design"], s(r).get("area_um2"),
          f'{r["design"]}: {fmt(s(r).get("area_um2"), "µm²")} of sky130 cells, {s(r).get("cells") or "?"} cells')
         for r in rows], "µm²", "Synthesised cell area")
    die = hbar_chart(
        [(r["design"], p(r).get("die_area_um2"),
          f'{r["design"]}: die {fmt(p(r).get("die_area_um2"), "µm²")}, '
          f'utilisation {fmt((p(r).get("utilization") or 0) * 100, "%")}')
         for r in rows], "µm²", "Die area after place and route")
    mix = stacked_chart(
        [(r["design"], s(r).get("mix")) for r in rows], GROUP_NAMES,
        "Cell mix", unit="cells", percent=True)
    slack = hbar_chart(
        [(r["design"], p(r).get("setup_ws_ns"),
          f'{r["design"]}: worst setup slack {fmt(p(r).get("setup_ws_ns"), "ns")} '
          f'at a {fmt(r["clock_period_ns"], "ns")} clock')
         for r in rows], "ns", "Worst setup slack", zero_center=True)
    fmax = hbar_chart(
        [(r["design"], r.get("fmax_mhz"),
          f'{r["design"]}: about {fmt(r.get("fmax_mhz"), "MHz")} '
          f'(target {fmt(1000 / r["clock_period_ns"] if r["clock_period_ns"] else None, "MHz")})')
         for r in rows], "MHz", "Estimated maximum clock", series_class="s1")
    power = stacked_chart(
        [(r["design"], {"Internal": (p(r).get("power_internal_w") or 0) * 1e3,
                        "Switching": (p(r).get("power_switching_w") or 0) * 1e3,
                        "Leakage": (p(r).get("power_leakage_w") or 0) * 1e3} if r["pnr"] else None)
         for r in rows], ["Internal", "Switching", "Leakage"], "Power", unit="mW")

    synthed = [r for r in rows if r["synth"]]
    routed = [r for r in rows if r["pnr"]]
    total_cells = sum(s(r).get("cells") or 0 for r in synthed)
    total_area = sum(s(r).get("area_um2") or 0 for r in synthed)
    met = [r for r in routed if (p(r).get("setup_ws_ns") or 0) >= 0]
    tiles = [
        (str(len(rows)), "designs"),
        (f"{total_cells:,}", "sky130 cells in total"),
        (fmt(total_area / 1e6, "mm²"), "total cell area"),
        (f"{len(routed)} / {len(rows)}", "placed & routed"),
        (f"{len(met)} / {len(routed)}" if routed else "–", "meet timing"),
    ]
    tiles_html = "".join(f'<div class="tile"><b>{ESC(v)}</b><span>{ESC(k)}</span></div>' for v, k in tiles)

    cols = ["Design", "Cells", "Flip-flops", "Cell area µm²", "Die area µm²", "Util %",
            "Clock ns", "Setup slack ns", "Hold slack ns", "fmax MHz", "Power mW", "DRC"]
    trs = []
    for r in rows:
        S, P = s(r), p(r)
        cells = [r["design"], S.get("cells"), S.get("flops"), S.get("area_um2"), P.get("die_area_um2"),
                 (P.get("utilization") or 0) * 100 if P.get("utilization") is not None else None,
                 r["clock_period_ns"], P.get("setup_ws_ns"), P.get("hold_ws_ns"), r.get("fmax_mhz"),
                 P["power_total_w"] * 1e3 if P.get("power_total_w") is not None else None,
                 P.get("drc_errors")]
        tds = "".join(f"<td>{ESC(c if isinstance(c, str) else fmt(c))}</td>" for c in cells)
        trs.append(f"<tr>{tds}</tr>")
    table = ("<table><thead><tr>" + "".join(f"<th>{c}</th>" for c in cols) +
             "</tr></thead><tbody>" + "".join(trs) + "</tbody></table>")

    commit = meta.get("commit")
    commit_html = ""
    if commit:
        url = meta.get("commit_url")
        commit_html = f' · commit <a href="{ESC(url)}">{ESC(commit[:7])}</a>' if url else f" · commit {ESC(commit[:7])}"

    def card(title, note, body):
        return f'<section class="card"><h2>{title}</h2><p class="note">{note}</p>{body}</section>'

    return f"""<!doctype html>
<html lang="en"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>PPA Dashboard</title>
<style>{CSS}</style></head>
<body><main>
<h1>PPA dashboard</h1>
<p class="sub">Power, performance and area of every course design on SkyWater sky130, rebuilt by CI on each change.
Hover a bar for details. Hardware is the new Software.</p>
<div class="tiles">{tiles_html}</div>
<div class="grid2">
{card("Area: synthesised cells", "Sum of sky130 standard cell areas reported by Yosys. Bigger datapaths (multipliers, FFT butterflies) dominate.", area)}
{card("Area: die after place &amp; route", "The die includes routing space; CORE_UTILIZATION in orfs/config.mk sets how full the core is.", die)}
{card("Cell mix", "What the gates are spent on. DSP designs are mostly adders; control logic is mostly gates and flip-flops.", mix)}
{card("Timing: worst setup slack", "Positive (blue) means the design meets its clock; negative (red) means a path is too slow.", slack)}
{card("Performance: estimated fmax", "1 / (clock period − worst slack). Some OpenROAD versions clip positive slack to 0, so read this as a lower bound.", fmax)}
{card("Power after place &amp; route", "OpenROAD estimate at the SDC clock with default switching activity. Internal + switching scale with frequency; leakage does not.", power)}
</div>
<section class="card tablewrap"><h2>All numbers</h2>
<p class="note">Also as <a href="metrics.json">metrics.json</a> and <a href="metrics.csv">metrics.csv</a>. “–” means that step has not run.</p>
{table}</section>
<footer>Generated {ESC(meta["generated"])}{commit_html} by <code>python/ppa_dashboard.py</code>.</footer>
</main></body></html>
"""


def flat_row(r):
    out = {"design": r["design"], "top": r["top"], "clock_period_ns": r["clock_period_ns"],
           "fmax_mhz": r.get("fmax_mhz")}
    for k, v in (r["synth"] or {}).items():
        if k == "mix":
            for g, n in v.items():
                out["cells_" + re.sub(r"\W+", "_", g.lower()).strip("_")] = n
        else:
            out["synth_" + k] = v
    for k, v in (r["pnr"] or {}).items():
        out["pnr_" + k] = v
    return out


def markdown_summary(rows):
    """A Markdown table for the GitHub Actions job summary."""
    lines = ["| Design | Cells | Cell area µm² | Die area µm² | Setup slack ns | fmax MHz | Power mW |",
             "|---|--:|--:|--:|--:|--:|--:|"]
    for r in rows:
        S, P = r["synth"] or {}, r["pnr"] or {}
        pw = P["power_total_w"] * 1e3 if P.get("power_total_w") is not None else None
        lines.append(f'| {r["design"]} | {fmt(S.get("cells"))} | {fmt(S.get("area_um2"))} | '
                     f'{fmt(P.get("die_area_um2"))} | {fmt(P.get("setup_ws_ns"))} | '
                     f'{fmt(r.get("fmax_mhz"))} | {fmt(pw)} |')
    return "\n".join(lines) + "\n"


def git_commit():
    sha = os.environ.get("GITHUB_SHA")
    if not sha:
        try:
            sha = subprocess.check_output(["git", "-C", REPO, "rev-parse", "HEAD"],
                                          stderr=subprocess.DEVNULL, text=True).strip()
        except (OSError, subprocess.CalledProcessError):
            sha = None
    url = None
    if sha and os.environ.get("GITHUB_REPOSITORY"):
        server = os.environ.get("GITHUB_SERVER_URL", "https://github.com")
        url = f"{server}/{os.environ['GITHUB_REPOSITORY']}/commit/{sha}"
    return sha, url


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("--designs", default=os.path.join(REPO, "designs"), help="folder with one sub-folder per design")
    ap.add_argument("--out", default=os.path.join(REPO, "ppa"), help="output folder")
    ap.add_argument("--summary", help="also append a Markdown table to this file (e.g. $GITHUB_STEP_SUMMARY)")
    args = ap.parse_args()

    rows = collect(args.designs)
    if not rows:
        raise SystemExit("No results found. Run `make check-sky130` (and `make pnr`) first.")
    sha, url = git_commit()
    meta = {"generated": datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%d %H:%M UTC"),
            "commit": sha, "commit_url": url}

    os.makedirs(args.out, exist_ok=True)
    with open(os.path.join(args.out, "index.html"), "w") as f:
        f.write(build_html(rows, meta))
    flat = [flat_row(r) for r in rows]
    with open(os.path.join(args.out, "metrics.json"), "w") as f:
        json.dump({"meta": meta, "designs": flat}, f, indent=2)
    keys = list(dict.fromkeys(k for r in flat for k in r))
    with open(os.path.join(args.out, "metrics.csv"), "w", newline="") as f:
        w = csv.DictWriter(f, fieldnames=keys)
        w.writeheader()
        w.writerows(flat)

    if args.summary:
        with open(args.summary, "a") as f:
            f.write("## PPA per design\n\n" + markdown_summary(rows))

    for r in rows:
        S, P = r["synth"] or {}, r["pnr"] or {}
        print(f'{r["design"]:>8}: {fmt(S.get("area_um2"), "um2"):>12} cells | '
              f'slack {fmt(P.get("setup_ws_ns"), "ns"):>9} | power {fmt((P.get("power_total_w") or 0) * 1e3 if P else None, "mW"):>9}')
    print(f"Wrote {os.path.join(args.out, 'index.html')}")


if __name__ == "__main__":
    main()
