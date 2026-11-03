#!/usr/bin/env python3
"""webcam_sobel.py - laptop webcam -> Zen FPGA Sobel filter -> live window, picture size changeable while running.

Pipeline: webcam -> gray W x H -> USB serial -> RP2350 (UART bridge) -> FPGA Sobel -> RP2350 -> USB serial -> window.
Keys in the window: 1..6 pick a size (80x60, 128x96, 160x120, 256x192, 320x240, 640x480), q quits.
Run `python webcam_sobel.py --sim` to try the window with a software Sobel instead of the board.
"""

# Standard library.
import argparse
import sys
import threading
import time

# Third-party.
import numpy as np
import cv2

# Bridge chunk size: the RP2350 reads the USB stream in blocks of this many bytes, so every frame is padded to a multiple.
CH = 128

# MicroPython program run on the RP2350: copies bytes between the USB serial port and the FPGA UART (UART1, GPIO24 TX / GPIO25 RX).
BRIDGE_CODE = """
import sys, select
from machine import UART, Pin
u = UART(1, baudrate=%(baud)d, tx=Pin(24), rx=Pin(25), rxbuf=16384, txbuf=8192, timeout=0)
p = select.poll()
p.register(sys.stdin, select.POLLIN)
src = sys.stdin.buffer
dst = sys.stdout.buffer
buf = bytearray(%(ch)d)
while True:
    if p.poll(0):
        n = src.readinto(buf)
        if n:
            u.write(memoryview(buf)[:n])
    k = u.any()
    if k:
        dst.write(u.read(k))
"""


# Picture sizes on the number keys 1..6.
SIZES = [(80, 60), (128, 96), (160, 120), (256, 192), (320, 240), (640, 480)]


# Software model of the FPGA filter: border 0, inner pixels min(255, |Gx| + |Gy|).
def sobel_ref(img):
    # Work in signed integers so differences do not wrap.
    a = img.astype(np.int32)
    # Output starts as all zeros (the border stays 0).
    out = np.zeros_like(a)
    # Top, middle and bottom rows of every 3x3 neighbourhood, for the inner pixels.
    t, m, b = a[:-2], a[1:-1], a[2:]
    # Horizontal gradient: right column minus left column, weights 1, 2, 1.
    gx = (t[:, 2:] + 2 * m[:, 2:] + b[:, 2:]) - (t[:, :-2] + 2 * m[:, :-2] + b[:, :-2])
    # Vertical gradient: bottom row minus top row, weights 1, 2, 1.
    gy = (b[:, :-2] + 2 * b[:, 1:-1] + b[:, 2:]) - (t[:, :-2] + 2 * t[:, 1:-1] + t[:, 2:])
    # Magnitude clamped to a byte, written into the inner region.
    out[1:-1, 1:-1] = np.minimum(np.abs(gx) + np.abs(gy), 255)
    # Back to bytes.
    return out.astype(np.uint8)


# Stand-in for the board: runs the same filter in software.
class SimLink:
    # Nothing to set up.
    def __init__(self, baud=0):
        pass

    # Filter one gray picture (numpy array) and return the result picture.
    def process(self, gray):
        return sobel_ref(gray)

    # Nothing to close.
    def close(self):
        pass


# Link to the real board through the RP2350's USB serial port.
class ZenLink:
    # Open the port and start the UART bridge on the RP2350.
    def __init__(self, port, fpga_baud=921600, ser=None):
        self.fpga_baud = fpga_baud
        # Open the serial port (a ready-made object can be passed in for tests).
        if ser is None:
            import serial
            ser = serial.Serial(port, 115200, timeout=0.1)
        self.ser = ser
        # Bigger OS buffers where the driver supports it (Windows).
        try:
            self.ser.set_buffer_size(rx_size=1 << 16, tx_size=1 << 16)
        except Exception:
            pass
        self._start_bridge()
        # Reader thread: collects everything the board sends.
        self.buf = bytearray()
        self.lock = threading.Lock()
        self.alive = True
        self.thread = threading.Thread(target=self._reader, daemon=True)
        self.thread.start()

    # Stop whatever runs on the board, enter the raw REPL and start the bridge program.
    def _start_bridge(self):
        s = self.ser
        # Interrupt a running program (also stops an older bridge).
        s.write(b"\r\x03\x03")
        time.sleep(0.3)
        s.reset_input_buffer()
        # Enter the raw REPL.
        s.write(b"\x01")
        banner = s.read_until(b"raw REPL; CTRL-B to exit\r\n>")
        if not banner.endswith(b">"):
            raise RuntimeError("could not enter the raw REPL on the board; is another program (mpremote, Thonny) using the port?")
        # Send the bridge program and run it.
        code = BRIDGE_CODE % {"baud": self.fpga_baud, "ch": CH}
        s.write(code.encode())
        s.write(b"\x04")
        ok = s.read(2)
        if ok != b"OK":
            raise RuntimeError("board did not accept the bridge program: %r" % ok)
        # A running bridge prints nothing; any text now is an error message.
        time.sleep(0.4)
        extra = s.read(s.in_waiting) if s.in_waiting else b""
        if extra:
            raise RuntimeError("bridge failed on the board: " + extra.decode(errors="replace"))

    # Reader thread body: move incoming bytes into the shared buffer.
    def _reader(self):
        while self.alive:
            try:
                n = self.ser.in_waiting
                data = self.ser.read(n if n else 1)
            except Exception:
                break
            if data:
                with self.lock:
                    self.buf += data

    # Send one gray picture (numpy array) and return the filtered picture, or None if the board did not answer in time.
    def process(self, gray):
        h, w = gray.shape
        need = w * h
        # Frame: sync byte, width and height (little endian), then the pixels.
        data = bytes([0xA5, w & 255, w >> 8, h & 255, h >> 8]) + gray.tobytes()
        # Pad to a multiple of the bridge chunk with 0xFF; the FPGA ignores bytes after the frame.
        pad = (-len(data)) % CH
        with self.lock:
            self.buf.clear()
        self.ser.write(data + b"\xff" * pad)
        # Generous time limit: three times the UART time plus a second.
        deadline = time.time() + 3 * len(data) * 10.0 / self.fpga_baud + 1.0
        while time.time() < deadline:
            with self.lock:
                if len(self.buf) >= need:
                    return np.frombuffer(bytes(self.buf[:need]), np.uint8).reshape(h, w)
            time.sleep(0.002)
        # Timed out: wait longer than the FPGA stall timeout (100 ms) so it drops the half frame, then start clean.
        time.sleep(0.3)
        with self.lock:
            self.buf.clear()
        return None

    # Stop the bridge and release the port.
    def close(self):
        self.alive = False
        try:
            self.ser.write(b"\x03")
            time.sleep(0.1)
            self.ser.write(b"\x02")
            self.ser.close()
        except Exception:
            pass


