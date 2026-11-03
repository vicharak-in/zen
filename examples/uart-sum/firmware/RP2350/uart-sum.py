# uart-sum.py - MicroPython for the RP2350 on the Zen 4: sends two numbers to the FPGA and prints the sum it sends back.
# Ported from the Shrike example: the UART wires are replaced by the Zen Link (zink_uart.py, copy it to the board too), and the GPIO2 reset line is gone
# (press btn1 on the Zen to reset the FPGA design, or call fpga.write(0x10, 1); it also resets itself at power-on).

from zink_uart import ZinkUART
import time

# UART-style byte stream over the Zen Link
uart = ZinkUART()

def send_value(value):
    uart.write(bytes([value & 0xFF]))

value = 1
while True:
    # First operand, then the second one
    send_value(value)
    time.sleep(0.5)
    send_value(value + 1)
    time.sleep(0.5)

    # Read the reply, if the FPGA has sent one
    if uart.any():
        reply = uart.read(1)[0]
        print(value, " + ", value + 1, " = ", reply)

    value = value + 1
    time.sleep(2)
