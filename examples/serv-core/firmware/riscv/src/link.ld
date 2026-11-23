/* Linker script for SERVxZen: everything lives in RAM at address 0. MEMSIZE is passed with --defsym from build.sh */
OUTPUT_ARCH( "riscv" )
ENTRY(_start)

SECTIONS
{
  /* Program code starts at the reset vector 0x0 */
  . = 0x00000000;
  /* Code first so _start sits at 0 */
  .text   : { *(.text.start) *(.text*) }
  /* Read-only data follows */
  .rodata : { *(.rodata*) *(.srodata*) }
  /* Initialised data (part of the hex image) */
  .data   : { *(.data*) *(.sdata*) }
  /* Zero-initialised data; start.S clears it */
  .bss    : { . = ALIGN(4); __bss_start = .; *(.bss*) *(.sbss*) *(COMMON) . = ALIGN(4); __bss_end = .; }
  /* First free byte after the image: tests must keep scratch memory above this and below the stack */
  __image_end = .;
  /* Stack grows down from the top of RAM */
  __stack_top = MEMSIZE;
  /* Fail the link if the image plus a 480-byte stack no longer fits in RAM */
  ASSERT(__image_end + 480 <= MEMSIZE, "SERVxZen: image + 480 B stack does not fit in RAM")
}
