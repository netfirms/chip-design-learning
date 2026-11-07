# synth_sky130.tcl -- synthesis onto real SkyWater sky130 standard cells.
#
# Same idea as synth_generic.ys, but flip-flops and logic are mapped onto
# cells from a Liberty (.lib) file, so `stat` reports real cell names and
# area in square microns.
#
# Run from designs/counter:
#   LIBERTY=/path/to/sky130_fd_sc_hd__tt_025C_1v80.lib yosys -c synth/synth_sky130.tcl
# (`make synth-sky130` downloads the .lib for you.)

yosys -import

if {![info exists ::env(LIBERTY)]} {
    puts stderr "ERROR: set LIBERTY to a sky130 .lib file"
    exit 1
}
set lib $::env(LIBERTY)

read_verilog -sv rtl/counter.v
synth -top counter -flatten

# Map flip-flops onto the library's sequential cells
dfflibmap -liberty $lib

# Map the remaining combinational logic with ABC, using the library cells.
# Note: real flows pass a "don't use" list here (e.g. the sky130 lpflow_*
# power-gating cells). OpenROAD-flow-scripts does that for you; newer Yosys
# versions accept `abc -dont_use <cell>`. Warnings about "unsupported
# expression" in scan flip-flops are harmless: Yosys just skips those cells.
abc -liberty $lib

# Tie constant 0/1 nets to tie cells and replace undriven/buffer nets
hilomap -hicell sky130_fd_sc_hd__conb_1 HI -locell sky130_fd_sc_hd__conb_1 LO
setundef -zero
opt_clean -purge

tee -o build/synth_sky130_stat.txt stat -liberty $lib
write_verilog -noattr build/counter_sky130.v
