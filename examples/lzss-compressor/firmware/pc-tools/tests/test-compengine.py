# This tests firmware/pc-tools/compengine.py without hardware: a simulated board speaks the same byte protocol as the real engine and uses the reference encoder.
# The RP2350 programs run for real (CPython with stub modules), including the Zen Link helper class zink_uart.py, against a fake Zen Link register interface.
# Run from the emu folder:  python3 tests/test-compengine.py
import os
import random
import struct
import subprocess
import sys
import tempfile

# Make the tools folder importable.
HERE = os.path.dirname(os.path.abspath(__file__))
TOOLS = os.path.join(HERE, "..")
sys.path.insert(0, TOOLS)
import compengine
import lzss_ref


# This class pretends to be the serial port of the board: it keeps the history like the firmware and answers each request with the reference encoder's bytes.
class FakeBoard:
    def __init__(self, silent=False):
        # Bytes written by the PC and not yet processed, bytes waiting for the PC to read, and all data of the current file so far.
        self.rx, self.tx, self.data, self.silent = bytearray(), bytearray(), bytearray(), silent
        # The UART speed the fake FPGA listens at right now, and every speed it was switched to.
        self.baud, self.baud_log = 115200.0, []

    def reset_input_buffer(self):
        pass

    def close(self):
        pass

    # The PC writes: handle complete requests (0 = reset, else length + bytes).
    def write(self, b):
        self.rx += b
        while self.rx and not self.silent:
            n = self.rx[0]
            if n in (0x7D, 0x7C):
                # Stream request: 0x7D / 0x7C, 16-bit length, then the whole stream; the fake cuts blocks like the FPGA does and answers block by block.
                if len(self.rx) < 3:
                    return
                total = self.rx[1] | (self.rx[2] << 8)
                if len(self.rx) < 3 + total:
                    return
                body = bytes(self.rx[3:3 + total]); del self.rx[:3 + total]
                self.streams = getattr(self, "streams", 0) + 1
                if n == 0x7D:
                    for off in range(0, total, 64):
                        blk = body[off:off + 64]
                        start = len(self.data); self.data += blk
                        enc = lzss_ref.encode_block(bytes(self.data), start, len(self.data))
                        self.tx += bytes([len(enc)]) + enc
                else:
                    p = 0
                    while p < total:
                        k = body[p]; chunk = body[p + 1:p + 1 + k]; p += 1 + k
                        self.write(bytes([0x80 | k]) + chunk)
                continue
            if n & 0x80:
                # Decode request: 0x80 | length, then that many compressed bytes; the reply is the raw count and the raw bytes.
                k = n & 0x7F
                if len(self.rx) < 1 + k:
                    return
                chunk = bytes(self.rx[1:1 + k]); del self.rx[:1 + k]
                bits = "".join(format(x, "08b") for x in chunk)
                q, produced = 0, bytearray()
                while len(bits) - q >= 9:
                    if bits[q] == "0":
                        produced.append(int(bits[q + 1:q + 9], 2)); q += 9
                    else:
                        d = int(bits[q + 1:q + 10], 2) + 1; l = int(bits[q + 10:q + 14], 2) + 3; q += 14
                        for _ in range(l):
                            produced.append((self.data + produced)[-d])
                self.data += produced
                self.tx += bytes([len(produced)]) + bytes(produced)
                continue
            if n == 0x7E:
                # Baud command: 0x7E + clocks per bit; the acknowledge goes out at the old rate, then the new rate applies (values below 8 mean the default 217).
                if len(self.rx) < 2:
                    return
                d = self.rx[1]; del self.rx[:2]
                self.tx += b"\x7e"
                self.baud = 25e6 / (d if d >= 8 else 217); self.baud_log.append(d)
                continue
            if n == 0:
                self.rx.pop(0); self.data = bytearray(); self.tx += b"\x00"
                continue
            if len(self.rx) < 1 + n:
                return
            blk = bytes(self.rx[1:1 + n]); del self.rx[:1 + n]
            start = len(self.data); self.data += blk
            enc = lzss_ref.encode_block(bytes(self.data), start, len(self.data))
            self.tx += bytes([len(enc)]) + enc

    # The PC reads up to n bytes.
    def read(self, n):
        out = bytes(self.tx[:n]); del self.tx[:n]
        return out


