# codesign/Makefile -- the 8-point FFT in software vs hardware.
#
#   make check    bit-exact Python model vs the RTL testbench output (needs numpy)
#   make bench    measure the software on this machine, write results + charts
#   make charts   redraw the charts from results/bench.json
#   make area     area of each fft_bfly twiddle variant on sky130 cells (Yosys)
#
# CPU_WATTS is the power of one busy core, for the software energy estimate.

PYTHON    ?= python3
CPU_WATTS ?= 10
REPO_ROOT := $(abspath ..)
FFT_CSV   := $(REPO_ROOT)/designs/fft/build/fft8_out.csv
LIBERTY   ?= $(REPO_ROOT)/.cache/sky130_fd_sc_hd__tt_025C_1v80.lib

.PHONY: check bench charts area clean

$(FFT_CSV):
	$(MAKE) -C $(REPO_ROOT)/designs/fft sim

check: $(FFT_CSV)
	$(PYTHON) fft_sw.py --rtl-csv $(FFT_CSV)

bench:
	$(PYTHON) benchmark.py --cpu-watts $(CPU_WATTS)

charts:
	$(PYTHON) benchmark.py --charts-only

$(LIBERTY):
	$(MAKE) -C $(REPO_ROOT)/designs/fft $(LIBERTY)

area: $(LIBERTY)
	@mkdir -p build
	@for k in 0 1 2 3; do \
		yosys -q -p "read_verilog -sv ../designs/fft/rtl/fft_bfly.v; \
			chparam -set K $$k -set IW 17 fft_bfly; synth -top fft_bfly -flatten; \
			abc -liberty $(LIBERTY); opt_clean -purge; \
			tee -q -o build/bfly_k$$k.txt stat -liberty $(LIBERTY)"; \
		printf 'fft_bfly K=%s: ' $$k; grep 'Chip area' build/bfly_k$$k.txt | sed 's/.*: //;s/$$/ um^2/'; \
	done

clean:
	rm -rf build