# Turn a camera frame into the W x H gray bytes the FPGA expects.
def prepare(frame, w, h):
    gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY) if frame.ndim == 3 else frame
    small = cv2.resize(gray, (w, h), interpolation=cv2.INTER_AREA)
    # 0x03 is the Ctrl-C byte, which would stop the RP2350 program, so use 4 instead.
    small[small == 3] = 4
    return small


# Open a camera index or a video/image file.
def open_source(args):
    if args.file:
        img = cv2.imread(args.file)
        if img is not None:
            return None, img
        cap = cv2.VideoCapture(args.file)
    else:
        cap = cv2.VideoCapture(args.cam)
    if not cap.isOpened():
        sys.exit("cannot open the camera / file")
    return cap, None


# Main loop.
def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--port", help="serial port of the Zen, e.g. COM8")
    ap.add_argument("--sim", action="store_true", help="use a software Sobel instead of the board")
    ap.add_argument("--w", type=int, default=160, help="start width (3..640)")
    ap.add_argument("--h", type=int, default=120, help="start height (3..480)")
    ap.add_argument("--baud", type=int, default=921600, help="UART speed between RP2350 and FPGA (must match the FPGA build: 27 = 921600, 12 = 2083333, 8 = 3125000)")
    ap.add_argument("--cam", type=int, default=0, help="webcam index")
    ap.add_argument("--file", help="video or image file instead of a webcam")
    ap.add_argument("--scale", type=int, default=6, help="window upscale factor (shrinks for big pictures)")
    ap.add_argument("--no-check", action="store_true", help="skip the comparison with the software Sobel")
    ap.add_argument("--no-gui", action="store_true", help="no window (use with --frames)")
    ap.add_argument("--frames", type=int, default=0, help="stop after this many frames (0 = until q)")
    args = ap.parse_args()
    if not args.sim and not args.port:
        sys.exit("give --port COMx, or use --sim")
    link = SimLink() if args.sim else ZenLink(args.port, args.baud)
    w, h = args.w, args.h
    cap, still = open_source(args)
    n = bad_frames = lost = 0
    t0 = time.time()
    try:
        while True:
            ok, frame = (True, still) if still is not None else cap.read()
            if not ok:
                break
            gray = prepare(frame, w, h)
            tf = time.time()
            edges = link.process(gray)
            dt = time.time() - tf
            n += 1
            if edges is None:
                lost += 1
                print("frame %d: no answer from the board" % n)
                continue
            ref = sobel_ref(gray)
            mism = int(np.count_nonzero(edges != ref))
            if not args.no_check and mism:
                bad_frames += 1
            fps = n / (time.time() - t0)
            if not args.no_gui:
                scale = max(1, min(args.scale, 1800 // (3 * w)))
                up = lambda im: cv2.resize(im, None, fx=scale, fy=scale, interpolation=cv2.INTER_NEAREST)
                # Colour pane: the same small picture, in colour (colour never goes to the FPGA).
                col = cv2.resize(frame, (w, h), interpolation=cv2.INTER_AREA)
                if col.ndim == 2:
                    col = cv2.cvtColor(col, cv2.COLOR_GRAY2BGR)
                to_bgr = lambda im: cv2.cvtColor(im, cv2.COLOR_GRAY2BGR)
                show = np.hstack([up(col), up(to_bgr(gray)), up(to_bgr(edges))])
                pw = w * scale
                cv2.putText(show, "colour (laptop)", (6, 18), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 255, 255), 1)
                cv2.putText(show, "black & white %dx%d (sent)" % (w, h), (pw + 6, 18), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 255, 255), 1)
                cv2.putText(show, "Zen Sobel %.1f fps %.0f KB/s diff vs numpy: %d" % (fps, 2 * w * h / max(dt, 1e-6) / 1000.0, mism),
                            (2 * pw + 6, 18), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 255, 255), 1)
                cv2.imshow("Zen Sobel", show)
                key = cv2.waitKey(1) & 0xFF
                if key == ord("q"):
                    break
                if ord("1") <= key < ord("1") + len(SIZES):
                    w, h = SIZES[key - ord("1")]
            if args.frames and n >= args.frames:
                break
    finally:
        link.close()
        if cap is not None:
            cap.release()
        if not args.no_gui:
            cv2.destroyAllWindows()
    print("frames %d, lost %d, frames differing from the software Sobel %d, %.1f fps"
          % (n, lost, bad_frames, n / max(time.time() - t0, 1e-9)))


# Run when started as a script.
if __name__ == "__main__":
    main()
