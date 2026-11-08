#!/usr/bin/env bash
# render_images.sh -- regenerate every picture under docs/images/.
#
# Run `make pnr` and `make sim` in each design first (the renders read the
# routed GDS files, the plots read the testbench CSVs). Needs the Python
# packages in python/requirements.txt plus gdstk and pyvista.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

R=python/render_3d.py
I=docs/images
mkdir -p "$I"

gds() { echo "designs/$1/build/orfs/results/sky130hd/$2/base/6_final.gds"; }
die() { python3 -c "import gdstk; print(gdstk.read_gds('$1').top_level()[0].bounding_box()[1][0])"; }
# region of width w and height h (um) around the centre of the die
centre() { python3 -c "c=$1/2; print(c-$2/2, c-$3/2, c+$2/2, c+$3/2)"; }

# Project banner
python3 $R "$(gds fir fir)" -o $I/banner.webp --size 2400 800 \
    --region 95 95 140 118 --zscale 2 --elevation 33 --azimuth -60 --zoom 1.5 --skip met5 \
    --title "chip-design-learning" --tagline "Hardware is the new Software" \
    --subtitle 'A fast-track course in digital chip design for EE students\nVerilog to silicon with Yosys, OpenROAD and SkyWater sky130' \
    --caption "16-tap FIR filter, routed in sky130 by this repo. Rendered from the GDS with python/render_3d.py"

for spec in counter:counter pwm:pwm fir:fir iir:iir fft:fft8; do
    d=${spec%%:*}; t=${spec##*:}
    g=$(gds "$d" "$t")
    [[ -f "$g" ]] || { echo "skip $d (no GDS, run make pnr)"; continue; }
    size=$(die "$g")

    # Whole die
    zoom=1.05; [[ ${size%.*} -gt 100 ]] && zoom=0.9
    python3 $R "$g" -o $I/${d}_3d.webp --size 1600 900 --zscale 2.5 --elevation 40 \
        --azimuth -60 --zoom $zoom --caption "$d: whole die in sky130, rendered from the routed GDS"

    # Close-up of the wiring, top two metal layers removed
    python3 $R "$g" -o $I/${d}_3d_closeup.webp --size 1600 800 --region $(centre "$size" 30 14) \
        --zscale 2 --elevation 30 --azimuth -62 --zoom 1.55 --skip met4 met5 via4 \
        --caption "$d close-up, about 30 x 14 um: transistors at the bottom, four metal layers above"

    # Transistor level: only diffusion, gates, local interconnect and contacts
    python3 $R "$g" -o $I/${d}_3d_transistors.webp --size 1600 800 --region $(centre "$size" 18 9) \
        --zscale 3.5 --elevation 45 --azimuth -65 --zoom 1.2 \
        --skip met1 met2 met3 met4 met5 via via2 via3 via4 \
        --caption "$d, transistor level: diffusion (green), polysilicon gates (red), local interconnect (blue), contacts (grey)"
done

# Tiny Tapeout capstone (designs/tt_fir, 1x2 tiles). tt_fir_1x1_3d.webp comes
# from a second `make pnr` with the 1x1 die in designs/tt_fir/orfs/config.mk.
g=$(gds tt_fir tt_fir)
if [[ -f "$g" ]]; then
    python3 python/render_transistors_iso.py "$g" "${g%.gds}.def" -o $I/tt_fir_iso_transistors.webp \
        --title "The FIR as a Tiny Tapeout project (1x2 tiles): transistors and wiring"
    python3 $R "$g" -o $I/tt_fir_3d.webp --size 1600 900 --zscale 2.5 --elevation 40 --azimuth -60 \
        --zoom 0.78 --caption "tt_fir in 1x2 Tiny Tapeout tiles (161 x 226 um), 42% full, rendered from the routed GDS"
fi

# ORFS stage pictures (placement, clock tree, routing) for the FIR
rep=designs/fir/build/orfs/reports/sky130hd/fir/base
for f in final_placement final_clocks final_routing final_congestion final_ir_drop final_worst_path; do
    [[ -f $rep/$f.webp ]] && cp $rep/$f.webp $I/fir_$f.webp
done

# Testbench plots and filter design plot
for spec in pwm:pwm fir:fir iir:iir fft:fft8 tt_fir:tt_um_chipcourse_fir; do
    d=${spec%%:*}; t=${spec##*:}
    make -s -C designs/$d plot >/dev/null && cp designs/$d/build/${t}_out.png $I/${d}_sim.png
done
python3 python/dsp_coeffs.py --plot >/dev/null && cp build/filters.png $I/filters.png
rm -rf build

echo "Images written to $I/"
