/* This linker script places code and data from address 0 and the zero-initialised buffers right after them; the stack grows down from the top of RAM. */
ENTRY(_start)

MEMORY
{
    /* Program and data RAM: the last 256 bytes below 0xC00 are left free for the stack. */
    RAM (rwx) : ORIGIN = 0x00000000, LENGTH = 0xB00
}

SECTIONS
{
    /* Code and read-only data, with the reset entry first so it lands at address 0. */
    .text : { *(.text.start) *(.text*) *(.rodata*) *(.srodata*) } > RAM
    /* Initialised data lives in the same image because the memory is loaded from one hex file. */
    .data : { *(.data*) *(.sdata*) } > RAM
    /* Buffers (history window, output bits) are not in the image; the firmware always writes them before reading them. */
    .bss  : { *(.bss*) *(.sbss*) *(COMMON) } > RAM
}
