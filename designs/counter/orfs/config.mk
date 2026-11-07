# OpenROAD-flow-scripts (ORFS) design configuration for the counter.
#
# ORFS is a set of Makefiles + Tcl scripts that drive Yosys and OpenROAD
# through the full RTL-to-GDS flow:
#   synth -> floorplan -> place -> cts -> route -> finish (GDS)
#
# Run it with `make pnr` from designs/counter (uses Docker, see
# scripts/orfs.sh). Every variable is documented in the ORFS docs:
# https://openroad-flow-scripts.readthedocs.io/en/latest/user/FlowVariables.html

# Directory of this file, so paths work wherever the repo is mounted
COUNTER_ORFS_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

export DESIGN_NAME     = counter
export DESIGN_NICKNAME = counter
export PLATFORM        = sky130hd

export VERILOG_FILES   = $(COUNTER_ORFS_DIR)../rtl/counter.v
export SDC_FILE        = $(COUNTER_ORFS_DIR)constraint.sdc

# Floorplan. The design is tiny (~25 cells), so we give it a fixed 60x60 um
# die rather than deriving the size from utilisation; that leaves room for
# the 12 I/O pins around the edge.
export DIE_AREA        = 0 0 60 60
export CORE_AREA       = 5 5 55 55

# Global placement target density (0..1). Low because the design is small.
export PLACE_DENSITY   = 0.35
