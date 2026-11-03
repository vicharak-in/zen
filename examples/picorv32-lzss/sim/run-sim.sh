#!/usr/bin/env bash
# This script simulates the LZSS firmware on the CPU and checks the compressed bytes against the Python reference.
# Part 1 runs the unchanged CPU system on its own over its UART pins; part 2 runs the Zen 4 board top, driven through real Zen Link frames.
# Run from anywhere:  bash sim/run-sim.sh   (needs iverilog and python3; the firmware is firmware/riscv/src/lzss.hex, run build.sh there first)
set -e
# Run from the project folder whatever the current directory is
cd "$(dirname "$0")/.."

# This is the number of input bytes in lzss-in.hex.
N=$(wc -l < sim/lzss-in.hex)
# This lists the RTL files; the register-file wrapper is included only when the board has one (Zen4), and must come first.
RTL="rtl/picorv32-regs-bram.v rtl/zen-picorv32-top.v rtl/picorv32.v"
# This compiles and runs the testbench.
TMP=$(mktemp -d)
iverilog -g2012 -P tb_lzss_core.NBYTES=$N -o "$TMP/t.vvp" sim/tb-lzss-core.v $RTL
vvp -N "$TMP/t.vvp" > "$TMP/out.txt"
# This compares the board's reply bytes with the Python reference encoder and decodes them back to the input.
python3 - "$TMP/out.txt" <<'PY'
import sys
sys.path.insert(0, "sim")
import lzss_ref
# The input bytes.
data = bytes(int(l, 16) for l in open("sim/lzss-in.hex"))
# The reply bytes printed by the testbench.
lines = open(sys.argv[1]).read().split("\n")
assert "ACK 00" in lines, "no reset acknowledge from the board"
got = bytes(int(l.split()[1], 16) for l in lines if l.startswith("OUT"))
ref = lzss_ref.compress_stream(data)
print("board output: %d bytes, reference: %d bytes, identical: %s" % (len(got), len(ref), got == ref))
print("decompresses back to the input: %s" % (lzss_ref.decompress_stream(got, len(data)) == data))
t = [l for l in lines if l.startswith("TIME")]
if t:
    ps = int(t[0].split()[1]); n = len(data)
    print("whole exchange (UART + compression): %.1f ms for %d bytes = %.0f bytes/s" % (ps / 1e9, n, n / (ps / 1e12)))
print("PASS" if got == ref and "[tb] DONE" in lines else "FAIL")
PY
# Part 2: the board top with the Zen Link (the first 200 bytes, to keep it short)
echo "=== picorv32-lzss-zen4-top through the Zen Link"
iverilog -g2012 -Wall -Wno-timescale -Isim -o "$TMP/z.vvp" sim/tb-lzss-zink.v rtl/picorv32-lzss-zen4-top.v rtl/zink/zen-link.v rtl/zink/zl-slave.v rtl/zink/zl-regs.v rtl/zl-afifo.v rtl/zl-uart-bridge.v $RTL
head -200 sim/lzss-in.hex > "$TMP/in200.hex"
vvp -N "$TMP/z.vvp" +in="$TMP/in200.hex" +n=200 +out="$TMP/zout.hex" | tee "$TMP/z.log" | tail -3
python3 - "$TMP/zout.hex" "$TMP/z.log" <<'PY'
import sys
sys.path.insert(0, "sim")
import lzss_ref
data = bytes(int(l, 16) for l in open("sim/lzss-in.hex"))[:200]
got = bytes(int(x, 16) for x in open(sys.argv[1]).read().split())
ok = got == lzss_ref.compress_stream(data) and "DONE" in open(sys.argv[2]).read() and "FAIL" not in open(sys.argv[2]).read()
print("Zen Link run: %d reply bytes, identical to the reference: %s" % (len(got), ok))
print("PASS" if ok else "FAIL")
sys.exit(0 if ok else 1)
PY
rm -rf "$TMP"
