/* link.ld -- memory map of the minirv testbench "SoC".
 *
 *   0x0000_0000  64 KB RAM: code, data, stack (grows down from the top)
 *   0x1000_0000  console: write a byte to print it
 *   0x1000_0004  exit: write the program's exit code to stop the simulation
 *   0x1000_0008  cycle counter: read the number of clocks since reset
 */
OUTPUT_ARCH(riscv)
ENTRY(_start)

MEMORY { RAM (rwx) : ORIGIN = 0x00000000, LENGTH = 64K }

SECTIONS
{
    .text : { *(.text.start) *(.text .text.*) } > RAM
    .rodata : { *(.rodata .rodata.* .srodata .srodata.*) } > RAM
    .data : { *(.data .data.* .sdata .sdata.*) } > RAM
    .bss (NOLOAD) : {
        _bss_start = .;
        *(.bss .bss.* .sbss .sbss.* COMMON)
        . = ALIGN(4);
        _bss_end = .;
    } > RAM
    _stack_top = ORIGIN(RAM) + LENGTH(RAM);
}
