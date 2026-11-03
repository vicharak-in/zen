# serv-report.py - MicroPython script for the RP2350 on the Zen 4: reads the SERV self-test report over the Zen Link and prints it.
# The SoC prints the report on its UART TX line about every 2 s; the bridge in the FPGA turns it into bytes the RP2350 reads. Copy this file and zink_uart.py to the board and run it:
#   python -m mpremote cp firmware/RP2350/zink_uart.py :
#   python -m mpremote run firmware/RP2350/serv-report.py
# It stops after the line "RESULT: ALL PASS" or "RESULT: FAIL ..." (or after 10 s without one).

import time                     # Timing helpers
from zink_uart import ZinkUART  # UART-style byte stream over the Zen Link

# Byte stream from the SoC's UART (115200 baud: 217 clocks per bit at 25 MHz, the bridge default)
uart = ZinkUART(timeout=100, timeout_char=20)
# Throw away stale bytes and the overflow flags, so the next report starts clean
uart.clear_flags()
uart.read()
# Time the script started, and the text collected so far
t0 = time.ticks_ms()
text = b""
# Read until a verdict line has arrived or 10 s have passed
while time.ticks_diff(time.ticks_ms(), t0) < 10000:
    data = uart.read()
    if data:
        text += data
        print(data.decode("utf-8", "ignore"), end="")
        if b"RESULT:" in text and text.endswith(b"\n"):
            break
print()
if b"RESULT: ALL PASS" in text:
    print("self-test: ALL PASS")
else:
    print("self-test: no ALL PASS line seen")
