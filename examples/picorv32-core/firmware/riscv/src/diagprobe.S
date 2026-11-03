# This file holds stack_probe(): a crash-proof test of stack-relative stores and loads, using compressed and normal encodings.
# It never returns through a stack-loaded address, so a broken stack cannot restart the CPU; it only reports what it read back.
    .section .text
    .globl stack_probe
# stack_probe(out): a0 = pointer to a 9-word result area.
#   out[0..3] = four words written/read at sp+0..12 with plain sw/lw (the assembler compresses these to c.swsp / c.lwsp)
#   out[4..7] = four words written/read at sp+16..28 with compression switched off (normal 32-bit sw/lw)
#   out[8]    = the stack pointer after the frame is made
stack_probe:
    # Make a 32-byte frame.
    addi sp, sp, -32
    # t0 = 0xDEAD0000, the base of the test pattern.
    lui  t0, 0xDEAD0
    # Round 1: store four consecutive words (even and odd word indices) using the compressible forms.
    sw   t0, 0(sp)
    addi t1, t0, 1
    sw   t1, 4(sp)
    addi t1, t0, 2
    sw   t1, 8(sp)
    addi t1, t0, 3
    sw   t1, 12(sp)
    # Round 1: read them back and save them in the result area.
    lw   t2, 0(sp)
    sw   t2, 0(a0)
    lw   t2, 4(sp)
    sw   t2, 4(a0)
    lw   t2, 8(sp)
    sw   t2, 8(a0)
    lw   t2, 12(sp)
    sw   t2, 12(a0)
    # Round 2: the same with compression switched off, so every access is a normal 32-bit instruction.
    .option push
    .option norvc
    addi t1, t0, 4
    sw   t1, 16(sp)
    addi t1, t0, 5
    sw   t1, 20(sp)
    addi t1, t0, 6
    sw   t1, 24(sp)
    addi t1, t0, 7
    sw   t1, 28(sp)
    lw   t2, 16(sp)
    sw   t2, 16(a0)
    lw   t2, 20(sp)
    sw   t2, 20(a0)
    lw   t2, 24(sp)
    sw   t2, 24(a0)
    lw   t2, 28(sp)
    sw   t2, 28(a0)
    .option pop
    # Report the stack pointer too.
    sw   sp, 32(a0)
    # Drop the frame and return through ra, which never left its register.
    addi sp, sp, 32
    ret
