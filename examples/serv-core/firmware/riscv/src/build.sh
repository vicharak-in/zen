#!/usr/bin/env bash
# Builds the SERVxZen self-test firmware.   Usage: bash build.sh [MARCH] [MEMSIZE] [OUT]
#   MARCH   default rv32i_zicsr        (use rv32ic_zicsr when the core is built with COMPRESSED=1)
#   MEMSIZE default 4096               (must equal the MEMSIZE parameter of the hardware)
#   OUT     default selftest           (writes out/OUT.elf, .bin, .hex, .lst)
#   EXTRA   optional 4th argument: extra compiler flags, e.g. "-DWITH_TRAP -DWITH_PERF"
# Needs riscv64-unknown-elf-gcc (the 64-bit toolchain builds 32-bit code fine) and python3.
set -e
cd "$(dirname "$0")"
python3 gen-golden.py golden.h >/dev/null
MARCH=${1:-rv32i_zicsr}
MEMSIZE=${2:-4096}
OUT=out/${3:-selftest}
mkdir -p out
EXTRA=${4:-}
GCC=${TOOLCHAIN_PREFIX:-riscv64-unknown-elf-}gcc
OBJCOPY=${TOOLCHAIN_PREFIX:-riscv64-unknown-elf-}objcopy
OBJDUMP=${TOOLCHAIN_PREFIX:-riscv64-unknown-elf-}objdump
$GCC -march=$MARCH -mabi=ilp32 -Os -ffreestanding -fno-builtin -fno-tree-loop-distribute-patterns -falign-functions=4 -fno-pic -nostdlib -nostartfiles \
     -Wall -Wextra $EXTRA -Wl,--defsym=MEMSIZE=$MEMSIZE -Wl,--no-warn-rwx-segments -Wl,--no-relax \
     -Tlink.ld -o $OUT.elf start.S selftest.c
$OBJCOPY -O binary $OUT.elf $OUT.bin
python3 makehex.py $OUT.bin > $OUT.hex
$OBJDUMP -d -M no-aliases $OUT.elf > $OUT.lst
# Record __bss_start (end of code and constants) and __image_end (first free byte) so the testbench can prove the stack never reached them
$OBJDUMP -t $OUT.elf | python3 -c "import sys; d={l.split()[-1]:int(l.split()[0],16) for l in sys.stdin if l.rstrip().endswith(('__image_end','__bss_start'))}; print(d['__bss_start'], d['__image_end'])" > $OUT.end
echo "built $OUT.hex  ($(stat -c %s $OUT.bin) bytes image, march=$MARCH, RAM=$MEMSIZE)"
