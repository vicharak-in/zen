#!/usr/bin/env bash
# This script simulates the hardware compressor with Icarus Verilog and checks every output byte against lzss_ref.py (the reference encoder / decoder).
# Part 1 runs the unchanged lzss_hw_top on its own over the UART lines; part 2 runs the Zen 4 board top, driven through real Zen Link frames.
# Run from this folder:  bash run-sim.sh
set -e
cd "$(dirname "$0")"
TOOLS=../firmware/pc-tools
TMP=$(mktemp -d)
# Part 1: the core on its own.
iverilog -g2012 -o "$TMP/sim.out" ../rtl/uart-rx.v ../rtl/uart-tx.v ../rtl/lzss-core.v ../rtl/rx-fifo.v ../rtl/lzss-hw-top.v tb-lzss-hw-core.v
# Part 2: the board top with the Zen Link.
iverilog -g2012 -Wall -Wno-timescale -I. -o "$TMP/zink.out" ../rtl/uart-rx.v ../rtl/uart-tx.v ../rtl/lzss-core.v ../rtl/rx-fifo.v ../rtl/lzss-hw-top.v ../rtl/zink/zen-link.v ../rtl/zink/zl-slave.v ../rtl/zink/zl-regs.v ../rtl/zl-afifo.v ../rtl/zl-uart-bridge.v ../rtl/lzss-zen4-top.v tb-lzss-zink.v
# This Python helper makes the test inputs, runs the simulations and compares with the reference.
python3 - "$TMP" "$TOOLS" <<'PY'
import os, random, subprocess, sys
tmp, tools = sys.argv[1:3]
sys.path.insert(0, tools)
import lzss_ref
random.seed(5)
# Test inputs: name -> bytes.
text = open(os.path.join(tools, "lzss_ref.py"), "rb").read()
csv = open(os.path.join(tools, "samples", "fakeimu.csv"), "rb").read() if os.path.exists(os.path.join(tools, "samples", "fakeimu.csv")) else b""
cases = {
    "one byte": b"x",
    "short text": b"hello hello hello hello",
    "exactly 64": bytes(range(64)),
    "65 bytes": b"abc" * 21 + b"zz",
    "zeros 300": bytes(300),
    "repeat 18": b"abcdefghijklmnopqrstuvwxyz" * 20,
    "random 700": bytes(random.randrange(256) for _ in range(700)),
    "source text": text[:2500],
    "history wrap": (b"0123456789abcdef" * 8 + bytes(random.randrange(256) for _ in range(600)) + b"0123456789abcdef" * 8),
}
if csv:
    cases["fakeimu head"] = csv[:2500]
fail = 0
# ---------------- Part 1: the core alone ----------------
for name, data in cases.items():
    inp, outp = os.path.join(tmp, "in.hex"), os.path.join(tmp, "out.hex")
    open(inp, "w").write("".join("%02x\n" % b for b in data))
    r = subprocess.run(["vvp", os.path.join(tmp, "sim.out"), "+in=" + inp, "+out=" + outp, "+n=%d" % len(data), "+dec=" + os.path.join(tmp, "dec.hex")], capture_output=True, text=True)
    lines = [l for l in r.stdout.splitlines() if l.startswith(("DONE", "FAIL"))]
    if not lines or lines[0].startswith("FAIL"):
        print("FAIL  %-14s %s" % (name, lines or r.stdout[-200:])); fail += 1; continue
    got = bytes(int(x, 16) for x in open(outp).read().split())
    want = lzss_ref.compress_stream(data)
    dec = bytes(int(x, 16) for x in open(os.path.join(tmp, "dec.hex")).read().split())
    ok = got == want and dec == data
    fail += not ok
    print("%s  %-14s %5d -> %5d bytes (reference %d)  hardware decode %s" % ("ok  " if ok else "FAIL", name, len(data), len(got), len(want), "exact" if dec == data else "WRONG (%d bytes)" % len(dec)))
