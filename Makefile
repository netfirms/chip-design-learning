# Top-level Makefile: forwards targets to a design directory.
#
#   make sim                      # counter testbench
#   make synth DESIGN=counter     # pick a design explicitly
#   make check                    # lint + sim + synth for every design (what CI runs)
#   make doctor                   # check which tools are installed

DESIGN  ?= counter
DESIGNS := $(notdir $(wildcard designs/*))
TARGETS := all sim waves lint verilator synth show synth-sky130 pnr pnr-gui clean

.PHONY: $(TARGETS) check doctor

$(TARGETS):
	$(MAKE) -C designs/$(DESIGN) $@

check:
	@for d in $(DESIGNS); do $(MAKE) -C designs/$$d lint sim synth || exit 1; done

doctor:
	@for t in iverilog vvp verilator yosys gtkwave dot docker openroad klayout; do \
		if command -v $$t >/dev/null 2>&1; then printf '  ok       %s\n' $$t; \
		else printf '  missing  %s\n' $$t; fi; \
	done
