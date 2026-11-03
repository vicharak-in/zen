# quadrature-decoder.py - MicroPython for the RP2350 on the Zen 4: reads the 8-byte packets from the FPGA quadrature decoder and prints position, speed, angle and direction.
# Ported from the Shrike Arduino example. The packets come over the Zen Link (zink_uart.py, copy it to the board too). Packet: 0xAA, position (int16), speed (int16), angle (uint16), flags (bit 0 = forward), all big endian.
#
# Test encoder (on by default): the FPGA has a built-in test encoder that this script drives through the Zen Link register CTRL1 (address 0x11: bit 0 = use the test encoder,
# bit 1 = A, bit 2 = B), so the design can be tried without a real encoder. Set USE_TEST_ENCODER = False to read a real encoder on the header pads R-05 (A) and R-06 (B).

import fpga
from zink_uart import ZinkUART
import time

CPR = 4000                  # Counts per revolution, must match the FPGA parameter
USE_TEST_ENCODER = True     # True: the RP2350 generates a test encoder signal inside the FPGA (no wires needed)
CTRL1 = 0x11                # Zen Link control register 1 (test encoder control)

# UART-style byte stream over the Zen Link
uart = ZinkUART()

# Gray-code sequence of (A, B): forward is index +1, reverse is index -1
SEQ = ((0, 0), (0, 1), (1, 1), (1, 0))

if USE_TEST_ENCODER:
    phase = 0
    direction_fwd = True
    steps_left = 400
    fpga.write(CTRL1, 1)      # switch the FPGA to the test encoder
else:
    fpga.write(CTRL1, 0)      # use the header pads

def test_encoder_step():
    """Advance the test encoder by one count, turning around every 400 counts."""
    global phase, direction_fwd, steps_left
    phase = (phase + (1 if direction_fwd else -1)) % 4
    a, b = SEQ[phase]
    fpga.write(CTRL1, 1 | (a << 1) | (b << 2))
    steps_left -= 1
    if steps_left == 0:
        direction_fwd = not direction_fwd
        steps_left = 400

def to_signed16(v):
    return v - 65536 if v >= 32768 else v

def read_packet():
    """Return (position, speed, angle_deg, forward) once a complete packet has arrived, else None."""
    # Look for the header byte
    while uart.any():
        b = uart.read(1)
        if b and b[0] == 0xAA:
            # Wait for the remaining seven bytes
            body = b""
            t0 = time.ticks_ms()
            while len(body) < 7 and time.ticks_diff(time.ticks_ms(), t0) < 50:
                if uart.any():
                    body += uart.read(7 - len(body))
            if len(body) < 7:
                return None
            position = to_signed16((body[0] << 8) | body[1])
            speed = to_signed16((body[2] << 8) | body[3])
            angle = (body[4] << 8) | body[5]
            forward = bool(body[6] & 1)
            return position, speed, angle * 360.0 / CPR, forward
    return None

print("Waiting for packets from the FPGA...")
while True:
    if USE_TEST_ENCODER:
        test_encoder_step()
        time.sleep_ms(2)
    pkt = read_packet()
    if pkt:
        position, speed, angle_deg, forward = pkt
        print("Pos: %d | Spd: %d | Ang: %.1f deg | Dir: %s" % (position, speed, angle_deg, "FWD" if forward else "REV"))
