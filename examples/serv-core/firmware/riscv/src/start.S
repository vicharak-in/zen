# Startup for SERVxZen: sets sp, clears .bss, calls main, then parks the CPU
# Also holds the trap entry that saves every caller-saved register, calls trap_handler() in C, and returns with mret

    .section .text.start
    .globl _start
_start:
    # Stack pointer at the top of RAM (set by the linker script)
    la   sp, __stack_top
    # Clear .bss word by word: a0 = start, a1 = end
    la   a0, __bss_start
    la   a1, __bss_end
1:  bgeu a0, a1, 2f
    sw   zero, 0(a0)
    addi a0, a0, 4
    j    1b
2:  # Run the C program
    call main
    # main returned: park here (a loop, so the PC does not run into unknown memory)
3:  j    3b

    .text
    .globl trap_entry
    .align 2
trap_entry:
    # Make room for 16 saved registers
    addi sp, sp, -64
    # Save ra, t0-t2, a0-a7, t3-t6 (everything C may have live across an interrupt)
    sw   ra,  0(sp)
    sw   t0,  4(sp)
    sw   t1,  8(sp)
    sw   t2, 12(sp)
    sw   a0, 16(sp)
    sw   a1, 20(sp)
    sw   a2, 24(sp)
    sw   a3, 28(sp)
    sw   a4, 32(sp)
    sw   a5, 36(sp)
    sw   a6, 40(sp)
    sw   a7, 44(sp)
    sw   t3, 48(sp)
    sw   t4, 52(sp)
    sw   t5, 56(sp)
    sw   t6, 60(sp)
    # Arguments for trap_handler(mcause, mepc)
    csrr a0, mcause
    csrr a1, mepc
    # The C handler returns the PC to resume at
    call trap_handler
    # Install the resume PC
    csrw mepc, a0
    # Restore all registers
    lw   ra,  0(sp)
    lw   t0,  4(sp)
    lw   t1,  8(sp)
    lw   t2, 12(sp)
    lw   a0, 16(sp)
    lw   a1, 20(sp)
    lw   a2, 24(sp)
    lw   a3, 28(sp)
    lw   a4, 32(sp)
    lw   a5, 36(sp)
    lw   a6, 40(sp)
    lw   a7, 44(sp)
    lw   t3, 48(sp)
    lw   t4, 52(sp)
    lw   t5, 56(sp)
    lw   t6, 60(sp)
    # Release the frame and return from the trap
    addi sp, sp, 64
    mret
