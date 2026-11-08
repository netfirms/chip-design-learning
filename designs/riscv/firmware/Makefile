# Firmware for minirv: C and assembly programs, compiled to memory images.
#
#   make            build every program (needs riscv64-unknown-elf-gcc)
#   make clean
#
# Each program gives <name>.hex (loaded by the testbench with $readmemh)
# and <name>.lst (the disassembly: every instruction the CPU will run).
# Both are committed, so `make sim` works without the compiler.
#
# Install the compiler on Ubuntu/Debian: apt install gcc-riscv64-unknown-elf

CROSS   ?= riscv64-unknown-elf-
CC      := $(CROSS)gcc
OBJCOPY := $(CROSS)objcopy
OBJDUMP := $(CROSS)objdump

# rv32i: the base integer instructions only, so there is no hardware
# multiply or divide. The compiler calls libgcc (-lgcc) for those: software.
ARCH    := -march=rv32i -mabi=ilp32
CFLAGS  := $(ARCH) -Os -ffreestanding -fno-builtin -Wall -Wextra
LDFLAGS := $(ARCH) -nostdlib -nostartfiles -T link.ld -Wl,--no-warn-rwx-segments

PROGRAMS := isa_test hello

.PHONY: all clean
all: $(addsuffix .hex,$(PROGRAMS))

isa_test.elf: isa_test.S link.ld
	$(CC) $(LDFLAGS) -o $@ isa_test.S

hello.elf: start.S hello.c link.ld
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ start.S hello.c -lgcc

%.hex: %.elf bin2hex.py
	$(OBJCOPY) -O binary $< $(basename $@).bin
	python3 bin2hex.py $(basename $@).bin $@
	$(OBJDUMP) -d --no-show-raw-insn $< > $(basename $@).lst
	@rm -f -- $(basename $@).bin
	@echo "$@: $$(wc -l < $@) words"

clean:
	rm -f -- *.elf *.bin
