# analog/Makefile -- the analog bridge: an ADC and a DAC around the FIR filter.
#
#   make sim          netlist the Xschem schematics, run every ngspice test (PASS/FAIL)
#   make dac          8-bit R-2R DAC only: all 256 codes, DNL and INL
#   make adc          3-bit flash ADC only: ramp test
#   make chain        sine -> 8-bit ADC -> designs/fir/rtl/fir.v -> DAC -> filter
#   make plot         sim, then write the plots to docs/images/analog_*.png
#   make figures      concept diagrams for the deck (slides/images/analog_*.png)
#   make schematics   schematic pictures for the docs (needs xvfb-run)
#   make schematic-src  regenerate sch/*.sch from gen_schematics.py
#   make gui S=dac_r2r8   open a schematic in Xschem
#   make clean
#
# Needs: ngspice, xschem, iverilog, python3 with numpy (+ matplotlib, Pillow to plot).

PY ?= python3
S  ?= adc_flash3

.PHONY: sim dac adc chain plot figures schematics schematic-src gui clean

sim:
	$(PY) analog.py check

dac adc chain:
	$(PY) analog.py $@

plot:
	$(PY) analog.py plot

figures:
	$(PY) figures.py

schematics:
	$(PY) analog.py schematics

schematic-src:
	$(PY) gen_schematics.py

gui:
	xschem --rcfile $(CURDIR)/xschemrc $(CURDIR)/sch/$(S).sch

clean:
	rm -rf build
