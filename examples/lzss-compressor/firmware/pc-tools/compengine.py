# This is the command-line tool for the compression engine: it compresses a file on the Zen board (LZSS on the soft CPU) and decompresses it again on the PC.
#   python firmware\pc-tools\compengine.py compress   FILE [-o OUT] [-p COMx] [--check-reference]
#   python firmware\pc-tools\compengine.py decompress FILE [-o OUT] [--force]
# (the wrappers compress.cmd and decompress.cmd in the emu folder shorten this to:  .\compress FILE   and   .\decompress FILE.lzb )
# Compress needs pyserial (pip install pyserial) and the board running the LZSS firmware; decompress needs neither.
import argparse
import os
import struct
import sys
import threading
import time

import lzss_ref

# Container header: 4 magic bytes, then the original length as a 32-bit number. LZB1 = LZSS block stream, LZB0 = stored (the data follows unchanged).
MAGIC_LZ = lzss_ref.MAGIC
MAGIC_STORED = b"LZB0"
HEADER = 8


# This error type is used for every problem the user can fix (no board, bad file, ...); main() prints its message and exits.
class ToolError(Exception):
    pass


# This function turns a byte count into text such as "97,704 bytes (95.4 KB)".
def human(n):
    # Small numbers are shown in bytes only.
    if n < 1024:
        return "%s bytes" % format(n, ",")
    # Larger numbers also get a KB or MB figure.
    if n < 1024 * 1024:
        return "%s bytes (%.1f KB)" % (format(n, ","), n / 1024.0)
    return "%s bytes (%.2f MB)" % (format(n, ","), n / (1024.0 * 1024.0))


# This function builds the .lzb file contents from the original bytes and the board's block stream, falling back to "stored" when compression does not help.
# Returns (file bytes, "LZSS" or "stored").
def pack(raw, stream):
    # Keep the compressed form only when it is really smaller than the data.
    if len(stream) < len(raw):
        return MAGIC_LZ + struct.pack("<I", len(raw)) + stream, "LZSS"
    # Otherwise store the data unchanged so the output never grows by more than the 8-byte header.
    return MAGIC_STORED + struct.pack("<I", len(raw)) + raw, "stored"


# This function turns .lzb file contents back into the original bytes; it raises ValueError with a readable message when the file is not valid.
def unpack(blob):
    # A valid file has at least the 8-byte header.
    if len(blob) < HEADER:
        raise ValueError("the file is too short to be a compengine file")
    # Read the format tag and the original length.
    magic, total = blob[:4], struct.unpack("<I", blob[4:8])[0]
    body = blob[HEADER:]
    # Stored files carry the original bytes directly.
    if magic == MAGIC_STORED:
        if len(body) != total:
            raise ValueError("the stored file is truncated or has extra data")
        return body
    # LZSS files carry the block stream; damaged data shows up as an index or value error while decoding.
    if magic == MAGIC_LZ:
        try:
            raw = lzss_ref.decompress_stream(body, total)
        except (IndexError, ValueError):
            raise ValueError("the compressed data is damaged or truncated")
        if len(raw) != total:
            raise ValueError("the decompressed length does not match the header")
        return raw
    raise ValueError("not a compengine file (unknown header %r)" % magic)


# This function finds the serial port of the USB-serial adapter: COMPENGINE_PORT if set, otherwise the only CH340 adapter (USB id 1a86) that is plugged in.
def find_port():
    # An explicit choice in the environment wins.
    env = os.environ.get("COMPENGINE_PORT")
    if env:
        return env
    try:
        from serial.tools import list_ports
    except ImportError:
        raise ToolError("pyserial is not installed. Run:  pip install pyserial")
    # Collect the CH340 adapters.
    found = [p.device for p in list_ports.comports() if p.vid == 0x1A86]
    if len(found) == 1:
        return found[0]
    raise ToolError("could not pick the adapter automatically (found %s). Give the port with  -p COMx" % (found or "none"))


