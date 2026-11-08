# mk/design.mk -- shared rules for every design under designs/.
#
# A design's Makefile sets a few variables and includes this file:
#
#   TOP := fir                  # top-level module name
#   RTL := rtl/fir.v            # synthesisable sources (space separated)
#   TB  := tb/fir_tb.v          # testbench
#   include ../../mk/design.mk
#
# Targets:
#   make sim           Run the self-checking testbench with Icarus Verilog
#   make waves         Open the waveform in GTKWave
#   make lint          Lint the RTL with Verilator
#   make verilator     Build and run the testbench with Verilator (--binary)
#   make cocotb        Run the Python (cocotb) testbench in cocotb/ with Icarus
#   make synth         Generic synthesis with Yosys (no PDK needed)
#   make show          Draw the synthesised circuit as an SVG (needs graphviz)
#   make synth-sky130  Synthesis onto SkyWater sky130 standard cells
#   make pnr           Full RTL-to-GDS with OpenROAD-flow-scripts (Docker)
#   make pnr-gui       Open the final layout in the OpenROAD GUI
#   make plot          Plot testbench output with python/plot_tb.py (DSP designs)
#   make clean

REPO_ROOT := $(abspath $(dir $(lastword $(MAKEFILE_LIST)))/..)
DESIGN    := $(notdir $(CURDIR))
BUILD     := build

# sky130 Liberty file, fetched from OpenROAD-flow-scripts on first use
SKY130_LIB_URL := https://raw.githubusercontent.com/The-OpenROAD-Project/OpenROAD-flow-scripts/master/flow/platforms/sky130hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib
LIBERTY   ?= $(REPO_ROOT)/.cache/sky130_fd_sc_hd__tt_025C_1v80.lib

# OpenROAD-flow-scripts Docker image
ORFS_IMAGE ?= openroad/orfs:latest

# Extra flags a design may set (e.g. include paths)
IVERILOG_FLAGS  ?=
VERILATOR_FLAGS ?=

.PHONY: all sim waves lint verilator cocotb synth show synth-sky130 pnr pnr-gui plot clean

all: lint sim synth

$(BUILD):
	mkdir -p $@

# ---- Simulation ------------------------------------------------------------
$(BUILD)/sim: $(RTL) $(TB) | $(BUILD)
	iverilog -g2012 -Wall $(IVERILOG_FLAGS) -o $@ $(TB) $(RTL)

sim: $(BUILD)/sim
	vvp -n $< | tee $(BUILD)/sim.log
	@grep -q '^PASS' $(BUILD)/sim.log

waves: sim
	gtkwave $(BUILD)/$(TOP).vcd &

# ---- Lint ------------------------------------------------------------------
lint:
	verilator --lint-only -Wall $(VERILATOR_FLAGS) --top-module $(TOP) $(RTL)

verilator: | $(BUILD)
	verilator --binary -Wno-fatal --timing $(VERILATOR_FLAGS) -Mdir $(BUILD)/obj_dir \
		--top-module $(TOP)_tb $(TB) $(RTL)
	$(BUILD)/obj_dir/V$(TOP)_tb

# ---- cocotb: the same design, verified from Python -------------------------
# Exits non-zero if any test fails, so CI catches it.
cocotb: | $(BUILD)
	$(MAKE) -f $(REPO_ROOT)/mk/cocotb.mk TOP=$(TOP) RTL="$(RTL)" DESIGN=$(DESIGN)

# ---- Synthesis -------------------------------------------------------------
synth: | $(BUILD)
	TOP=$(TOP) RTL="$(RTL)" yosys -q -l $(BUILD)/synth_generic.log -c $(REPO_ROOT)/scripts/synth_generic.tcl
	@cat $(BUILD)/synth_generic_stat.txt

show: | $(BUILD)
	yosys -q -p 'read_verilog -sv $(RTL); synth -top $(TOP); opt_clean -purge; show -format svg -prefix $(BUILD)/$(TOP) $(TOP)'
	@echo "Wrote $(BUILD)/$(TOP).svg"

$(LIBERTY):
	mkdir -p $(dir $@)
	curl -fL -o $@ $(SKY130_LIB_URL)

synth-sky130: $(LIBERTY) | $(BUILD)
	TOP=$(TOP) RTL="$(RTL)" LIBERTY=$(LIBERTY) \
		yosys -q -l $(BUILD)/synth_sky130.log -c $(REPO_ROOT)/scripts/synth_sky130.tcl 2>&1 \
		| grep -v 'unsupported expression' || true
	@test -s $(BUILD)/synth_sky130_stat.txt && cat $(BUILD)/synth_sky130_stat.txt

# ---- Place & route (OpenROAD-flow-scripts in Docker) -----------------------
# Results land in build/orfs/{logs,reports,results}/sky130hd/$(TOP)/base/
pnr:
	$(REPO_ROOT)/scripts/orfs.sh $(ORFS_IMAGE) designs/$(DESIGN)/orfs/config.mk

pnr-gui:
	$(REPO_ROOT)/scripts/orfs.sh $(ORFS_IMAGE) designs/$(DESIGN)/orfs/config.mk gui_final

# ---- Plots (DSP designs write build/$(TOP)_out.csv) -----------------------
plot: sim
	@if [ -f $(BUILD)/$(TOP)_out.csv ]; then \
		python3 $(REPO_ROOT)/python/plot_tb.py $(BUILD)/$(TOP)_out.csv; \
	else echo "$(DESIGN): no $(BUILD)/$(TOP)_out.csv to plot (open the VCD with 'make waves')"; fi

clean:
	rm -rf $(BUILD)
