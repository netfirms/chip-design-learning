# OpenROAD-flow-scripts (ORFS) configuration for designs/tt_fir.
#
# Tiny Tapeout itself hardens projects with LibreLane (see README.md); this
# config runs the course's own flow (`make pnr`) on a die of exactly the
# size of the tiles you ask for, so you can check that the design fits
# before you submit it. Variable reference:
# https://openroad-flow-scripts.readthedocs.io/en/latest/user/FlowVariables.html

THIS_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

export DESIGN_NAME     = tt_um_chipcourse_fir
export DESIGN_NICKNAME = tt_fir
export PLATFORM        = sky130hd

export VERILOG_FILES   = $(THIS_DIR)../src/project.v $(THIS_DIR)../src/fir.v
export SDC_FILE        = $(THIS_DIR)constraint.sdc

# A Tiny Tapeout tile on sky130 is 161.00 x 111.52 um; "1x2" is two tiles
# stacked: 161.00 x 225.76 um. A fixed die instead of CORE_UTILIZATION,
# because the tile size is what you buy.
# For 1x1 use DIE_AREA = 0 0 161.00 111.52, CORE_AREA = 2.76 2.72 158.24 108.80
export DIE_AREA   = 0 0 161.00 225.76
export CORE_AREA  = 2.76 2.72 158.24 223.04
export PLACE_DENSITY = 0.60
