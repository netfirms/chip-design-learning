# Top-level Makefile: forwards targets to a design directory.
#
#   make sim                      # counter testbench
#   make sim DESIGN=fir           # any design under designs/
#   make synth DESIGN=counter     # pick a design explicitly
#   make check                    # lint + sim + synth for every design (what CI runs)
#   make check-sky130             # sky130 synthesis for every design
#   make doctor                   # check which tools are installed

DESIGN  ?= counter
DESIGNS := $(notdir $(wildcard designs/*))
TARGETS := all sim waves lint verilator synth show synth-sky130 pnr pnr-gui plot clean

.PHONY: $(TARGETS) check check-sky130 doctor

$(TARGETS):
	$(MAKE) -C designs/$(DESIGN) $@

check:
	@for d in $(DESIGNS); do $(MAKE) -C designs/$$d lint sim synth || exit 1; done

check-sky130:
	@for d in $(DESIGNS); do $(MAKE) -C designs/$$d synth-sky130 || exit 1; done

doctor:
	@for t in iverilog vvp verilator yosys gtkwave dot python3 docker openroad klayout; do \
		if command -v $$t >/dev/null 2>&1; then printf '  ok       %s\n' $$t; \
		else printf '  missing  %s\n' $$t; fi; \
	done
