# zink_uart.py - UART-style byte stream over the Zen Link (runs on the RP2350 of the Zen board).
# Replaces machine.UART(1, ...) for designs whose FPGA side has a zl_uart_bridge (registers at 0x100..0x105 and a burst window at 0x180..0x1FF).
# The FPGA design keeps its normal UART core; the bridge turns these bytes into the UART lines inside the FPGA.
#
#   uart = ZinkUART()
#   uart.write(b"hello")            queue bytes towards the core (waits for room)
#   uart.any()                      number of bytes the core has sent that are waiting
#   uart.read(n)                    like machine.UART.read: waits up to `timeout` ms for the first byte and then until n bytes have arrived
#                                   or `timeout_char` ms pass without a new byte; None when nothing came (the defaults, 0, return at once)
#   uart.init(baudrate=921600)      like machine.UART.init: sets the bridge's clocks per bit to core_clk // baudrate
#   uart.set_cpb(217)               change the clocks per UART bit of the bridge directly (the core must use the same rate)

import fpga
import time

# Register addresses of zl_uart_bridge
DATA, STATUS, RXCNT, TXFREE, CPB_LO, CPB_HI = 0x100, 0x101, 0x102, 0x103, 0x104, 0x105
# First address of the burst window (every address there behaves like DATA)
WINDOW = 0x180
# Largest burst the link carries in one frame
BURST = 128


class ZinkUART:
    def __init__(self, init=True, timeout=0, timeout_char=0, core_clk=25_000_000):
        """Start the link (fpga.init) and check that a Zen Link bitstream is loaded."""
        # Milliseconds read() waits for the first byte, and between bytes
        self.timeout = timeout
        self.timeout_char = timeout_char
        # Clock of the design behind the bridge, used by init(baudrate=...)
        self.core_clk = core_clk
        if init:
            fpga.init()
        if not fpga.link_ok():
            raise RuntimeError("Zen Link not up: is the Zen 4 bitstream of this example loaded?")

    def init(self, baudrate=None, **kwargs):
        """Like machine.UART.init: the baud rate becomes clocks per bit (core clock / baud rate); the other arguments are accepted and ignored."""
        if baudrate:
            self.set_cpb(self.core_clk // baudrate)
        for k in ("timeout", "timeout_char"):
            if k in kwargs:
                setattr(self, k, kwargs[k])

    def any(self):
        """Number of bytes from the core that are waiting to be read."""
        return fpga.read(RXCNT)

    def status(self):
        """STATUS register: bit0 data waiting, bit1 room to write, bit2 write overflow, bit3 receive overflow, bit4 idle."""
        return fpga.read(STATUS)

    def clear_flags(self):
        """Clear the sticky overflow flags."""
        fpga.write(STATUS, 0)

    def set_cpb(self, cpb):
        """Set the clocks per UART bit (core clock / baud rate). Do it while the line is idle."""
        fpga.write(CPB_LO, cpb & 0xFF)
        fpga.write(CPB_HI, (cpb >> 8) & 0xFF)

    def get_cpb(self):
        """Read back the clocks per UART bit."""
        return fpga.read(CPB_LO) | (fpga.read(CPB_HI) << 8)

    def write(self, data, timeout_ms=5000):
        """Queue the bytes of data towards the core, waiting for room when the FIFO is full."""
        data = bytes(data)
        i = 0
        t0 = time.ticks_ms()
        while i < len(data):
            room = fpga.read(TXFREE)
            if room == 0:
                if time.ticks_diff(time.ticks_ms(), t0) > timeout_ms:
                    raise OSError("ZinkUART write timeout")
                continue
            n = min(room, BURST, len(data) - i)
            if n == 1:
                fpga.write(DATA, data[i])
            else:
                fpga.write_block(WINDOW, data[i:i + n])
            i += n
            t0 = time.ticks_ms()
        return len(data)

    def flush(self, timeout_ms=5000):
        """Wait until everything queued has been sent on the UART line."""
        t0 = time.ticks_ms()
        while not (fpga.read(STATUS) & 0x10):
            if time.ticks_diff(time.ticks_ms(), t0) > timeout_ms:
                raise OSError("ZinkUART flush timeout")

    def _take(self, n):
        """Take up to n bytes that are waiting right now (n >= 1)."""
        out = bytearray()
        while n > 0:
            k = min(n, BURST)
            if k == 1:
                out.append(fpga.read(DATA))
            else:
                buf = bytearray(k)
                fpga.read_block(WINDOW, buf)
                out += buf
            n -= k
        return bytes(out)

    def read(self, n=None):
        """Return up to n bytes (all waiting bytes when n is None), or None when nothing arrived; waits as set by timeout and timeout_char."""
        out = bytearray()
        wait = self.timeout
        t0 = time.ticks_ms()
        while n is None or len(out) < n:
            avail = fpga.read(RXCNT)
            if avail:
                want = avail if n is None else min(avail, n - len(out))
                out += self._take(want)
                if n is None:
                    break
                wait = self.timeout_char
                t0 = time.ticks_ms()
            elif time.ticks_diff(time.ticks_ms(), t0) >= wait:
                break
        return bytes(out) if out else None

    def readinto(self, buf):
        """Fill buf with waiting bytes, return how many were stored (None when nothing is waiting)."""
        d = self.read(len(buf))
        if d is None:
            return None
        buf[:len(d)] = d
        return len(d)
