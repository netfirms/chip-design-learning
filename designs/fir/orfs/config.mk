# OpenROAD-flow-scripts (ORFS) configuration for designs/fir.
# Run with `make pnr` from designs/fir. Variable reference:
# https://openroad-flow-scripts.readthedocs.io/en/latest/user/FlowVariables.html

# Directory of this file, so paths work wherever the repo is mounted
THIS_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

export DESIGN_NAME     = fir
export DESIGN_NICKNAME = fir
export PLATFORM        = sky130hd

export VERILOG_FILES   = $(THIS_DIR)../rtl/fir.v
export SDC_FILE        = $(THIS_DIR)constraint.sdc

# Size the core from the synthesised cell area: cells fill 40% of the core,
# the rest is left for routing. PLACE_DENSITY is how tightly placement packs.
export CORE_UTILIZATION = 40
export PLACE_DENSITY    = 0.60
