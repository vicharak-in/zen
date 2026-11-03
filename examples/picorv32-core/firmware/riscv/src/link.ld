/* This linker script places everything from address 0; the top of RAM is left free for the stack, which grows down. */
ENTRY(_start)

MEMORY
{
    /* Program and data RAM: the stack lives above it, growing down from the top of the memory. */
    RAM (rwx) : ORIGIN = 0x00000000, LENGTH = 0xB30
}

SECTIONS
{
    /* Code and read-only data, with the reset entry first so it lands at address 0. */
    .text : { *(.text.start) *(.text*) *(.rodata*) *(.srodata*) } > RAM
    /* Initialised data lives in the same image because the memory is loaded from one hex file. */
    .data : { *(.data*) *(.sdata*) } > RAM
}
