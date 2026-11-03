# uart-led.py - MicroPython for the RP2350 on the Zen 4: type "on" or "off" to switch LED 1 through the FPGA.
# Ported from the Shrike example: the UART wires are replaced by the Zen Link (zink_uart.py, copy it to the board too). The FPGA turns the bytes into the UART line of the unchanged core.

from zink_uart import ZinkUART
import time

# UART-style byte stream over the Zen Link
uart = ZinkUART()

def send_value(value):
    # Send one raw byte
    uart.write(bytes([value]))

while True:
    cmd = input("Type 'on' or 'off': ").strip().lower()

    if cmd == "on":
        send_value(0xAB)
        print("LED on")
    elif cmd == "off":
        send_value(0xFF)
        print("LED off")
    else:
        print("Invalid input, type 'on' or 'off'")

    time.sleep(0.2)