# This function opens the serial port at 115200 8N1 with a 5 s read timeout.
def open_serial(port):
    try:
        import serial
    except ImportError:
        raise ToolError("pyserial is not installed. Run:  pip install pyserial")
    try:
        return serial.Serial(port, 115200, timeout=5)
    except Exception as e:
        raise ToolError("cannot open %s (%s). Is another program using it?" % (port, e))


# Every program switches off Ctrl-C handling first and then sends one "R" byte, and the PC waits for it before sending data (a data byte 0x03 arriving earlier would interrupt the program).
# This is the MicroPython program the tool starts on the RP2350: it copies bytes between USB and the FPGA's UART bridge on the Zen Link.
# PC -> RP frames: one length byte N (1..255) then N bytes, which go to the FPGA; N = 0 ends the bridge. RP -> PC: every byte the FPGA sends, unchanged.
# The length-prefix keeps the stream binary-safe (Ctrl-C handling is switched off in the program, so any byte value can be sent).
BRIDGE_SRC = """
import micropython
micropython.kbd_intr(-1)
import sys, select
u = ZinkUART()
u.set_cpb(217)
i = sys.stdin.buffer
o = sys.stdout.buffer
p = select.poll()
p.register(sys.stdin, select.POLLIN)
o.write(b"R")
def need(n):
    b = b""
    while len(b) < n:
        c = i.read(n - len(b))
        if c:
            b += c
    return b
run = True
while run:
    n = u.any()
    if n:
        o.write(u.read(n))
    if p.poll(0):
        n = need(1)[0]
        if n == 0:
            run = False
        else:
            u.write(need(n))
"""


# This is the MicroPython program for the RP2350 "engine" mode: the PC sends only [u32 length][file bytes]; the RP2350 cuts the data into 64-byte blocks,
# runs the block protocol with the FPGA over the Zen Link and streams the .lzb container back: LZB1 + u32 length, then [C][C bytes] per block, then 0xFF.
# If the FPGA stops answering it sends 0xFE 0x01 instead of the end marker (a block length is never above 72, so these values are unambiguous).
ENGINE_SRC = """
import micropython
micropython.kbd_intr(-1)
import sys
u = ZinkUART(timeout=3000, timeout_char=200)
u.set_cpb({defdiv})
i = sys.stdin.buffer
o = sys.stdout.buffer
o.write(b"R")
def need(n):
    b = b""
    while len(b) < n:
        c = i.read(n - len(b))
        if c:
            b += c
    return b
def reply(n):
    b = u.read(n)
    if b is None or len(b) != n:
        raise OSError
    return b
def link(d, b):
    u.write(bytes([0x7e, d]))
    if reply(1) != b"\\x7e":
        raise OSError
    u.set_cpb(d)
    u.read(u.any())
rb = b""
def blocks(nb):
    global rb
    while nb:
        i = 0
        while nb and i < len(rb) and i + 1 + rb[i] <= len(rb):
            if rb[i] > 80:
                raise OSError
            i += 1 + rb[i]
            nb -= 1
        if i:
            o.write(rb[:i])
            rb = rb[i:]
        if nb:
            d = u.read(max(u.any(), 1))
            if not d:
                raise OSError
            rb += d
n = int.from_bytes(need(4), "little")
o.write(b"LZB1" + n.to_bytes(4, "little"))
left = n
try:
    u.read(u.any())
    u.write(b"\\x00")
    if reply(1) != b"\\x00":
        raise OSError
    if {div} != {defdiv}:
        link({div}, {rpbaud})
    q = []
    while left or q:
        while left and len(q) < 2:
            k = min(448, left)
            blk = need(k)
            left -= k
            u.write(bytes([0x7d, k & 255, k >> 8]) + blk)
            q.append((k + 63) // 64)
        blocks(q.pop(0))
    o.write(b"\\xff")
    if {div} != {defdiv}:
        link({defdiv}, 115200)
except OSError:
    while left:
        k = min(64, left)
        need(k)
        left -= k
    o.write(b"\\xfe\\x01")
    if {div} != {defdiv}:
        try:
            link({defdiv}, 115200)
        except OSError:
            u.set_cpb({defdiv})
"""


