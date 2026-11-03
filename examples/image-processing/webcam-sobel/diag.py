# diag.py - board-side link test, no PC camera or Python bridge involved.
# Run:  python -m mpremote connect COM8 run diag.py
# It sends one tiny 8x8 frame to the FPGA at several baud rates and prints what comes back (64 bytes expected).

# Time functions.
import time
# UART and pins.
from machine import UART, Pin

# Picture size of the test frame.
W = 8
H = 8
# Frame: sync byte, width and height (little endian), then a gradient with a bright box.
pix = bytearray()
for y in range(H):
    for x in range(W):
        pix.append(200 if (2 <= x < 6 and 2 <= y < 6) else (x * 8 + y * 4))
frame = bytes([0xA5, W, 0, H, 0]) + bytes(pix)

# Try the baud rates the FPGA can be built for (only the one matching its CLKS_PER_BIT will answer).
for baud in (921600, 2083333, 3125000):
    # Open UART1 on the Zen Link pads (GPIO24 TX, GPIO25 RX).
    u = UART(1, baudrate=baud, tx=Pin(24), rx=Pin(25), rxbuf=1024, txbuf=1024, timeout=0)
    # Let the FPGA drop any half frame from the previous try (its stall timeout is 100 ms).
    time.sleep_ms(250)
    # Throw away anything left over.
    u.read()
    # Send the frame.
    u.write(frame)
    # Wait for the answer.
    time.sleep_ms(300)
    # Read what came back.
    n = u.any()
    d = u.read(n) if n else b''
    # Report.
    print(baud, 'got', len(d), 'expect', W * H, list(d[:20]))
    # Release the UART.
    u.deinit()
print('done')
