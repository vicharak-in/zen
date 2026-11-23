#!/usr/bin/env bash
# This script builds selftest.hex for the Zen PicoRV32 and sanity-checks the test logic on the host PC first.
# Needs: gcc (host), python3, and clang with lld and llvm-objcopy (Ubuntu/WSL: sudo apt install clang lld llvm). The hex was built with clang -Oz.
set -e

# This is the folder this script lives in.
cd "$(dirname "$0")"
# This is the memory size in 32-bit words (must match MEM_WORDS in the top module: 768 = 3 KB).
WORDS=768

# Step 1: regenerate the register-test assembly.
python3 gen-regtest.py

# Step 2: run the same checks on the PC. If this fails the expected values in selftest.c are wrong, not the CPU.
HOSTBIN=$(mktemp -d)/selftest_host
gcc -DHOST -O0 -o "$HOSTBIN" selftest.c
"$HOSTBIN" > /dev/null && echo "host check: all tests pass"
rm -f "$HOSTBIN"

# Step 3: cross-compile for the CPU (RV32IMC, no libraries, no linker relaxation, code from address 0).
clang --target=riscv32-unknown-elf -march=rv32imc -mabi=ilp32 -Oz -ffreestanding -fno-builtin -nostdlib -mno-relax -Wall -Wextra \
    -fuse-ld=lld -Wl,-T,link.ld -Wl,--build-id=none -o selftest.elf start.S regtest.S diagprobe.S selftest.c
# Step 4: extract the raw binary image.
llvm-objcopy -O binary selftest.elf selftest.bin
# Step 5: convert the binary into one 32-bit hex word per line, padded to the full memory size.
python3 - "$WORDS" "$((WORDS*4-208))" <<'EOF'
import sys, struct
# This is the number of memory words to emit.
words = int(sys.argv[1])
# This reads the raw program image.
data = open("selftest.bin", "rb").read()
# This pads the image to a whole number of 32-bit words.
data += b"\0" * (-len(data) % 4)
# This unpacks the image into little-endian 32-bit words.
w = list(struct.unpack("<%dI" % (len(data) // 4), data))
# This aborts if the program leaves less than 208 bytes for the stack (the word at 0xB30 is also used by the register test).
assert len(w) <= int(sys.argv[2]) // 4, "program too large (%d bytes)" % len(data)
# This pads with zeros up to the memory size.
w += [0] * (words - len(w))
# This writes the hex file.
open("selftest.hex", "w").write("".join("%08x\n" % x for x in w))
print("program size: %d bytes (limit %s)" % (len(data), sys.argv[2]))
EOF
# Step 6: print the section sizes.
llvm-size selftest.elf