# Fast-baud runs: switch the link to a shorter bit time with the 0x7E command, run a full compress + decode there, then return to the default rate.
for name in ("source text", "fakeimu head", "history wrap"):
    if name not in cases:
        continue
    data = cases[name]
    inp, outp = os.path.join(tmp, "in.hex"), os.path.join(tmp, "out.hex")
    open(inp, "w").write("".join("%02x\n" % b for b in data))
    for div in (8, 11):
        r = subprocess.run(["vvp", os.path.join(tmp, "sim.out"), "+in=" + inp, "+out=" + outp, "+n=%d" % len(data), "+dec=" + os.path.join(tmp, "dec.hex"), "+div=%d" % div], capture_output=True, text=True)
        got = bytes(int(x, 16) for x in open(outp).read().split()) if os.path.exists(outp) else b""
        dec = bytes(int(x, 16) for x in open(os.path.join(tmp, "dec.hex")).read().split())
        ok = got == lzss_ref.compress_stream(data) and dec == data and "BAUD back-to-default ok" in r.stdout
        fail += not ok
        print("%s  %-14s at %d clocks/bit (default 16): compress + decode exact, back to default rate: %s" % ("ok  " if ok else "FAIL", name, div, "yes" if ok else r.stdout[-120:]))
# Pipelined runs: the next block is sent while the FPGA is still working on the previous one (and at a fast baud too).
for name in ("source text", "fakeimu head", "history wrap", "repeat 18"):
    if name not in cases:
        continue
    data = cases[name]
    inp, outp = os.path.join(tmp, "in.hex"), os.path.join(tmp, "out.hex")
    open(inp, "w").write("".join("%02x\n" % b for b in data))
    for extra in ([], ["+div=8"]):
        r = subprocess.run(["vvp", os.path.join(tmp, "sim.out"), "+in=" + inp, "+out=" + outp, "+n=%d" % len(data), "+dec=" + os.path.join(tmp, "dec.hex"), "+pipe"] + extra, capture_output=True, text=True)
        got = bytes(int(x, 16) for x in open(outp).read().split()) if os.path.exists(outp) else b""
        ok = got == lzss_ref.compress_stream(data)
        fail += not ok
        print("%s  %-14s pipelined%s: compress exact" % ("ok  " if ok else "FAIL", name, " at 8 clocks/bit" if extra else ""))
# Stream runs: the host sends chunks behind 0x7D / 0x7C and the core cuts the blocks itself (also at a fast baud).
for name in ("one byte", "exactly 64", "65 bytes", "source text", "fakeimu head", "history wrap", "random 700", "repeat 18"):
    if name not in cases:
        continue
    data = cases[name]
    inp, outp = os.path.join(tmp, "in.hex"), os.path.join(tmp, "out.hex")
    open(inp, "w").write("".join("%02x\n" % b for b in data))
    for extra in (["+stream", "+dstream"], ["+stream", "+dstream", "+div=8"]):
        r = subprocess.run(["vvp", os.path.join(tmp, "sim.out"), "+in=" + inp, "+out=" + outp, "+n=%d" % len(data), "+dec=" + os.path.join(tmp, "dec.hex")] + extra, capture_output=True, text=True)
        got = bytes(int(x, 16) for x in open(outp).read().split()) if os.path.exists(outp) else b""
        dec = bytes(int(x, 16) for x in open(os.path.join(tmp, "dec.hex")).read().split())
        ok = got == lzss_ref.compress_stream(data) and dec == data
        fail += not ok
        print("%s  %-14s stream%s: compress exact + decode exact" % ("ok  " if ok else "FAIL", name, " at 8 clocks/bit" if "+div=8" in extra else ""))
# Idle fallback: after a long silence at the fast rate the link must answer at the default rate again.
open(inp, "w").write("00\n")
r = subprocess.run(["vvp", os.path.join(tmp, "sim.out"), "+in=" + inp, "+out=" + outp, "+n=1", "+idle"], capture_output=True, text=True)
ok = "IDLE fallback ok" in r.stdout
fail += not ok
print("%s  idle timeout returns the link to the default baud rate" % ("ok  " if ok else "FAIL " + r.stdout[-120:]))

# ---------------- Part 2: the Zen 4 board top through the Zen Link ----------------
def blocks_of(comp):
    """Split a compressed stream into its [C][C bytes] blocks."""
    out, i = [], 0
    while i < len(comp):
        out.append(comp[i:i + 1 + comp[i]]); i += 1 + comp[i]
    return out

def zink_run(cmd, nrx, extra=()):
    """Run the Zen Link testbench with a command byte stream; returns (reply bytes, stdout)."""
    cf, of = os.path.join(tmp, "cmd.hex"), os.path.join(tmp, "zout.hex")
    open(cf, "w").write("".join("%02x\n" % b for b in cmd))
    if os.path.exists(of):
        os.remove(of)
    r = subprocess.run(["vvp", os.path.join(tmp, "zink.out"), "+cmd=" + cf, "+ncmd=%d" % len(cmd), "+nrx=%d" % nrx, "+out=" + of] + list(extra), capture_output=True, text=True)
    got = bytes(int(x, 16) for x in open(of).read().split()) if os.path.exists(of) else b""
    return got, r.stdout

