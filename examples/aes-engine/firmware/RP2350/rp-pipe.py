# rp-pipe.py - MicroPython script for the RP2350 on the Zen board.
# It is a framed pipe between the USB serial port (the PC) and the AES engine in the FPGA, which it reaches over the Zen Link (zink_uart.py, copy it to the board too).
# Frames PC -> RP:  [n][n bytes]            send the n bytes (1..250) to the engine
#                   [0][b2][b1][b0]         change the engine's UART rate to the 24 bit baud number b2 b1 b0 (the bridge's clocks per bit = 25 MHz / baud)
# Frames RP -> PC:  [n][n bytes]            n bytes (1..250) that came from the engine
# Run it with:  mpremote run rp-pipe.py   (or save it as main.py on the RP2350). The aes-engine bitstream must be loaded first.

import sys                      # USB serial access
import select                   # Non blocking wait on the USB serial port
import time                     # Small time helpers
from zink_uart import ZinkUART  # UART-style byte stream over the Zen Link

# Clock of the AES engine in Hz (the bridge counts UART bit times on it)
CORE_CLK = 25_000_000
# Byte stream to the engine; 115200 baud (217 clocks per bit) is also the default of the engine
uart = ZinkUART()
# Polling object that tells when the PC has sent something
poll = select.poll()
# Watch the USB serial input
poll.register(sys.stdin, select.POLLIN)
# Raw binary access to the USB serial port
usb_in = sys.stdin.buffer
usb_out = sys.stdout.buffer

# Make sure a 0x03 byte from the PC is data and not a Ctrl-C (this call is not available everywhere)
try:
    import micropython
    micropython.kbd_intr(-1)
except Exception:
    pass


def usb_read_exact(n):
    """Read exactly n bytes from the PC (waits until they have arrived)."""
    out = b""                                   # Bytes collected so far
    while len(out) < n:                         # Until all have arrived
        chunk = usb_in.read(n - len(out))       # Ask for the missing bytes
        if chunk:                               # Something came
            out += chunk                        # Keep it
    return out                                  # Done


def to_pc(data):
    """Send bytes from the engine to the PC in frames of at most 250 bytes."""
    i = 0                                       # Position in the data
    while i < len(data):                        # Until everything is sent
        part = data[i:i + 250]                  # Next piece
        usb_out.write(bytes([len(part)]) + part)  # Length byte, then the bytes
        i += len(part)                          # Move on
    usb_out.flush() if hasattr(usb_out, "flush") else None  # Push it out now


# Start from the engine default
uart.set_cpb(217)

# Main loop: forward both directions forever
while True:
    # PC to engine: a frame header is waiting
    if poll.poll(0):
        n = usb_read_exact(1)[0]                # Frame length
        if n == 0:                              # Baud rate change frame
            b = usb_read_exact(3)               # The 24 bit baud rate
            baud = (b[0] << 16) | (b[1] << 8) | b[2]
            uart.set_cpb(CORE_CLK // baud)      # Apply it as clocks per bit
        else:
            uart.write(usb_read_exact(n))       # Hand the payload to the engine
    # Engine to PC: forward whatever has arrived
    if uart.any():
        data = uart.read()                      # Everything that is waiting
        if data:
            to_pc(data)                         # Forward it in frames
