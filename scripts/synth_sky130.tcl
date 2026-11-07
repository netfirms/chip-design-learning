# synth_sky130.tcl -- synthesis onto real SkyWater sky130 standard cells.
#
# Same idea as synth_generic.tcl, but flip-flops and logic are mapped onto
# cells from a Liberty (.lib) file, so `stat` reports real cell names and
# area in square microns.
#
# Called by `make synth-sky130` with TOP, RTL and LIBERTY set.

yosys -import

set top $::env(TOP)
set lib $::env(LIBERTY)

foreach f $::env(RTL) { read_verilog -sv $f }
synth -top $top -flatten

# Map flip-flops onto the library's sequential cells
dfflibmap -liberty $lib

# Map the remaining combinational logic with ABC, using the library cells.
# Note: real flows pass a "don't use" list here (e.g. the sky130 lpflow_*
# power-gating cells). OpenROAD-flow-scripts does that for you; newer Yosys
# versions accept `abc -dont_use <cell>`.
abc -liberty $lib

# Tie constant 0/1 nets to tie cells
hilomap -hicell sky130_fd_sc_hd__conb_1 HI -locell sky130_fd_sc_hd__conb_1 LO
setundef -zero
opt_clean -purge

tee -o build/synth_sky130_stat.txt stat -liberty $lib
write_verilog -noattr build/${top}_sky130.v
