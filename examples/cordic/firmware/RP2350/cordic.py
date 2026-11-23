# cordic.py - MicroPython for the RP2350 on the Zen 4, ported from the Shrike example: the SPI pins, chip-select pin, reset pin and flash call are replaced by
# the Zen Link byte port (zen_spi.py, copy it to the board too).
#cordic.py
# Valid angle range: 0 to 45 degrees.

import math
import time
from zen_spi import ZenSPI

# Zen Link byte port (the FPGA resets itself at power-on, btn1 resets it too)
spi = ZenSPI()

def spi_exchange(byte_val):
    return spi.exchange(byte_val)

def fpga_query(mode, val1, val2=0):
    if mode == "cos":
        packet = (int(val1 * 64) & 0x3F) | 0x00
    elif mode == "sin":
        packet = (int(val1 * 64) & 0x3F) | 0x40
    elif mode == "mul":
        packet = ((int(val1) & 0x07) << 3) | (int(val2) & 0x07) | 0x80
    elif mode == "tan":
        packet = (int(val1 * 64) & 0x3F) | 0xC0

    spi_exchange(packet)
    time.sleep_us(15)
    raw = spi_exchange(0x00)

    if raw & 0x80:
        raw -= 0x100
    fpga_val = raw if mode == "mul" else raw / 64.0

    if mode == "sin":
        ref = math.sin(val1)
    elif mode == "cos":
        ref = math.cos(val1)
    elif mode == "tan":
        ref = math.tan(val1)
    elif mode == "mul":
        ref = float(val1 * val2)

    return fpga_val, ref, abs(fpga_val - ref)



print()
print("CORDIC Coprocessor  |  angle range: 0 to 45 deg")
print()
print("  cos  sin  tan  mul  exit")
print()

while True:
    try:
        mode = input("> ").strip().lower()
    except (EOFError, KeyboardInterrupt):
        break

    if mode == "exit":
        break

    elif mode in ("cos", "sin", "tan"):
        try:
            deg = float(input("angle (deg) > "))
        except ValueError:
            print("  number please")
            continue
        if not (0.0 <= deg <= 45.0):
            print("  0 to 45 deg only")
            continue
        rad = math.radians(deg)
        fpga, ref, err = fpga_query(mode, rad)
        print(f"  fpga {fpga:.4f}  ref {ref:.4f}  err {err:.6f}")

    elif mode == "mul":
        try:
            a = int(input("a (3-bit signed, -4 to 3) > "))
            b = int(input("b (3-bit signed, -4 to 3) > "))
        except ValueError:
            print("  integers only")
            continue
        if not (-4 <= a <= 3 and -4 <= b <= 3):
            print("  range: -4 to 3")
            continue
        fpga, ref, err = fpga_query("mul", a, b)
        print(f"  fpga {fpga:.4f}  ref {ref:.4f}  err {err:.6f}")

    else:
        print("  modes: cos  sin  tan  mul  exit")