# This is the MicroPython program for the RP2350 decode mode: the PC sends [u32 length of the block stream][the block stream: C, C bytes, ...];
# the RP2350 sends every block to the FPGA decoder as 0x80|C + bytes and streams the raw data back as [count][bytes] per block, then 0xFF (or 0xFE 0x01 on failure).
DECODE_SRC = """
import micropython
micropython.kbd_intr(-1)
import sys
u = ZinkUART(timeout=3000, timeout_char=200)
u.set_cpb({defdiv})
i = sys.stdin.buffer
o = sys.stdout.buffer
o.write(b"R")
def need(n):
    b = b""
    while len(b) < n:
        c = i.read(n - len(b))
        if c:
            b += c
    return b
def reply(n):
    b = u.read(n)
    if b is None or len(b) != n:
        raise OSError
    return b
def link(d, b):
    u.write(bytes([0x7e, d]))
    if reply(1) != b"\\x7e":
        raise OSError
    u.set_cpb(d)
    u.read(u.any())
rb = b""
def blocks(nb):
    global rb
    while nb:
        i = 0
        while nb and i < len(rb) and i + 1 + rb[i] <= len(rb):
            if rb[i] > 80:
                raise OSError
            i += 1 + rb[i]
            nb -= 1
        if i:
            o.write(rb[:i])
            rb = rb[i:]
        if nb:
            d = u.read(max(u.any(), 1))
            if not d:
                raise OSError
            rb += d
left = int.from_bytes(need(4), "little")
try:
    u.read(u.any())
    u.write(b"\\x00")
    if reply(1) != b"\\x00":
        raise OSError
    if {div} != {defdiv}:
        link({div}, {rpbaud})
    q = []
    pend = None
    while left > 0 or pend or q:
        while (left > 0 or pend) and len(q) < 2:
            grp = bytearray()
            nb = 0
            while left > 0 or pend:
                if pend:
                    blk = pend
                    pend = None
                else:
                    k = need(1)[0]
                    blk = bytes([k]) + need(k)
                    left -= len(blk)
                if grp and (len(grp) + len(blk) > 448 or nb >= 7):
                    pend = blk
                    break
                grp += blk
                nb += 1
            u.write(bytes([0x7c, len(grp) & 255, len(grp) >> 8]) + grp)
            q.append(nb)
        blocks(q.pop(0))
    o.write(b"\\xff")
    if {div} != {defdiv}:
        link({defdiv}, 115200)
except OSError:
    while left > 0:
        k = need(1)[0]
        need(k)
        left -= 1 + k
    o.write(b"\\xfe\\x01")
    if {div} != {defdiv}:
        try:
            link({defdiv}, 115200)
        except OSError:
            u.set_cpb({defdiv})
"""


# This is the helper class that lets the RP2350 programs talk to the FPGA over the Zen Link like a UART (zink_uart.py in this folder); it is sent in front of every program.
with open(os.path.join(os.path.dirname(os.path.abspath(__file__)), "zink_uart.py")) as _f:
    ZINK_SRC = _f.read()


# This function builds the text sent to the RP2350: the Zen Link helper class, then the program with its numbers filled in.
def program_text(src, **fmt):
    return ZINK_SRC + "\n" + src.format(**fmt)


# This function reads from the port until the data ends with `tail` or the time runs out; it returns what it read.
def read_until(ser, tail, seconds):
    got = b""
    end = time.time() + seconds
    while time.time() < end and not got.endswith(tail):
        got += ser.read(1)
    return got