def block_cmds(data):
    """Reset, then one compress command per 64-byte block; returns (command bytes, expected reply)."""
    cmd = bytearray(b"\x00")
    for i in range(0, len(data), 64):
        blk = data[i:i + 64]
        cmd += bytes([len(blk)]) + blk
    return bytes(cmd), b"\x00" + lzss_ref.compress_stream(data)

def stream_cmds(data):
    """Reset, then 0x7D chunks of up to 448 bytes; returns (command bytes, expected reply)."""
    cmd = bytearray(b"\x00")
    for i in range(0, len(data), 448):
        ch = data[i:i + 448]
        cmd += bytes([0x7D, len(ch) & 255, len(ch) >> 8]) + ch
    return bytes(cmd), b"\x00" + lzss_ref.compress_stream(data)

def decode_cmds(data):
    """Reset, then one decode command (0x80 | C) per compressed block; returns (command bytes, expected reply)."""
    comp = lzss_ref.compress_stream(data)
    cmd, exp = bytearray(b"\x00"), bytearray(b"\x00")
    pos = 0
    for b in blocks_of(comp):
        cmd += bytes([0x80 | b[0]]) + b[1:]
        n = min(64, len(data) - pos)
        exp += bytes([n]) + data[pos:pos + n]
        pos += n
    return bytes(cmd), bytes(exp)

def decode_stream_cmds(data):
    """Reset, then 0x7C groups of whole blocks (up to 448 compressed bytes); returns (command bytes, expected reply)."""
    comp = lzss_ref.compress_stream(data)
    cmd, exp = bytearray(b"\x00"), bytearray(b"\x00")
    pos, group, glen = 0, [], 0
    def flush():
        nonlocal group, glen, pos
        if group:
            cmd.extend([0x7C, glen & 255, glen >> 8])
            for b in group:
                cmd.extend(b)
                n = min(64, len(data) - pos)
                exp.extend(bytes([n]) + data[pos:pos + n]); pos += n
            group, glen = [], 0
    for b in blocks_of(comp):
        if glen + len(b) > 448:
            flush()
        group.append(b); glen += len(b)
    flush()
    return bytes(cmd), bytes(exp)

zcases = [("one byte", "one byte"), ("short text", "short text"), ("65 bytes", "65 bytes"), ("random 700", "random 700"), ("source text", "source text"), ("history wrap", "history wrap")]
for label, key in zcases:
    # At most 896 bytes (two 448-byte chunks) are sent at once, like the host tools do, so the engine's input FIFO cannot overflow
    data = cases[key][:896]
    for mode, fn in (("block commands", block_cmds), ("stream 0x7D", stream_cmds), ("decode 0x80|C", decode_cmds), ("decode stream 0x7C", decode_stream_cmds)):
        if mode.startswith("decode stream") and key not in ("source text", "history wrap", "random 700"):
            continue
        cmd, exp = fn(data)
        got, out = zink_run(cmd, len(exp))
        ok = got == exp and "DONE" in out
        fail += not ok
        print("%s  Zen Link  %-14s %-18s %5d command bytes, %5d reply bytes" % ("ok  " if ok else "FAIL", label, mode, len(cmd), len(exp)) + ("" if ok else "  " + out[-160:]))
# Fast bit time through the Zen Link: switch to 8 and 11 clocks per bit, run a stream compress and decode, switch back.
for div in (8, 11):
    data = cases["source text"][:896]
    for mode, fn in (("stream 0x7D", stream_cmds), ("decode stream 0x7C", decode_stream_cmds)):
        cmd, exp = fn(data)
        got, out = zink_run(cmd, len(exp), ["+div=%d" % div])
        ok = got == exp and "BAUD back-to-default ok" in out
        fail += not ok
        print("%s  Zen Link  source text    %-18s at %d clocks/bit, back to default: %s" % ("ok  " if ok else "FAIL", mode, div, "yes" if ok else out[-160:]))
print("ALL PASSED" if not fail else "%d FAILED" % fail)
sys.exit(1 if fail else 0)
PY
rm -rf "$TMP"
