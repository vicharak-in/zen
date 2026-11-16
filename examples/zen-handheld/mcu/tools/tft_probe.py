# tft_probe.py - the smallest possible test of the ILI9341 TFT: software SPI on five pins, start-up commands, then the screen turns red, green, blue
# Run:  python -m mpremote connect COM4 run mcu\tft_probe.py     Change the pin numbers below if you wired other GPIOs.
from machine import Pin, SoftSPI
import time

# The five signal pins (GPIO numbers on the RP2350)
SCK, MOSI, DC, RST, CS = 18, 19, 20, 21, 17
# Slow clock so that long jumper wires do not matter
spi = SoftSPI(baudrate=1_000_000, polarity=0, phase=0, sck=Pin(SCK), mosi=Pin(MOSI), miso=Pin(11))
dc = Pin(DC, Pin.OUT, value=0)
rst = Pin(RST, Pin.OUT, value=1)
cs = Pin(CS, Pin.OUT, value=1)


# Send one command byte and its data bytes
def cmd(c, data=b""):
    cs(0)
    dc(0)
    spi.write(bytes([c]))
    if data:
        dc(1)
        spi.write(data)
    cs(1)


# Hardware reset, then the minimum start-up: sleep out, 16 bit colour, rotation, display on
print("reset")
rst(0)
time.sleep_ms(50)
rst(1)
time.sleep_ms(150)
cmd(0x01)
time.sleep_ms(150)
cmd(0x11)
time.sleep_ms(120)
cmd(0x3A, b"\x55")
cmd(0x36, b"\x48")
cmd(0x29)
time.sleep_ms(50)


# Fill the whole 240 x 320 screen with one RGB565 colour
def fill(color):
    cmd(0x2A, bytes([0, 0, 0, 239]))
    cmd(0x2B, bytes([0, 0, 1, 63]))
    cmd(0x2C)
    cs(0)
    dc(1)
    line = bytes([color >> 8, color & 255]) * 240
    for _ in range(320):
        spi.write(line)
    cs(1)


# Three colours, one second each
for name, c in (("red", 0xF800), ("green", 0x07E0), ("blue", 0x001F)):
    print(name)
    fill(c)
    time.sleep_ms(1000)
print("done")
