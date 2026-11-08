# start.S -- what runs before main(): the C start-up code.
#
# A C program expects a stack and zeroed global variables. On a PC the
# operating system sets these up; on bare metal it is our job.

    .section .text.start
    .globl _start
_start:
    la      sp, _stack_top          # stack pointer: top of RAM
    la      t0, _bss_start          # zero .bss (globals without an initial value)
    la      t1, _bss_end
1:  bgeu    t0, t1, 2f
    sw      zero, 0(t0)
    addi    t0, t0, 4
    j       1b
2:  call    main                    # a0 = main's return value
    li      t0, 0x10000004          # write it to the exit register
    sw      a0, 0(t0)
3:  j       3b                      # and wait for the testbench to stop us