# This helper makes a fake-board opener.
def opener(**kw):
    return lambda port: FakeBoard(**kw)


# This helper fails the test if the board is opened at all.
def no_board(port):
    raise AssertionError("the board must not be used for this file")


# Collected check count.
checks = 0


# This helper records one check.
def check(cond, msg):
    global checks
    checks += 1
    assert cond, msg
    print("  ok  " + msg)


tmp = tempfile.mkdtemp()
random.seed(3)

import time as _real_time
# MicroPython's tick functions, so the real zink_uart.py runs on CPython.
_real_time.ticks_ms = lambda: int(_real_time.time() * 1000)
_real_time.ticks_diff = lambda a, b: a - b


# This builds a fake `fpga` module (the board's Zen Link API) in front of a fake board: it models the UART bridge registers of the FPGA design.
# A byte written reaches the board only when the bridge's clocks-per-bit match the rate the board listens at (like the real serial line).
def make_fpga(board):
    import types as _t
    st = {"cpb": 217, "rxq": bytearray(), "up": True}
    def deliver(data):
        if abs(25e6 / st["cpb"] - board.baud) > 0.01 * board.baud:
            return
        board.write(bytes(data))
        st["rxq"] += board.read(len(board.tx))
    def read(addr):
        if addr == 0x102: return min(255, len(st["rxq"]))
        if addr == 0x103: return 255
        if addr == 0x100: return st["rxq"].pop(0) if st["rxq"] else 0
        if addr == 0x101: return 0x12
        if addr == 0x104: return st["cpb"] & 255
        if addr == 0x105: return st["cpb"] >> 8
        return 0
    def write(addr, v):
        if addr == 0x100: deliver([v])
        elif addr == 0x104: st["cpb"] = (st["cpb"] & 0xFF00) | v
        elif addr == 0x105: st["cpb"] = (st["cpb"] & 0x00FF) | (v << 8)
    def write_block(addr, data):
        assert 0x180 <= addr <= 0x1FF and len(data) <= 128
        deliver(data)
    def read_block(addr, buf):
        assert 0x180 <= addr <= 0x1FF and len(buf) <= 128
        for k in range(len(buf)):
            buf[k] = st["rxq"].pop(0)
    return _t.SimpleNamespace(init=lambda: None, link_ok=lambda: st["up"], read=read, write=write, write_block=write_block, read_block=read_block, state=st)

# 1. A text file: output equals the reference container, ratio below 100%, round trip exact.
text = (open(os.path.join(TOOLS, "lzss_ref.py"), "rb").read()) * 2
src = os.path.join(tmp, "notes.txt"); open(src, "wb").write(text)
r = compengine.compress_file(src, src + ".lzb", "COMx", open_port=opener(), check_reference=True)
blob = open(src + ".lzb", "rb").read()
check(blob == lzss_ref.MAGIC + struct.pack("<I", len(text)) + lzss_ref.compress_stream(text), "text file: container equals the reference encoder's")
check(r["kind"] == "LZSS" and r["compressed"] < r["original"] and r["same_as_reference"] is True, "text file: smaller (%d -> %d), identical to reference" % (r["original"], r["compressed"]))
d = compengine.decompress_file(src + ".lzb")
check(os.path.basename(d["dst"]) == "notes.restored.txt", "decompress next to the original does not overwrite it (wrote %s)" % os.path.basename(d["dst"]))
check(open(d["dst"], "rb").read() == text and open(src, "rb").read() == text, "restored file equals the original; original untouched")
d2 = compengine.decompress_file(src + ".lzb")
check(os.path.basename(d2["dst"]) == "notes.restored2.txt", "a second decompress picks a new name (%s)" % os.path.basename(d2["dst"]))

# 2. Incompressible data is stored, so the output grows by only the 8-byte header.
rnd = bytes(random.randrange(256) for _ in range(5000))
p = os.path.join(tmp, "noise.bin"); open(p, "wb").write(rnd)
r = compengine.compress_file(p, p + ".lzb", "COMx", open_port=opener())
check(r["kind"] == "stored" and r["compressed"] == len(rnd) + 8, "random data: stored, only +8 bytes (%d -> %d)" % (len(rnd), r["compressed"]))
check(open(compengine.decompress_file(p + ".lzb")["dst"], "rb").read() == rnd, "random data round trip exact")

