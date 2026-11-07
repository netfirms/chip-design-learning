# OpenROAD-flow-scripts (ORFS) configuration for designs/pwm.
# Run with `make pnr` from designs/pwm. Variable reference:
# https://openroad-flow-scripts.readthedocs.io/en/latest/user/FlowVariables.html

# Directory of this file, so paths work wherever the repo is mounted
THIS_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

export DESIGN_NAME     = pwm
export DESIGN_NICKNAME = pwm
export PLATFORM        = sky130hd

export VERILOG_FILES   = $(THIS_DIR)../rtl/pwm.v
export SDC_FILE        = $(THIS_DIR)constraint.sdc

# Tiny design: fixed 60x60 um die with room for the I/O pins
export DIE_AREA        = 0 0 60 60
export CORE_AREA       = 5 5 55 55
export PLACE_DENSITY   = 0.35
