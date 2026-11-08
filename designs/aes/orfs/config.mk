# OpenROAD-flow-scripts (ORFS) configuration for designs/aes (aes_ctr).
# Run with `make pnr` from designs/aes. Variable reference:
# https://openroad-flow-scripts.readthedocs.io/en/latest/user/FlowVariables.html

# Directory of this file, so paths work wherever the repo is mounted
THIS_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

export DESIGN_NAME     = aes_ctr
export DESIGN_NICKNAME = aes_ctr
export PLATFORM        = sky130hd

export VERILOG_FILES   = $(THIS_DIR)../rtl/aes_sbox.v $(THIS_DIR)../rtl/aes128.v $(THIS_DIR)../rtl/aes_ctr.v
export SDC_FILE        = $(THIS_DIR)constraint.sdc

# Size the core from the synthesised cell area: cells fill 40% of the core,
# the rest is left for routing. The 20 S-boxes are dense random logic, so
# this design needs the routing room more than the DSP designs do.
export CORE_UTILIZATION = 40
export PLACE_DENSITY    = 0.60
