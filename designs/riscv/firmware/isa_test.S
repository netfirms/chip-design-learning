# isa_test.S -- self-checking test of every RV32I instruction minirv runs.
#
# Each CHECK compares a register with the value the RISC-V spec says it must
# hold. gp counts the checks; on the first mismatch the test writes gp to the
# exit register, so a failing run tells you exactly which check broke (find
# it in isa_test.lst). Exit code 0 means every check passed.

#define EXIT 0x10000004

    .macro CHECK reg, val
    li      t6, \val
    addi    gp, gp, 1
    bne     \reg, t6, fail
    .endm

    .text
    .globl _start
_start:
    li      gp, 0

    # ---- Arithmetic --------------------------------------------------------
    li      a0, 5
    li      a1, 7
    add     a2, a0, a1
    CHECK   a2, 12
    sub     a2, a0, a1
    CHECK   a2, -2
    addi    a2, a0, -10
    CHECK   a2, -5
    lui     a2, 0x12345
    CHECK   a2, 0x12345000
1:  auipc   a2, 0                   # a2 = address of this instruction
    la      a3, 1b                  # the assembler knows that address too
    sub     a2, a2, a3              # so a2 - a3 must be 0
    CHECK   a2, 0
    addi    x0, x0, 5               # x0 ignores writes
    add     a2, x0, x0
    CHECK   a2, 0

    # ---- Logic -------------------------------------------------------------
    li      a0, 0xf0f0f0f0
    li      a1, 0x0ff00ff0
    and     a2, a0, a1
    CHECK   a2, 0x00f000f0
    or      a2, a0, a1
    CHECK   a2, 0xfff0fff0
    xor     a2, a0, a1
    CHECK   a2, 0xff00ff00
    andi    a2, a0, 0xff
    CHECK   a2, 0xf0
    ori     a2, a0, 0x0f
    CHECK   a2, 0xf0f0f0ff
    xori    a2, a0, -1
    CHECK   a2, 0x0f0f0f0f

    # ---- Shifts ------------------------------------------------------------
    li      a0, 1
    li      a1, 31
    sll     a2, a0, a1
    CHECK   a2, 0x80000000
    slli    a2, a0, 4
    CHECK   a2, 16
    li      a0, 0x80000000
    srli    a2, a0, 31
    CHECK   a2, 1
    srai    a2, a0, 31
    CHECK   a2, 0xffffffff
    li      a1, 4
    sra     a2, a0, a1
    CHECK   a2, 0xf8000000
    srl     a2, a0, a1
    CHECK   a2, 0x08000000
    li      a1, 36                  # only the low 5 bits count: shift by 4
    srl     a2, a0, a1
    CHECK   a2, 0x08000000

    # ---- Compare -----------------------------------------------------------
    li      a0, -1
    li      a1, 1
    slt     a2, a0, a1              # -1 < 1 signed
    CHECK   a2, 1
    sltu    a2, a0, a1              # 0xffffffff < 1 unsigned? no
    CHECK   a2, 0
    slti    a2, a0, 0
    CHECK   a2, 1
    sltiu   a2, a1, -1              # 1 < 0xffffffff
    CHECK   a2, 1

    # ---- Loads and stores --------------------------------------------------
    la      s0, buf
    li      a0, 0x11223344
    sw      a0, 0(s0)
    lw      a2, 0(s0)
    CHECK   a2, 0x11223344
    lb      a2, 0(s0)               # little endian: byte 0 is 0x44
    CHECK   a2, 0x44
    lbu     a2, 3(s0)
    CHECK   a2, 0x11
    li      a0, 0x80
    sb      a0, 1(s0)
    lw      a2, 0(s0)
    CHECK   a2, 0x11228044
    lb      a2, 1(s0)               # sign-extended
    CHECK   a2, 0xffffff80
    lbu     a2, 1(s0)               # zero-extended
    CHECK   a2, 0x80
    li      a0, 0xbeef
    sh      a0, 2(s0)
    lw      a2, 0(s0)
    CHECK   a2, 0xbeef8044
    lh      a2, 2(s0)
    CHECK   a2, 0xffffbeef
    lhu     a2, 2(s0)
    CHECK   a2, 0xbeef
    lh      a2, 0(s0)
    CHECK   a2, 0xffff8044
    addi    s1, s0, 8
    lw      a2, -8(s1)              # negative offset
    CHECK   a2, 0xbeef8044
    sw      a1, 4(s0)               # a second word, next to the first
    lw      a2, 4(s0)
    CHECK   a2, 1
    lw      a2, 0(s0)               # and the first one is untouched
    CHECK   a2, 0xbeef8044

    # ---- Branches (taken and not taken) ------------------------------------
    li      a0, -1
    li      a1, 1
    addi    gp, gp, 1
    blt     a0, a1, 1f
    j       fail
1:  bltu    a0, a1, fail
    bge     a1, a0, 1f
    j       fail
1:  bge     a0, a0, 1f              # equal counts as >=
    j       fail
1:  bgeu    a1, a0, fail
    bgeu    a0, a1, 1f
    j       fail
1:  beq     a0, a0, 1f
    j       fail
1:  beq     a0, a1, fail
    bne     a0, a0, fail
    bne     a0, a1, 1f
    j       fail
1:  blt     a1, a0, fail

    # ---- Jumps -------------------------------------------------------------
    addi    gp, gp, 1
    jal     ra, 1f                  # ra = address of the next instruction
ret1:
    j       fail
1:  la      a3, ret1
    bne     ra, a3, fail
    addi    gp, gp, 1
    la      a4, 1f
    addi    a4, a4, 1               # jalr clears bit 0 of the target
    jalr    t0, 0(a4)
ret2:
    j       fail
1:  la      a3, ret2
    bne     t0, a3, fail
    fence                           # a no-op on this CPU

    # ---- All checks passed -------------------------------------------------
    li      t0, EXIT
    sw      zero, 0(t0)
1:  j       1b

fail:
    li      t0, EXIT
    sw      gp, 0(t0)
1:  j       1b

    .data
    .balign 4
buf:
    .word   0, 0, 0
