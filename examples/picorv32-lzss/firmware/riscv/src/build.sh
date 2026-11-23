#!/usr/bin/env bash
# This script builds lzss.hex for the Zen PicoRV32, after checking the compressor on the host PC.
# Needs: gcc (host), python3, and a RISC-V toolchain (Ubuntu/WSL: sudo apt install gcc-riscv64-unknown-elf).
set -e

# This is the folder this script lives in.
cd "$(dirname "$0")"
# This is the RISC-V toolchain prefix.
TC=riscv64-unknown-elf-
# This is the memory size in 32-bit words (must match MEM_WORDS in the top module: 768 = 3 KB).
WORDS=768

# Step 1: build the host version and make sure its output matches the Python reference byte for byte.
TMP=$(mktemp -d)
gcc -DHOST -O1 -o "$TMP/lzss_host" lzss.c
python3 - "$TMP" <<'PY'
import os, subprocess, sys, random
# This is the scratch folder.
tmp = sys.argv[1]
# This is the reference implementation in the tools folder.
sys.path.insert(0, os.path.join(os.getcwd(), "..", "..", "..", "sim"))
import lzss_ref
# This is a test input with text, repeats and noise.
random.seed(5)
data = (b"the quick brown fox jumps over the lazy dog. " * 40 + bytes(random.randrange(256) for _ in range(300)) + b"abcabcabcabc" * 50)
open(tmp + "/in.bin", "wb").write(data)
# This runs the C compressor on the host.
subprocess.check_call([tmp + "/lzss_host", tmp + "/in.bin", tmp + "/out.bin"])
# The C output must equal the Python reference and must decompress back to the input.
c_out = open(tmp + "/out.bin", "rb").read()
assert c_out == lzss_ref.compress_stream(data), "C compressor differs from the Python reference"
assert lzss_ref.decompress_stream(c_out, len(data)) == data, "round trip failed"
print("host check: C == Python reference, round trip ok (%d -> %d bytes)" % (len(data), len(c_out)))
PY
rm -rf "$TMP"

# Step 2: cross-compile for the CPU (RV32IMC, no libraries, no linker relaxation, code from address 0).
${TC}gcc -march=rv32imc -mabi=ilp32 -Os -ffreestanding -fno-builtin -nostdlib -mno-relax \
    -Wall -Wextra -T link.ld -Wl,--build-id=none -o lzss.elf start.S lzss.c
# Step 3: extract the raw binary image (buffers in .bss are not part of the image).
${TC}objcopy -O binary lzss.elf lzss.bin
# Step 4: convert the binary into one 32-bit hex word per line, padded to the full memory size.
python3 - "$WORDS" <<'PY'
import sys, struct
# This is the number of memory words to emit.
words = int(sys.argv[1])
# This reads the raw program image and pads it to whole words.
data = open("lzss.bin", "rb").read()
data += b"\0" * (-len(data) % 4)
# This unpacks it into little-endian 32-bit words.
w = list(struct.unpack("<%dI" % (len(data) // 4), data))
# This pads with zeros up to the memory size.
w += [0] * (words - len(w))
# This writes the hex file.
open("lzss.hex", "w").write("".join("%08x\n" % x for x in w))
print("image: %d bytes" % len(data))
PY
# Step 5: print section sizes; text+data+bss must stay below 0xB00 (2816) so the stack has room.
${TC}size lzss.elf
