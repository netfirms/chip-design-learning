# Makefile for the counter design.
#
#   make sim           Run the self-checking testbench with Icarus Verilog
#   make waves         Open the waveform in GTKWave
#   make lint          Lint the RTL with Verilator
#   make verilator     Build and run the testbench with Verilator (--binary)
#   make synth         Generic synthesis with Yosys (no PDK needed)
#   make show          Draw the synthesised circuit as an SVG (needs graphviz)
#   make synth-sky130  Synthesis onto SkyWater sky130 standard cells
#   make pnr           Full RTL-to-GDS with OpenROAD-flow-scripts (Docker)
#   make clean

TOP      := counter
RTL      := rtl/counter.v
TB       := tb/counter_tb.v
BUILD    := build

# sky130 Liberty file, fetched from OpenROAD-flow-scripts on first use
SKY130_LIB_URL := https://raw.githubusercontent.com/The-OpenROAD-Project/OpenROAD-flow-scripts/master/flow/platforms/sky130hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib
LIBERTY  ?= $(abspath ../../.cache/sky130_fd_sc_hd__tt_025C_1v80.lib)

# OpenROAD-flow-scripts Docker image
ORFS_IMAGE ?= openroad/orfs:latest
REPO_ROOT  := $(abspath ../..)

.PHONY: all sim waves lint verilator synth show synth-sky130 pnr pnr-gui clean

all: lint sim synth

$(BUILD):
	mkdir -p $@

# ---- Simulation ------------------------------------------------------------
$(BUILD)/sim: $(RTL) $(TB) | $(BUILD)
	iverilog -g2012 -Wall -o $@ $(TB) $(RTL)

sim: $(BUILD)/sim
	vvp -n $< | tee $(BUILD)/sim.log
	@grep -q '^PASS' $(BUILD)/sim.log

waves: sim
	gtkwave $(BUILD)/$(TOP).vcd &

# ---- Lint ------------------------------------------------------------------
lint:
	verilator --lint-only -Wall $(RTL)

verilator: | $(BUILD)
	verilator --binary -Wno-fatal --timing -Mdir $(BUILD)/obj_dir \
		--top-module counter_tb $(TB) $(RTL)
	$(BUILD)/obj_dir/Vcounter_tb

# ---- Synthesis -------------------------------------------------------------
synth: | $(BUILD)
	yosys -q -l $(BUILD)/synth_generic.log -s synth/synth_generic.ys
	@cat $(BUILD)/synth_generic_stat.txt

show: | $(BUILD)
	yosys -q -p 'read_verilog -sv $(RTL); synth -top $(TOP); opt_clean -purge; show -format svg -prefix $(BUILD)/$(TOP) $(TOP)'
	@echo "Wrote $(BUILD)/$(TOP).svg"

$(LIBERTY):
	mkdir -p $(dir $@)
	curl -fL -o $@ $(SKY130_LIB_URL)

synth-sky130: $(LIBERTY) | $(BUILD)
	LIBERTY=$(LIBERTY) yosys -q -l $(BUILD)/synth_sky130.log -c synth/synth_sky130.tcl
	@cat $(BUILD)/synth_sky130_stat.txt

# ---- Place & route (OpenROAD-flow-scripts in Docker) -----------------------
# Results land in build/orfs/{logs,reports,results}/sky130hd/counter/base/
pnr:
	$(REPO_ROOT)/scripts/orfs.sh $(ORFS_IMAGE) designs/counter/orfs/config.mk

pnr-gui:
	$(REPO_ROOT)/scripts/orfs.sh $(ORFS_IMAGE) designs/counter/orfs/config.mk gui_final

clean:
	rm -rf $(BUILD)