# This function runs a MicroPython program on the RP2350 through its raw REPL (the same mechanism mpremote uses); the program keeps the port afterwards.
def start_program(ser, source):
    # A relay left running by an earlier run ends on a zero frame; on a normal prompt this byte does nothing.
    ser.write(b"\x00")
    time.sleep(0.2)
    # Stop whatever the RP2350 is running, then enter the raw REPL.
    ser.write(b"\x03\x03")
    time.sleep(0.2)
    ser.reset_input_buffer()
    ser.write(b"\x01")
    if not read_until(ser, b"CTRL-B to exit\r\n>", 3).endswith(b">"):
        raise ToolError("the RP2350 did not answer on this port. Is it the board's own USB port (not the UART adapter), and no other program using it?")
    # Send the program in small pieces, then run it with Ctrl-D.
    code = source.encode()
    for k in range(0, len(code), 128):
        ser.write(code[k:k + 128])
        time.sleep(0.01)
    ser.write(b"\x04")
    if not read_until(ser, b"OK", 3).endswith(b"OK"):
        raise ToolError("the RP2350 did not accept the program")
    # Wait for the ready byte: the program has switched off Ctrl-C handling and set up the Zen Link.
    got = read_until(ser, b"R", 3)
    if not got.endswith(b"R"):
        raise ToolError("the program on the RP2350 did not start%s" % ((": " + got.decode("latin-1").strip()[:120]) if got else ""))


# This function starts the relay program (USB <-> UART, used by rp-check.py).
def start_bridge(ser):
    start_program(ser, program_text(BRIDGE_SRC))


# This class wraps the RP2350's USB port so it looks like the UART adapter: writes become length-prefixed frames, reads pass straight through.
class RpSerial:
    def __init__(self, ser):
        self.ser = ser

    def reset_input_buffer(self):
        self.ser.reset_input_buffer()

    def write(self, data):
        for k in range(0, len(data), 255):
            chunk = data[k:k + 255]
            self.ser.write(bytes([len(chunk)]) + chunk)

    def read(self, n):
        return self.ser.read(n)

    # This pushes pending bytes out (the frames are written at once, so there is nothing to wait for).
    def flush(self):
        self.ser.flush()

    # The read timeout in seconds, passed on to the USB serial port.
    @property
    def timeout(self):
        return self.ser.timeout

    @timeout.setter
    def timeout(self, value):
        self.ser.timeout = value

    # This ends the bridge (zero frame) and returns the RP2350 to its normal prompt.
    def close(self):
        try:
            self.ser.write(b"\x00")
            time.sleep(0.2)
            self.ser.write(b"\x02")
        finally:
            self.ser.close()


# This class is the port of the RP2350 while the engine program runs: plain reads and writes; closing returns the RP2350 to its normal prompt.
class EngineSerial:
    def __init__(self, ser):
        self.ser = ser

    # This throws away unread bytes.
    def reset_input_buffer(self):
        self.ser.reset_input_buffer()

    # This sends bytes to the RP2350.
    def write(self, data):
        return self.ser.write(data)

    # This reads up to n bytes.
    def read(self, n):
        return self.ser.read(n)

    # This returns the number of bytes waiting.
    @property
    def in_waiting(self):
        return self.ser.in_waiting

    # This leaves the raw REPL and closes the port.
    def close(self):
        try:
            self.ser.write(b"\x02")
        finally:
            self.ser.close()


# This is the FPGA clock in Hz, the default UART rate and the divisor (clocks per bit) the FPGA uses at that rate.
FPGA_CLOCK = 25_000_000
DEFAULT_BAUD = 115200
DEFAULT_DIV = 217


