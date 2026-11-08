#!/usr/bin/env python3
"""figures_riscv.py -- diagrams and plots for the RISC-V CPU deck (Module 9).

    python3 slides/figures_riscv.py     # writes slides/images/riscv_*.png

Uses the drawing helpers and colours of figures.py. The numbers come from
designs/riscv: the instruction mix and cycle counts are printed by
`make sim`, the area split from `make synth-sky130`.
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from figures import (ACCENT, ACCENT2, GREEN, GREY, RED, SOFT, arrow, box,  # noqa: E402
                     canvas, plt, save)

WARM = "#fff4e6"
MINT = "#e8f5ee"


def fig_toolchain():
    """C source to a running CPU: the software flow next to the hardware flow."""
    fig, ax = canvas(14, 4.6)
    sw = [("hello.c\nstart.S", "you write it"),
          ("gcc\nrv32i", "compile + link"),
          ("hello.elf", "machine code"),
          ("hello.hex", "one word per line"),
          ]
    x = 0.2
    for i, (name, sub) in enumerate(sw):
        fc = ACCENT if i == 0 else SOFT
        box(ax, x, 2.75, 1.75, 1.05, name, fc=fc, fs=11, bold=True, tc="white" if i == 0 else "#1d2328")
        ax.text(x + 0.875, 2.6, sub, ha="center", va="top", fontsize=9.5, color=GREY, style="italic")
        if i < len(sw) - 1:
            arrow(ax, x + 1.77, 3.27, x + 2.13, 3.27, color=ACCENT)
        x += 2.15
    ax.text(4.4, 4.15, "software flow: make firmware", ha="center", fontsize=12, color=ACCENT, fontweight="bold")

    hw = [("minirv.v", "you write it"), ("Yosys +\nOpenROAD", "make pnr"), ("6_final.gds", "the chip")]
    x = 0.2
    for i, (name, sub) in enumerate(hw):
        fc = ACCENT2 if i == 0 else WARM
        box(ax, x, 0.55, 1.75, 1.05, name, fc=fc, ec=ACCENT2, fs=11, bold=True,
            tc="white" if i == 0 else "#1d2328")
        ax.text(x + 0.875, 0.4, sub, ha="center", va="top", fontsize=9.5, color=GREY, style="italic")
        if i < len(hw) - 1:
            arrow(ax, x + 1.77, 1.07, x + 2.13, 1.07, color=ACCENT2)
        x += 2.15
    ax.text(3.3, 1.95, "hardware flow: make pnr", ha="center", fontsize=12, color=ACCENT2, fontweight="bold")

    # The testbench SoC: RAM + CPU + console
    ax.add_patch(plt.Rectangle((9.0, 0.35), 4.8, 3.9, fc="#f6f8fa", ec=GREY, lw=1.2, ls="--"))
    ax.text(11.4, 4.0, "make sim: the testbench is the computer", ha="center", fontsize=10.5, color=GREY)
    box(ax, 9.3, 2.45, 1.9, 1.15, "RAM 64 KB\n$readmemh", fc=SOFT, fs=10.5)
    box(ax, 11.7, 2.45, 1.8, 1.15, "minirv.v\nCPU", fc=ACCENT2, ec=ACCENT2, fs=12, bold=True, tc="white")
    arrow(ax, 11.25, 3.2, 11.65, 3.2, color=GREY, style="<|-|>")

    box(ax, 9.3, 0.6, 4.2, 1.35, "console 0x1000_0000\n\"Hello from minirv ...\"\nexit 0x1000_0004 · cycles 0x1000_0008",
        fc=MINT, ec=GREEN, fs=9.5)
    arrow(ax, 12.6, 2.43, 12.6, 1.97, color=GREEN)
    arrow(ax, 8.62, 3.27, 9.28, 3.1, color=ACCENT)          # hex into RAM
    ax.text(7.4, 1.07, "the same\nminirv.v runs\nin the testbench", ha="center", va="center", fontsize=9.5,
            color=ACCENT2, style="italic")
    save(fig, "riscv_toolchain.png")


def fig_formats():
    """The six RV32I instruction formats, bit fields to scale."""
    fig, ax = plt.subplots(figsize=(13, 4.6))
    ax.axis("off")
    ax.set_xlim(-2.2, 32.4)
    ax.set_ylim(-0.6, 6.8)
    imm = "#fbe3c8"
    reg = SOFT
    fixed = "#e9ecef"
    rows = [
        ("R", "add, sub, and, sll ...", [(7, "funct7", fixed), (5, "rs2", reg), (5, "rs1", reg), (3, "funct3", fixed), (5, "rd", reg), (7, "opcode", fixed)]),
        ("I", "addi, lw, jalr ...", [(12, "imm[11:0]", imm), (5, "rs1", reg), (3, "funct3", fixed), (5, "rd", reg), (7, "opcode", fixed)]),
        ("S", "sw, sh, sb", [(7, "imm[11:5]", imm), (5, "rs2", reg), (5, "rs1", reg), (3, "funct3", fixed), (5, "imm[4:0]", imm), (7, "opcode", fixed)]),
        ("B", "beq, blt ...", [(7, "imm[12|10:5]", imm), (5, "rs2", reg), (5, "rs1", reg), (3, "funct3", fixed), (5, "imm[4:1|11]", imm), (7, "opcode", fixed)]),
        ("U", "lui, auipc", [(20, "imm[31:12]", imm), (5, "rd", reg), (7, "opcode", fixed)]),
        ("J", "jal", [(20, "imm[20|10:1|11|19:12]", imm), (5, "rd", reg), (7, "opcode", fixed)]),
    ]
    for r, (name, ex, fields) in enumerate(rows):
        y = 5.6 - r * 1.0
        ax.text(-1.9, y + 0.35, name, ha="center", va="center", fontsize=15, fontweight="bold", color=ACCENT)
        x = 0
        for width, label, fc in fields:
            ax.add_patch(plt.Rectangle((x, y), width, 0.7, fc=fc, ec="#8a959d", lw=1))
            ax.text(x + width / 2, y + 0.35, label, ha="center", va="center", fontsize=9.5, family="monospace")
            x += width
        ax.text(32.2, y + 0.35, ex, ha="left", va="center", fontsize=10, color=GREY)
    for bit, xpos in ((31, 0.5), (25, 6.5), (20, 11.5), (15, 16.5), (12, 19.5), (7, 24.5), (0, 31.5)):
        ax.text(xpos, 6.5, str(bit), ha="center", fontsize=9, color=GREY)
    ax.text(16, -0.45, "rs1, rs2, rd sit in the same bits in every format, so the register file can be read before decode finishes. "
            "The sign bit of every immediate is bit 31.", ha="center", fontsize=10, color=ACCENT)
    ax.set_xlim(-2.2, 38)
    save(fig, "riscv_formats.png")


def fig_datapath():
    """Block diagram of minirv: what each part of minirv.v becomes."""
    fig, ax = canvas(14, 6.6)
    # memory interface on the left (off chip)
    ax.add_patch(plt.Rectangle((0.15, 0.35), 1.45, 5.6, fc="#f6f8fa", ec=GREY, lw=1.2, ls="--"))
    ax.text(0.875, 5.75, "memory\n(off chip)", ha="center", va="top", fontsize=10.5, color=GREY)
    ax.text(0.875, 3.1, "64 KB\nprogram\nand data", ha="center", va="center", fontsize=10, color=GREY)

    # flip-flops (orange) and logic (blue)
    box(ax, 2.3, 4.5, 1.5, 0.9, "pc", fc=WARM, ec=ACCENT2, fs=12, bold=True)
    box(ax, 2.3, 2.75, 1.5, 0.9, "instr", fc=WARM, ec=ACCENT2, fs=12, bold=True)
    box(ax, 2.3, 1.25, 1.5, 1.0, "state\nFETCH EXEC\nMEM TRAP", fc=MINT, ec=GREEN, fs=9.5)
    box(ax, 4.4, 2.5, 1.7, 1.4, "decode\n+ immediates", fs=11)
    box(ax, 4.4, 4.5, 1.7, 0.9, "next pc", fs=11)
    box(ax, 6.7, 2.3, 2.0, 1.8, "register file\nx1..x31\n31 x 32 flip-flops", fc=WARM, ec=ACCENT2, fs=10.5)
    box(ax, 6.7, 4.5, 1.6, 0.9, "branch\ncompare", fs=10)
    box(ax, 9.4, 2.7, 1.7, 1.4, "ALU\n+ - & | ^\n<< >> <", fs=11)
    box(ax, 9.4, 0.45, 1.7, 1.25, "load / store\nbyte lanes", fs=10.5)
    box(ax, 11.8, 2.3, 1.8, 1.8, "rd value\nselect", fs=10.5)

    # fetch: pc -> memory -> instr -> decode -> register file -> ALU -> rd select
    arrow(ax, 2.28, 4.95, 1.62, 4.95, color=GREY)
    ax.text(1.95, 5.5, "mem_addr", ha="center", fontsize=8.5, color=GREY)
    arrow(ax, 1.62, 3.2, 2.28, 3.2, color=GREY)
    ax.text(1.95, 2.45, "mem_rdata", ha="center", fontsize=8.5, color=GREY)
    arrow(ax, 3.8, 3.2, 4.38, 3.2, color=ACCENT)
    arrow(ax, 6.1, 3.45, 6.68, 3.45, color=ACCENT, text="rs1 rs2", toff=(0, 0.08), fs=8.5)
    arrow(ax, 8.7, 3.6, 9.38, 3.6, color=ACCENT)
    arrow(ax, 11.1, 3.4, 11.78, 3.4, color=ACCENT)
    # immediate to the ALU, under the register file
    ax.plot([6.1, 6.4, 6.4, 9.0, 9.0], [2.75, 2.75, 1.95, 1.95, 3.0], color=ACCENT, lw=1.5)
    arrow(ax, 9.0, 3.0, 9.38, 3.0, color=ACCENT)
    ax.text(7.7, 2.0, "imm", ha="center", va="bottom", fontsize=8.5, color=ACCENT)
    # write back, over the top
    ax.plot([12.7, 12.7, 8.5, 8.5], [4.12, 5.9, 5.9, 4.6], color=ACCENT2, lw=1.6)
    arrow(ax, 8.5, 4.6, 8.5, 4.12, color=ACCENT2)
    ax.text(10.6, 5.97, "write rd", ha="center", fontsize=9.5, color=ACCENT2)
    # branches and jumps: register file -> compare -> next pc -> pc
    arrow(ax, 7.5, 4.1, 7.5, 4.48, color=ACCENT)
    arrow(ax, 6.68, 4.95, 6.12, 4.95, color=ACCENT, text="taken?", toff=(0, 0.08), fs=8.5)
    arrow(ax, 4.38, 4.95, 3.82, 4.95, color=ACCENT2)
    # loads and stores
    ax.plot([8.0, 8.0], [2.28, 1.1], color=ACCENT, lw=1.5)
    arrow(ax, 8.0, 1.1, 9.38, 1.1, color=ACCENT, text="address, data", toff=(0, 0.08), fs=8.5)
    ax.plot([11.1, 12.7], [1.1, 1.1], color=ACCENT, lw=1.5)
    arrow(ax, 12.7, 1.1, 12.7, 2.28, color=ACCENT)
    ax.text(11.9, 1.17, "load data", ha="center", va="bottom", fontsize=8.5, color=ACCENT)
    ax.plot([10.25, 10.25, 1.62], [0.43, 0.6, 0.6], color=GREY, lw=1.5)
    arrow(ax, 2.2, 0.6, 1.62, 0.6, color=GREY)
    ax.text(5.6, 0.67, "mem_addr, mem_wdata, mem_wstrb", ha="center", va="bottom", fontsize=8.5, color=GREY)
    ax.text(7, 0.0, "Orange boxes are flip-flops (1,129 of them); blue boxes are combinational logic between them.",
            ha="center", fontsize=10.5, color=GREY)
    save(fig, "riscv_datapath.png")


def fig_fsm():
    """The sequencer: four states."""
    from matplotlib.patches import Circle
    fig, ax = canvas(11, 5.2)
    pos = {"FETCH": (1.6, 2.7), "EXEC": (5.5, 2.7), "MEM": (9.4, 2.7), "TRAP": (5.5, 4.55)}
    col = {"FETCH": SOFT, "EXEC": WARM, "MEM": SOFT, "TRAP": "#f8d7d3"}
    for st, (x, y) in pos.items():
        r = 0.5 if st == "TRAP" else 0.8
        ax.add_patch(Circle((x, y), r, fc=col[st], ec=RED if st == "TRAP" else ACCENT, lw=2))
        ax.text(x, y, st, ha="center", va="center", fontsize=12.5, fontweight="bold")
    arrow(ax, 2.4, 2.7, 4.7, 2.7, color=ACCENT, text="mem_ready:\ninstr <= mem_rdata", fs=9.5)
    arrow(ax, 6.3, 2.7, 8.6, 2.7, color=ACCENT, text="load or store:\nstart the access", fs=9.5)
    # EXEC -> FETCH (everything that is not a load or store)
    ax.plot([5.5, 5.5, 2.1], [1.9, 1.35, 1.35], color=ACCENT2, lw=1.6)
    arrow(ax, 2.1, 1.35, 2.1, 2.07, color=ACCENT2)
    ax.text(3.8, 1.42, "ALU, branch, jump:\nwrite rd, pc <= next pc", ha="center", va="bottom",
            fontsize=9.5, color=ACCENT2)
    # MEM -> FETCH
    ax.plot([9.4, 9.4, 1.4], [1.9, 0.55, 0.55], color=ACCENT, lw=1.6)
    arrow(ax, 1.4, 0.55, 1.4, 1.88, color=ACCENT)
    ax.text(5.5, 0.45, "mem_ready: write rd (loads), pc <= pc + 4", ha="center", va="top", fontsize=9.5, color=ACCENT)
    # EXEC -> TRAP
    arrow(ax, 5.5, 3.5, 5.5, 4.03, color=RED)
    ax.text(6.15, 4.55, "ecall, ebreak, unknown opcode,\nmisaligned access: stop", fontsize=9.5, color=RED, va="center")
    ax.text(0.15, 3.85, "reset", fontsize=10, color=GREY)
    arrow(ax, 0.55, 3.75, 1.05, 3.3, color=GREY)
    save(fig, "riscv_fsm.png")


def fig_timing():
    """Clock-by-clock: an addi, then a lw."""
    fig, ax = plt.subplots(figsize=(13, 3.3))
    ax.axis("off")
    ax.set_xlim(-2.2, 9.2)
    ax.set_ylim(0.6, 3.5)
    rows = [
        ("addi a0,a0,1", [(0, 2, "FETCH", SOFT), (2, 1, "EXEC", WARM)]),
        ("lw a1,0(a0)", [(3, 2, "FETCH", SOFT), (5, 1, "EXEC", WARM), (6, 2, "MEM", MINT)]),
    ]
    for r, (name, segs) in enumerate(rows):
        y = 2.2 - r * 1.1
        ax.text(-0.2, y + 0.35, name, ha="right", va="center", fontsize=11, family="monospace")
        for x0, w, s, fc in segs:
            ax.add_patch(plt.Rectangle((x0, y), w, 0.7, fc=fc, ec=ACCENT, lw=1.3))
            ax.text(x0 + w / 2, y + 0.35, s, ha="center", va="center", fontsize=10.5, fontweight="bold")
    for c in range(9):
        ax.plot([c, c], [0.9, 3.1], color="#c9d1d6", lw=0.8, ls=":")
        if c < 8:
            ax.text(c + 0.5, 3.15, str(c + 1), ha="center", fontsize=9, color=GREY)
    ax.text(4, 3.4, "clock cycle", ha="center", fontsize=9.5, color=GREY)
    ax.text(3.5, 0.65, "FETCH and MEM take 2 cycles because the memory answers one cycle after mem_valid. "
            "ALU ops: 3 cycles, loads and stores: 5.", ha="center", fontsize=10, color=ACCENT)
    save(fig, "riscv_timing.png")


def fig_mix():
    """Instruction mix and cycles of hello.c, from `make sim`."""
    # From make sim: hello: 8647 instructions, 28744 cycles
    mix = [("ALU", 4502, 3), ("branch", 1929, 3), ("jump", 766, 3), ("store", 720, 5),
           ("load", 682, 5), ("lui/auipc", 48, 3)]
    names = [m[0] for m in mix]
    n = [m[1] for m in mix]
    cyc = [m[1] * m[2] for m in mix]
    fig, axs = plt.subplots(1, 2, figsize=(13, 4.0))
    ax = axs[0]
    bars = ax.barh(names[::-1], n[::-1], color=ACCENT)
    ax.bar_label(bars, padding=4, fontsize=10)
    ax.set_title("hello.c: 8,647 instructions executed")
    ax.set_xlabel("instructions")
    ax.set_xlim(0, 5400)
    ax.grid(axis="y", visible=False)
    ax = axs[1]
    bars = ax.barh(names[::-1], cyc[::-1], color=[ACCENT2 if c[2] == 5 else ACCENT for c in mix[::-1]])
    ax.bar_label(bars, padding=4, fontsize=10)
    ax.set_title("28,744 clock cycles: CPI 3.32")
    ax.set_xlabel("clock cycles (3 per instruction, 5 for loads and stores)")
    ax.set_xlim(0, 16500)
    ax.grid(axis="y", visible=False)
    fig.tight_layout()
    save(fig, "riscv_mix.png")


def fig_area():
    """Where the 65,365 um^2 of cells go (make synth-sky130, by cell type)."""
    parts = [("register file\nflip-flops (992)", 19859, ACCENT2),
             ("4:1 muxes\n(mostly the 2 read ports)", 11531, "#f2b277"),
             ("ALU, decode, load/store,\nnext pc, other logic", 30541, ACCENT),
             ("pc, instr, mem_*\nflip-flops", 3435, "#7fb4c6")]
    fig, ax = plt.subplots(figsize=(12, 2.6))
    left = 0
    total = sum(p[1] for p in parts)
    for name, a, c in parts:
        ax.barh(0, a, left=left, color=c, edgecolor="white", height=0.6)
        ax.text(left + a / 2, 0, "%d%%" % round(100 * a / total), ha="center", va="center",
                color="white", fontsize=13, fontweight="bold")
        ax.text(left + a / 2, -0.48, name, ha="center", va="top", fontsize=9.5)
        left += a
    ax.set_xlim(-total * 0.01, total * 1.04)
    ax.set_ylim(-1.0, 0.45)
    ax.axis("off")
    ax.set_title("minirv in sky130: 7,103 cells, 65,365 µm² of cell area", fontsize=13)
    save(fig, "riscv_area.png")


def main():
    for fn in (fig_toolchain, fig_formats, fig_datapath, fig_fsm, fig_timing, fig_mix, fig_area):
        fn()


if __name__ == "__main__":
    main()
