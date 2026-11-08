# mk/cocotb.mk -- run a design's cocotb (Python) testbench.
#
# Called from mk/design.mk by `make cocotb`; it is a separate Makefile because
# cocotb's own rules define targets (sim, clean, ...) that would clash with ours.
#
#   make cocotb                    # every test in cocotb/test_<design>.py
#   make cocotb COCOTB_TEST_FILTER=test_impulse   # just one test (a regex)
#   make cocotb WAVES=1            # also dump a waveform (build/cocotb/*.fst)
#   make cocotb COCOTB_RANDOM_SEED=42             # replay a random run
#
# Needs: pip install -r python/requirements-verif.txt, plus Icarus Verilog.

REPO_ROOT := $(abspath $(dir $(lastword $(MAKEFILE_LIST)))/..)

SIM            ?= icarus
TOPLEVEL_LANG  := verilog
VERILOG_SOURCES = $(addprefix $(CURDIR)/,$(RTL))
COCOTB_TOPLEVEL     = $(TOP)
COCOTB_TEST_MODULES = test_$(DESIGN)
SIM_BUILD      := $(CURDIR)/build/cocotb
COCOTB_RESULTS_FILE := $(SIM_BUILD)/results.xml
export COCOTB_RESULTS_FILE

# The test lives in cocotb/, shared helpers and DSP models in python/
export PYTHONPATH := $(CURDIR)/cocotb:$(REPO_ROOT)/python$(if $(PYTHONPATH),:$(PYTHONPATH))

include $(shell cocotb-config --makefiles)/Makefile.sim