# This function turns a wanted baud rate into the FPGA divisor (8..255 clocks per bit) and the exact RP2350 rate that matches it; it raises ToolError if the rate cannot be made.
def baud_params(baud):
    if baud == DEFAULT_BAUD:
        return dict(div=DEFAULT_DIV, rpbaud=DEFAULT_BAUD, defdiv=DEFAULT_DIV)
    div = round(FPGA_CLOCK / baud)
    if not 8 <= div <= 255:
        raise ToolError("baud rate %d is not possible: it must be between %d and %d" % (baud, FPGA_CLOCK // 255, FPGA_CLOCK // 8))
    return dict(div=div, rpbaud=round(FPGA_CLOCK / div), defdiv=DEFAULT_DIV)


# This function opens the RP2350's USB port and starts a program on it: the relay (engine=False) or the compression engine (engine=True).
def open_rp(port, engine=False, program=None, baud=DEFAULT_BAUD):
    ser = open_serial(port)
    try:
        if engine:
            ser.write_timeout = 10
            start_program(ser, program_text(program or ENGINE_SRC, **baud_params(baud)))
        else:
            start_bridge(ser)
    except Exception:
        ser.close()
        raise
    return EngineSerial(ser) if engine else RpSerial(ser)


# This function opens the link to the FPGA design for the small test scripts: "COM7" is a USB-serial adapter on the header pins, "rp:COM8" is the RP2350 relay (Zen Link).
# The result has write, read, flush, reset_input_buffer and close, like a pyserial port.
def open_link(spec, timeout=5):
    if spec.lower().startswith("rp:"):
        ser = open_rp(spec[3:])
        ser.timeout = timeout
        return ser
    try:
        import serial
    except ImportError:
        raise ToolError("pyserial is missing: pip install pyserial")
    return serial.Serial(spec, 115200, timeout=timeout)


# This message explains what to check when the FPGA does not answer the RP2350.
FPGA_SILENT = ("the FPGA did not answer the RP2350. Check: bitstream loaded (CDONE = 1) and built from the Zen Link version of lzss-compressor (top module lzss_zen4_top), btn1 pressed, "
               "and that the LZSS firmware (not the echo test) is loaded.")


# This function sends a payload to an RP2350 program that answers with [count][bytes] blocks ending in 0xFF; it returns the blocks.
# header: bytes the answer must start with (or b"").  maxc: largest legal count.  keep_counts: keep the count bytes in the result (compress) or drop them (decompress).
def rp_stream(ser, payload, header, maxc, keep_counts, progress):
    ser.reset_input_buffer()
    # State shared with the reader thread.
    st = {"err": None, "end": False, "out": bytearray()}

    # This thread collects the answer, checking the framing as it goes.
    def collect():
        buf, stage, last = bytearray(), ("head" if header else "blocks"), time.time()
        while not st["end"] and not st["err"]:
            if time.time() - last > 15:
                st["err"] = "the RP2350 stopped answering"
                return
            chunk = ser.read(max(1, ser.in_waiting))
            if chunk:
                buf += chunk
                last = time.time()
            while not st["end"] and not st["err"]:
                if stage == "head":
                    if len(buf) < len(header):
                        break
                    if bytes(buf[:len(header)]) != header:
                        st["err"] = "unexpected data from the RP2350 (is the right program running?)"
                        return
                    del buf[:len(header)]
                    stage = "blocks"
                else:
                    if not buf:
                        break
                    c = buf[0]
                    if c == 0xFF:
                        st["end"] = True
                    elif c == 0xFE:
                        st["err"] = FPGA_SILENT
                    elif c > maxc:
                        st["err"] = "damaged data from the RP2350"
                    elif len(buf) >= 1 + c:
                        st["out"] += buf[:1 + c] if keep_counts else buf[1:1 + c]
                        del buf[:1 + c]
                    else:
                        break

    th = threading.Thread(target=collect, daemon=True)
    th.start()
    try:
        for k in range(0, len(payload), 256):
            ser.write(payload[k:k + 256])
            progress(min(k + 256, len(payload)))
            if st["err"]:
                break
    except Exception as e:
        st["err"] = st["err"] or "lost the connection to the RP2350 (%s)" % e
    th.join(30)
    if st["err"]:
        raise ToolError(st["err"])
    if not st["end"]:
        raise ToolError("the RP2350 did not finish")
    return bytes(st["out"])


# This function sends the whole file to the RP2350 compression engine and returns the block stream (what board_compress returns).
def rp_compress(ser, raw, progress):
    return rp_stream(ser, struct.pack("<I", len(raw)) + raw, MAGIC_LZ + struct.pack("<I", len(raw)), 80, True, progress)


# This function sends a block stream to the RP2350 decode program and returns the raw data the FPGA decoded.
def rp_decompress(ser, body, progress):
    return rp_stream(ser, struct.pack("<I", len(body)) + body, b"", 64, False, progress)


# This function decodes a block stream on the FPGA through the UART adapter, block by block, and returns the raw data.
def board_decompress(ser, body, progress):
    ser.reset_input_buffer()
    ser.write(b"\x00")
    if read_exact(ser, 1) != b"\x00":
        raise ToolError("unexpected reply to the reset command; is the LZSS firmware or hardware engine loaded?")
    out, pos = bytearray(), 0
    while pos < len(body):
        k = body[pos]
        # One block: 0x80 | compressed length, then the compressed bytes; the reply is the raw count and the raw bytes.
        ser.write(bytes([0x80 | k]) + body[pos + 1:pos + 1 + k])
        n = read_exact(ser, 1)
        out += read_exact(ser, n[0])
        pos += 1 + k
        progress(pos)
    return bytes(out)


# This function reads exactly n bytes from the port or raises a ToolError that says what to check.
def read_exact(ser, n):
    b = ser.read(n)
    if len(b) != n:
        raise ToolError("the board did not answer (expected %d byte, got %d). Check: bitstream loaded (CDONE = 1), btn1 pressed, "
                        "wiring R-05 -> adapter RXD, R-06 -> adapter TXD, GND, and that the LZSS firmware (not the echo test) is loaded." % (n, len(b)))
    return b


# This function sends the data to the board block by block and returns the block stream it sends back.
# ser: the open port.  raw: the data.  progress: called with the number of bytes done after each block.
def board_compress(ser, raw, progress):
    # Throw away anything left in the input buffer.
    ser.reset_input_buffer()
    # Reset the board's history: send 0, expect 0 back.
    ser.write(b"\x00")
    if read_exact(ser, 1) != b"\x00":
        raise ToolError("unexpected reply to the reset command; is the LZSS firmware loaded?")
    stream = bytearray()
    for start in range(0, len(raw), lzss_ref.BLOCK):
        # One block: length byte, then the bytes.
        blk = raw[start:start + lzss_ref.BLOCK]
        ser.write(bytes([len(blk)]) + blk)
        # Reply: compressed length, then that many bytes.
        n = read_exact(ser, 1)
        stream += n + read_exact(ser, n[0])
        progress(start + len(blk))
    return bytes(stream)


# This function builds a progress callback that rewrites one console line (only when the output is a terminal).
def make_progress(total):
    # Start time and the time of the last redraw.
    t0 = time.time()
    last = [0.0]

    def progress(done):
        # Redraw at most 5 times a second, and always at the end.
        now = time.time()
        if not sys.stdout.isatty() or (now - last[0] < 0.2 and done < total):
            return
        last[0] = now
        # Estimate the time left from the speed so far.
        speed = done / max(now - t0, 1e-9)
        eta = (total - done) / speed if speed else 0
        sys.stdout.write("\r  sending   %3d%%   %s / %s   about %d s left   " % (100 * done // max(total, 1), format(done, ","), format(total, ","), eta))
        sys.stdout.flush()
    return progress


# This function compresses one file through the board and writes the .lzb file; it returns a dict of the results and does not print anything itself.
# open_port: function that opens the port (replaced by a simulated board in the tests).
def compress_file(src, dst, port, open_port=open_serial, check_reference=False, progress=None, transfer=None):
    if os.path.isdir(src):
        raise ToolError("%s is a folder; compress takes one file at a time for now" % src)
    if not os.path.isfile(src):
        raise ToolError("file not found: %s" % src)
    raw = open(src, "rb").read()
    t0 = time.time()
    # An empty file needs no board.
    if len(raw) == 0:
        stream = b""
    else:
        ser = open_port(port)
        try:
            stream = (transfer or board_compress)(ser, raw, progress or (lambda done: None))
        finally:
            ser.close()
    seconds = time.time() - t0
    blob, kind = pack(raw, stream)
    # The result must decompress back to the input; this is checked before anything is written.
    if unpack(blob) != raw:
        raise ToolError("internal check failed: the compressed data does not decompress to the original; nothing was saved")
    # Optionally compare with the Python reference encoder (slow on big files).
    same_as_reference = None
    if check_reference and raw:
        same_as_reference = stream == lzss_ref.compress_stream(raw)
    replaced = os.path.exists(dst)
    with open(dst, "wb") as f:
        f.write(blob)
    return {"src": os.path.abspath(src), "dst": os.path.abspath(dst), "original": len(raw), "compressed": len(blob), "kind": kind,
            "seconds": seconds, "port": port, "same_as_reference": same_as_reference, "replaced": replaced}


# This function chooses the output name for decompress: the .lzb name without its suffix, never overwriting an existing file (it adds ".restored" instead).
def restored_name(src):
    # Remove ".lzb" if present, otherwise add ".restored".
    base = src[:-4] if src.lower().endswith(".lzb") else src + ".restored"
    if not os.path.exists(base):
        return base
    # The plain name is taken (probably the original): put ".restored" before the extension, then number it if needed.
    stem, ext = os.path.splitext(base)
    cand, i = stem + ".restored" + ext, 2
    while os.path.exists(cand):
        cand = "%s.restored%d%s" % (stem, i, ext)
        i += 1
    return cand


# This function decompresses one .lzb file and writes the restored file; it returns a dict of the results.
# With open_port and transfer the LZSS data is decoded by the FPGA (and compared with the PC's own decode); otherwise the PC decodes it.
def decompress_file(src, dst=None, force=False, open_port=None, transfer=None, port=None, progress=None):
    if not os.path.isfile(src):
        raise ToolError("file not found: %s" % src)
    blob = open(src, "rb").read()
    t0 = time.time()
    try:
        raw = unpack(blob)
    except ValueError as e:
        raise ToolError("%s: %s" % (src, e))
    kind = "stored" if blob[:4] == MAGIC_STORED else "LZSS"
    via, hw_match = "PC", None
    # Decode on the FPGA when asked, the data is LZSS and not empty; the PC's decode above is the reference to compare with.
    if open_port and transfer and kind == "LZSS" and len(raw) > 0:
        ser = open_port(port)
        try:
            hw = transfer(ser, blob[HEADER:], progress or (lambda done: None))
        finally:
            ser.close()
        hw_match = (hw == raw)
        if not hw_match:
            raise ToolError("the FPGA decoded different data than the PC (%d vs %d bytes); nothing was saved" % (len(hw), len(raw)))
        via = "board"
    seconds = time.time() - t0
    # Choose the output name.
    if dst is None:
        dst = restored_name(src)
    elif os.path.exists(dst) and not force:
        raise ToolError("%s already exists; use --force to overwrite it or choose another name with -o" % dst)
    with open(dst, "wb") as f:
        f.write(raw)
    return {"src": os.path.abspath(src), "dst": os.path.abspath(dst), "compressed": len(blob), "restored": len(raw),
            "kind": kind, "seconds": seconds, "via": via, "port": port, "hw_match": hw_match}


# This function prints the result of a compress run.
def report_compress(r):
    o, c = r["original"], r["compressed"]
    print("  original    %s" % human(o))
    print("  compressed  %s    (%s)" % (human(c), "LZSS" if r["kind"] == "LZSS" else "stored: this data does not compress, so it was kept as is"))
    if o:
        change = 100.0 * (o - c) / o
        print("  ratio       %.1f%% of the original size    %s %s" % (100.0 * c / o, "saved" if change >= 0 else "grew by", human(abs(o - c))))
    print("  saved to    %s%s" % (r["dst"], "   (replaced an earlier file)" if r["replaced"] else ""))
    if o:
        print("  time        %.1f s on the board (%s), %.1f KB/s" % (r["seconds"], r["port"], o / 1024.0 / max(r["seconds"], 1e-9)))
    print("  check       decompresses back to the original: yes")
    if r["same_as_reference"] is not None:
        print("  reference   board output identical to the Python reference encoder: %s" % ("yes" if r["same_as_reference"] else "NO"))


# This function prints the result of a decompress run.
def report_decompress(r):
    print("  compressed  %s    (%s)" % (human(r["compressed"]), r["kind"]))
    print("  restored    %s" % human(r["restored"]))
    print("  saved to    %s" % r["dst"])
    if r.get("via") == "board":
        print("  time        %.1f s on the board (%s)" % (r["seconds"], r["port"]))
        print("  check       the FPGA's decoded data is identical to the PC's decode: yes")
    else:
        print("  time        %.2f s on the PC" % r["seconds"])


# This is the command-line entry point.
def main(argv=None):
    ap = argparse.ArgumentParser(prog="compengine", description="Compress files on the Zen board (LZSS) and decompress them on the PC.")
    sub = ap.add_subparsers(dest="cmd", required=True)
    c = sub.add_parser("compress", help="compress FILE through the board and write FILE.lzb")
    c.add_argument("file")
    c.add_argument("-o", "--output", help="output file (default: FILE.lzb next to the input)")
    c.add_argument("-p", "--port", help="serial port of the USB-serial adapter, e.g. COM7 (default: the only CH340 adapter found)")
    c.add_argument("--rp", metavar="COMx", help="send the data through the RP2350 (its own USB port, e.g. COM8) instead of the UART adapter")
    c.add_argument("--baud", type=int, default=921600, help="serial speed between the Zen Link bridge and the engine inside the FPGA, switched at run time (default 921600; 115200 keeps the slow default)")
    c.add_argument("--check-reference", action="store_true", help="also compare the board's output with the Python reference encoder (slow for big files)")
    d = sub.add_parser("decompress", help="restore a .lzb file")
    d.add_argument("file")
    d.add_argument("-o", "--output", help="output file (default: the name without .lzb, or NAME.restored.EXT if that exists)")
    d.add_argument("--rp", metavar="COMx", help="decode on the FPGA through the RP2350 (its own USB port, e.g. COM8) instead of on the PC")
    d.add_argument("--baud", type=int, default=921600, help="serial speed between the Zen Link bridge and the engine inside the FPGA, switched at run time (default 921600; 115200 keeps the slow default)")
    d.add_argument("-p", "--port", help="decode on the FPGA through the USB-serial adapter on this port, e.g. COM7")
    d.add_argument("--force", action="store_true", help="overwrite the output file if it exists")
    a = ap.parse_args(argv)
    try:
        if a.cmd == "compress":
            dst = a.output or a.file + ".lzb"
            rp = a.rp or os.environ.get("COMPENGINE_RP")
            opener, transfer = open_serial, None
            if rp:
                port = rp
                opener = lambda p: open_rp(p, engine=True, baud=a.baud)
                transfer = rp_compress
            elif os.path.isfile(a.file) and os.path.getsize(a.file) > 0:
                port = a.port or find_port()
            else:
                port = a.port or "-"
            print("Compressing  %s" % os.path.abspath(a.file))
            size = os.path.getsize(a.file) if os.path.isfile(a.file) else 0
            r = compress_file(a.file, dst, port, open_port=opener, transfer=transfer, check_reference=a.check_reference, progress=make_progress(size))
            if sys.stdout.isatty():
                sys.stdout.write("\r" + " " * 78 + "\r")
            report_compress(r)
        else:
            print("Decompressing  %s" % os.path.abspath(a.file))
            if not os.path.isfile(a.file):
                raise ToolError("file not found: %s (compress a file first; the output is FILE.lzb)" % a.file)
            rp = a.rp
            if rp:
                opener = lambda p: open_rp(p, engine=True, program=DECODE_SRC, baud=a.baud)
                r = decompress_file(a.file, a.output, a.force, open_port=opener, transfer=rp_decompress, port=rp, progress=make_progress(os.path.getsize(a.file)))
            elif a.port:
                r = decompress_file(a.file, a.output, a.force, open_port=open_serial, transfer=board_decompress, port=a.port, progress=make_progress(os.path.getsize(a.file)))
            else:
                r = decompress_file(a.file, a.output, a.force)
            if sys.stdout.isatty():
                sys.stdout.write("\r" + " " * 78 + "\r")
            report_decompress(r)
    except ToolError as e:
        print("error: %s" % e, file=sys.stderr)
        return 1
    return 0


# This runs main() when the script is executed directly.
if __name__ == "__main__":
    sys.exit(main())
