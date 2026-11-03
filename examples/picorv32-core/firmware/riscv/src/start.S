# This is the reset entry point: the core starts at address 0 with sp already set to STACKADDR by the hardware.
    .section .text.start
    .globl _start
_start:
    # Jump straight into the C program (never returns).
    j main
