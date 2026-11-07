# synth_generic.tcl -- technology-independent synthesis with Yosys.
#
# Maps the RTL onto Yosys' own generic gate library ($_AND_, $_DFF_P_, ...).
# No PDK needed, so this is the fastest way to see what your Verilog turns into.
#
# Called by `make synth` from a design directory with:
#   TOP = top module name, RTL = space-separated list of Verilog files

yosys -import

set top $::env(TOP)

# 1. Read the design
foreach f $::env(RTL) { read_verilog -sv $f }

# 2. Elaborate, optimise and map to generic gates.
#    `synth` is a script that runs: hierarchy, proc, opt, fsm, memory,
#    techmap, abc, ... (see `help synth` inside yosys for the full list).
synth -top $top -flatten

# 3. Clean up and report
opt_clean -purge
tee -o build/synth_generic_stat.txt stat

# 4. Write the gate-level netlist
write_verilog -noattr build/${top}_generic.v
