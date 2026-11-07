# OpenROAD-flow-scripts (ORFS) configuration for designs/fft.
# Run with `make pnr` from designs/fft. Variable reference:
# https://openroad-flow-scripts.readthedocs.io/en/latest/user/FlowVariables.html

# Directory of this file, so paths work wherever the repo is mounted
THIS_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

export DESIGN_NAME     = fft8
export DESIGN_NICKNAME = fft8
export PLATFORM        = sky130hd

export VERILOG_FILES   = $(THIS_DIR)../rtl/fft8.v $(THIS_DIR)../rtl/fft_bfly.v
export SDC_FILE        = $(THIS_DIR)constraint.sdc

# Size the core from the synthesised cell area (40% of the core is cells)
export CORE_UTILIZATION = 40
export PLACE_DENSITY    = 0.60
