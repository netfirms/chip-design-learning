# riscv: see mk/design.mk for the list of targets (make sim, synth, pnr, ...)
#
# Extra target:
#   make firmware   recompile the C and assembly programs in firmware/
#                   (needs riscv64-unknown-elf-gcc; the .hex files are committed)
TOP := minirv
RTL := rtl/minirv.v
TB  := tb/minirv_tb.v
include ../../mk/design.mk

.PHONY: firmware
firmware:
	$(MAKE) -C firmware

# The simulation reads the programs, so rebuild it when they change.
$(BUILD)/sim: firmware/isa_test.hex firmware/hello.hex
