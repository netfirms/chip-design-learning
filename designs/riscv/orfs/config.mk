# OpenROAD-flow-scripts (ORFS) configuration for designs/riscv (minirv).
# Run with `make pnr` from designs/riscv. Variable reference:
# https://openroad-flow-scripts.readthedocs.io/en/latest/user/FlowVariables.html

# Directory of this file, so paths work wherever the repo is mounted
THIS_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

export DESIGN_NAME     = minirv
export DESIGN_NICKNAME = minirv
export PLATFORM        = sky130hd

export VERILOG_FILES   = $(THIS_DIR)../rtl/minirv.v
export SDC_FILE        = $(THIS_DIR)constraint.sdc

# Size the core from the synthesised cell area: cells fill 40% of the core,
# the rest is left for routing. The CPU is only the core: its program
# memory sits outside the chip, on the 102 mem_* pins.
export CORE_UTILIZATION = 40
export PLACE_DENSITY    = 0.60