# 3. An empty file needs no board.
e = os.path.join(tmp, "empty.dat"); open(e, "wb").write(b"")
r = compengine.compress_file(e, e + ".lzb", "-", open_port=no_board)
check(r["compressed"] == 8 and open(compengine.decompress_file(e + ".lzb")["dst"], "rb").read() == b"", "empty file: no board used, round trip exact")

# 4. A path with spaces, and an explicit output name.
sp = os.path.join(tmp, "my folder"); os.makedirs(sp)
q = os.path.join(sp, "a b.v"); open(q, "wb").write(b"module m; endmodule\n" * 50)
out = os.path.join(sp, "custom.lzb")
r = compengine.compress_file(q, out, "COMx", open_port=opener())
check(os.path.exists(out) and r["dst"] == os.path.abspath(out), "path with spaces and -o name work")
try:
    compengine.decompress_file(out, q)
    check(False, "decompress must refuse to overwrite an existing -o file")
except compengine.ToolError as ex:
    check("already exists" in str(ex), "decompress refuses to overwrite an existing -o file without --force")
compengine.decompress_file(out, q, force=True)
check(open(q, "rb").read() == b"module m; endmodule\n" * 50, "--force overwrites")

# 5. Damaged files give a clear error, never a crash.
good = open(src + ".lzb", "rb").read()
for name, bad in (("truncated", good[:len(good) // 2]), ("wrong header", b"XXXX" + good[4:]), ("too short", b"LZB"),
                  ("garbage body", good[:8] + bytes(random.randrange(256) for _ in range(len(good) - 8)))):
    b = os.path.join(tmp, "bad.lzb"); open(b, "wb").write(bad)
    try:
        compengine.decompress_file(b)
        check(False, name + " must be rejected")
    except compengine.ToolError as ex:
        check(True, "%s file rejected: %s" % (name, str(ex).split(": ", 1)[-1]))

# 6. Board problems give a clear message.
try:
    compengine.compress_file(src, src + ".x", "COMx", open_port=opener(silent=True))
    check(False, "a silent board must raise")
except compengine.ToolError as ex:
    check("did not answer" in str(ex), "silent board: clear message")
try:
    compengine.compress_file(sp, sp + ".lzb", "COMx", open_port=no_board)
    check(False, "a folder must be refused")
except compengine.ToolError as ex:
    check("folder" in str(ex), "folder refused with a clear message")

# 7. Command line, run as a real process: decompress needs no board or pyserial.
cli = [sys.executable, os.path.join(TOOLS, "compengine.py")]
res = subprocess.run(cli + ["decompress", src + ".lzb", "-o", os.path.join(tmp, "cli_out.txt")], capture_output=True, text=True)
check(res.returncode == 0 and open(os.path.join(tmp, "cli_out.txt"), "rb").read() == text, "CLI decompress works as a separate process")
print(res.stdout)
res = subprocess.run(cli + ["decompress", os.path.join(tmp, "missing.lzb")], capture_output=True, text=True)
check(res.returncode == 1 and "file not found" in res.stderr, "CLI: missing file -> exit 1 and a message")
env = dict(os.environ); env.pop("COMPENGINE_PORT", None)
res = subprocess.run(cli + ["compress", src], capture_output=True, text=True, env=env)
check(res.returncode == 1 and res.stderr.startswith("error:"), "CLI compress without pyserial/board: clear error (%s)" % res.stderr.strip()[:80])


# 8. Through the RP2350 bridge. First the real MicroPython bridge program is run against stub modules, then the PC side against a fake RP2350.
import types

# This runs BRIDGE_SRC with fake fpga/select/micropython modules: frames go in on "stdin", a fake FPGA answers over the Zen Link.
def run_bridge_program(frames, board):
    class Buf:
        def __init__(self, data): self.data = bytearray(data)
        def read(self, n):
            out = bytes(self.data[:n]); del self.data[:n]; return out
        def write(self, b): self.data += b
    stdin, stdout = types.SimpleNamespace(buffer=Buf(frames)), types.SimpleNamespace(buffer=Buf(b""))
    fp = make_fpga(board)
    class Poll:
        def register(self, o, f): pass
        def poll(self, timeout=0): return [(stdin, 1)] if stdin.buffer.data else []
    mods = {"fpga": fp,
            "micropython": types.SimpleNamespace(kbd_intr=lambda x: None),
            "select": types.SimpleNamespace(poll=Poll, POLLIN=1)}
    saved = (sys.stdin, sys.stdout, {k: sys.modules.get(k) for k in mods})
    sys.modules.update(mods); sys.stdin, sys.stdout = stdin, stdout
    try:
        exec(compengine.program_text(compengine.BRIDGE_SRC), {})
    finally:
        sys.stdin, sys.stdout = saved[0], saved[1]
        for k, v in saved[2].items():
            if v is None: sys.modules.pop(k, None)
            else: sys.modules[k] = v
    return bytes(stdout.buffer.data), fp

fb = FakeBoard()
frames = bytes([1]) + b"\x00" + bytes([4]) + bytes([3]) + b"abc" + bytes([0])   # reset, then a 3-byte block, then end
back, fp = run_bridge_program(frames, fb)
enc = lzss_ref.encode_block(b"abc", 0, 3)
check(back == b"R" + b"\x00" + bytes([len(enc)]) + enc, "bridge program: frames reach the FPGA over the Zen Link, replies come back unchanged")
check(fp.state["cpb"] == 217, "bridge program: starts the bridge at 217 clocks per bit (115200 baud)")


# This pretends to be an RP2350 on its USB port: raw-REPL handshake, then the bridge in front of a fake board.
class FakeRp:
    def __init__(self, broken=False):
        self.mode, self.out, self.code, self.board, self.broken, self.frame, self.closed = "repl", bytearray(), bytearray(), FakeBoard(), broken, bytearray(), False
    def reset_input_buffer(self): self.out.clear()
    def close(self): self.closed = True
    def write(self, b):
        if self.broken: return
        for x in b:
            if self.mode == "repl":
                if x == 1: self.mode = "raw"; self.out += b"raw REPL; CTRL-B to exit\r\n>"
            elif self.mode == "raw":
                if x == 4: self.mode = "bridge"; self.out += b"OKR"; self.frame.clear()
                else: self.code.append(x)
            elif self.mode == "bridge":
                self.frame.append(x)
                if self.frame[0] == 0: self.mode = "repl"; self.frame.clear()
                elif len(self.frame) == 1 + self.frame[0]:
                    self.board.write(bytes(self.frame[1:])); self.frame.clear()
                    self.out += self.board.read(len(self.board.tx))
    def read(self, n):
        out = bytes(self.out[:n]); del self.out[:n]; return out

rps = []
def open_fake_rp(port):
    fr = FakeRp(); rps.append(fr)
    compengine.start_bridge(fr)
    return compengine.RpSerial(fr)

r = compengine.compress_file(src, src + ".rp.lzb", "COM8", open_port=open_fake_rp)
check(open(src + ".rp.lzb", "rb").read() == blob, "via RP bridge: output identical to the direct path (%d -> %d)" % (r["original"], r["compressed"]))
check(rps[0].mode == "repl" and rps[0].closed and b"class ZinkUART" in bytes(rps[0].code) and b"u = ZinkUART()" in bytes(rps[0].code), "bridge ended cleanly and the program sent to the RP includes the Zen Link helper")
try:
    compengine.start_bridge(FakeRp(broken=True))
    check(False, "a dead RP port must raise")
except compengine.ToolError as ex:
    check("did not answer" in str(ex), "no RP2350 on the port: clear message")

# 9. Engine mode: the PC sends only [u32 length][file]; the real ENGINE_SRC program (run with stub modules) does the blocks.
import threading as _th
import time as _time

# This runs a MicroPython program source with a fake fpga module and a stub micropython module and returns what it wrote to stdout.
def run_program(src, stdin_bytes, board):
    class Buf:
        def __init__(self, data): self.data = bytearray(data)
        def read(self, n):
            out = bytes(self.data[:n]); del self.data[:n]; return out
        def write(self, b): self.data += b
    stdin, stdout = types.SimpleNamespace(buffer=Buf(stdin_bytes)), types.SimpleNamespace(buffer=Buf(b""))
    mods = {"fpga": make_fpga(board), "micropython": types.SimpleNamespace(kbd_intr=lambda x: None)}
    saved = (sys.stdin, sys.stdout, {k: sys.modules.get(k) for k in mods})
    sys.modules.update(mods); sys.stdin, sys.stdout = stdin, stdout
    try:
        # A short wait for the first byte keeps the silent-FPGA tests fast
        exec(src.replace("timeout=3000", "timeout=40").replace("timeout_char=200", "timeout_char=20"), {})
    finally:
        sys.stdin, sys.stdout = saved[0], saved[1]
        for k, v in saved[2].items():
            if v is None: sys.modules.pop(k, None)
            else: sys.modules[k] = v
    return bytes(stdout.buffer.data), len(stdin.buffer.data)


# This pretends to be an RP2350: raw REPL, then it runs the engine program once the PC has sent the whole request.
class FakeEngineRp:
    def __init__(self, silent=False):
        self.mode, self.out, self.code, self.inbox, self.silent, self.closed = "repl", bytearray(), bytearray(), bytearray(), silent, False
        self.lock = _th.Lock()
        self.board = FakeBoard(silent=silent)
    @property
    def in_waiting(self): return len(self.out)
    def reset_input_buffer(self):
        with self.lock: self.out.clear()
    def close(self): self.closed = True
    def write(self, b):
        for x in b:
            if self.mode == "repl":
                if x == 1: self.mode = "raw"; self.out += b"raw REPL; CTRL-B to exit\r\n>"
            elif self.mode == "raw":
                if x == 4: self.mode = "prog"; self.out += b"OKR"
                else: self.code.append(x)
            elif self.mode == "prog":
                self.inbox.append(x)
                if len(self.inbox) >= 4 and len(self.inbox) == 4 + struct.unpack("<I", bytes(self.inbox[:4]))[0]:
                    res, left = run_program(self.code.decode(), bytes(self.inbox), self.board)
                    with self.lock: self.out += res[1:] + b"\x04\x04>"
                    self.mode = "done"
    def read(self, n):
        if not self.out: _time.sleep(0.005)
        with self.lock:
            out = bytes(self.out[:n]); del self.out[:n]
        return out

def open_fake_engine(port, silent=False, baud=115200, keep=None):
    fr = FakeEngineRp(silent)
    if keep is not None: keep.append(fr)
    compengine.start_program(fr, compengine.program_text(compengine.ENGINE_SRC, **compengine.baud_params(baud)))
    return compengine.EngineSerial(fr)

r = compengine.compress_file(src, src + ".eng.lzb", "COM8", open_port=open_fake_engine, transfer=compengine.rp_compress, check_reference=True)
check(open(src + ".eng.lzb", "rb").read() == blob and r["same_as_reference"] is True, "engine mode: RP2350 does the blocks; output identical to the reference (%d -> %d)" % (r["original"], r["compressed"]))
r = compengine.compress_file(p, p + ".eng.lzb", "COM8", open_port=open_fake_engine, transfer=compengine.rp_compress)
check(r["kind"] == "stored", "engine mode: incompressible file falls back to stored")
one = os.path.join(tmp, "one.txt"); open(one, "wb").write(b"x")
r = compengine.compress_file(one, one + ".lzb", "COM8", open_port=open_fake_engine, transfer=compengine.rp_compress)
check(open(compengine.decompress_file(one + ".lzb")["dst"], "rb").read() == b"x", "engine mode: 1-byte file round trip")
exact = os.path.join(tmp, "exact.bin"); open(exact, "wb").write(b"ab" * 64)
r = compengine.compress_file(exact, exact + ".lzb", "COM8", open_port=open_fake_engine, transfer=compengine.rp_compress)
check(open(compengine.decompress_file(exact + ".lzb")["dst"], "rb").read() == b"ab" * 64, "engine mode: file of exactly 2 blocks round trip")
try:
    compengine.compress_file(src, src + ".bad", "COM8", open_port=lambda port: open_fake_engine(port, silent=True), transfer=compengine.rp_compress)
    check(False, "a silent FPGA must raise")
except compengine.ToolError as ex:
    check("FPGA did not answer" in str(ex), "engine mode: silent FPGA gives a clear message")

# This opens the decode program on a fake RP2350 whose FPGA never answers.
def open_fake_decode_silent(port, baud=115200):
    fr = FakeEngineRp(silent=True)
    compengine.start_program(fr, compengine.program_text(compengine.DECODE_SRC, **compengine.baud_params(baud)))
    return compengine.EngineSerial(fr)

# 10. Decode on the board: through the RP2350 decode program and through the adapter path, both against the fake FPGA decoder.
def open_fake_decode(port, baud=115200, keep=None):
    fr = FakeEngineRp()
    if keep is not None: keep.append(fr)
    compengine.start_program(fr, compengine.program_text(compengine.DECODE_SRC, **compengine.baud_params(baud)))
    return compengine.EngineSerial(fr)

d = compengine.decompress_file(src + ".eng.lzb", os.path.join(tmp, "hw_dec.txt"), open_port=open_fake_decode, transfer=compengine.rp_decompress, port="COM8")
check(d["via"] == "board" and d["hw_match"] is True and open(d["dst"], "rb").read() == text, "decode through the RP2350: FPGA output equals the PC decode (%d bytes)" % d["restored"])
d = compengine.decompress_file(exact + ".lzb", os.path.join(tmp, "hw_dec2.bin"), open_port=open_fake_decode, transfer=compengine.rp_decompress, port="COM8")
check(open(d["dst"], "rb").read() == b"ab" * 64, "decode through the RP2350: file of exactly 2 blocks")
d = compengine.decompress_file(p + ".eng.lzb", os.path.join(tmp, "hw_dec3.bin"), open_port=no_board, transfer=compengine.rp_decompress, port="COM8")
check(d["via"] == "PC" and open(d["dst"], "rb").read() == rnd, "stored (incompressible) file is not sent to the board")
d = compengine.decompress_file(src + ".eng.lzb", os.path.join(tmp, "hw_dec4.txt"), open_port=lambda port: FakeBoard(), transfer=compengine.board_decompress, port="COM7")
check(d["via"] == "board" and open(d["dst"], "rb").read() == text, "decode through the UART adapter path")
try:
    compengine.decompress_file(src + ".eng.lzb", os.path.join(tmp, "hw_dec5.txt"), open_port=lambda port: open_fake_decode_silent(port), transfer=compengine.rp_decompress, port="COM8")
    check(False, "a silent FPGA decoder must raise")
except compengine.ToolError as ex:
    check("FPGA did not answer" in str(ex), "decode: silent FPGA gives a clear message")



# 11. Baud switching: at 921600 and 2000000 the programs switch the fake FPGA and the RP2350 UART, finish correctly, and return to the default rate.
for want in (921600, 2000000):
    kept = []
    r = compengine.compress_file(src, src + ".fast.lzb", "COM8", open_port=lambda port: open_fake_engine(port, baud=want, keep=kept), transfer=compengine.rp_compress)
    bp = compengine.baud_params(want)
    board = kept[0].board
    check(open(src + ".fast.lzb", "rb").read() == blob and board.baud_log == [bp["div"], 217] and board.streams >= 2,
          "compress at %d: same output, FPGA divisor %d then back to the default (log %s)" % (want, bp["div"], board.baud_log))
    kept = []
    d = compengine.decompress_file(src + ".eng.lzb", os.path.join(tmp, "fast_dec.txt"), True, open_port=lambda port: open_fake_decode(port, baud=want, keep=kept), transfer=compengine.rp_decompress, port="COM8")
    check(d["hw_match"] is True and kept[0].board.baud_log == [bp["div"], 217], "decode at %d: FPGA output equals the PC decode, link back to the default rate" % want)
check(compengine.baud_params(921600)["rpbaud"] == 925926 and compengine.baud_params(2000000)["div"] == 12, "baud helper: 921600 -> divisor 27, 2000000 -> divisor 12")
try:
    compengine.baud_params(10_000_000)
    check(False, "an impossible baud rate must raise")
except compengine.ToolError:
    check(True, "baud helper rejects a rate the FPGA cannot make")

print("\nALL %d CHECKS PASSED" % checks)
