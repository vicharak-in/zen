# spi_display.py - MicroPython driver for small SPI colour displays (ST7789, ILI9341, ST7735) on the Zen 8 RP2350
# Only RGB565 colour and a write-only SPI link are used (no MISO needed), so 4 signal wires + power are enough.
from machine import Pin, SPI
import framebuf
import time

# Wiring on the RP2350 (hardware SPI0, GPIO 18 and 19 are its clock and data pins). GPIO 0-5 and 24-29 are used by the FPGA, so they are avoided.
SPI_ID = 0
PIN_SCK = 18
PIN_MOSI = 19
PIN_DC = 20
PIN_CS = 17
PIN_RST = None
# (set PIN_RST = None and wire the panel's RST to 3V3 when GPIO 21 is needed for the camera clock)
# Backlight: wire BL to 3V3, or set a GPIO number here to switch it from software (None = not used)
PIN_BL = None
# SPI clock in Hz (ST7789 and ILI9341 take 40 MHz or more on short wires; lower it if the picture is noisy)
BAUD = 20_000_000

# Controller presets: width, height, column offset, row offset, MADCTL byte, invert colours
# Rotation is set through MADCTL. The init commands per controller are in _init_controller.
PRESETS = {
    # 240x240 1.3"/1.54" IPS modules need the 80-row offset only in some rotations; 240x320 has no offset
    "st7789_240x240": dict(w=240, h=240, dx=0, dy=0, madctl=0x00, invert=True),
    "st7789_240x320": dict(w=240, h=320, dx=0, dy=0, madctl=0x00, invert=True),
    "ili9341_240x320": dict(w=240, h=320, dx=0, dy=0, madctl=0x48, invert=False),
    "st7735_128x160": dict(w=128, h=160, dx=0, dy=0, madctl=0xC0, invert=False),
}


# Pack an 8-bit-per-channel colour into the 16-bit RGB565 value (the driver sends the high byte first)
def color565(r, g, b):
    return ((r & 0xF8) << 8) | ((g & 0xFC) << 3) | (b >> 3)


# Some ready colours
BLACK = color565(0, 0, 0)
WHITE = color565(255, 255, 255)
RED = color565(255, 0, 0)
GREEN = color565(0, 255, 0)
BLUE = color565(0, 0, 255)
YELLOW = color565(255, 255, 0)


# One SPI display; create it, then call the drawing methods
class Display:
    # Open SPI, reset the panel, send the init sequence for the chosen controller and clear the screen
    def __init__(self, preset="st7789_240x320", rotation=0):
        # Look up the controller settings
        p = PRESETS[preset]
        self.kind = preset.split("_")[0]
        self.base_madctl = p["madctl"]
        self.w0, self.h0 = p["w"], p["h"]
        self.dx, self.dy = p["dx"], p["dy"]
        self.invert = p["invert"]
        # Control pins: DC low = command, high = data; CS low = selected
        self.dc = Pin(PIN_DC, Pin.OUT, value=0)
        self.cs = Pin(PIN_CS, Pin.OUT, value=1)
        self.rst = Pin(PIN_RST, Pin.OUT, value=1) if PIN_RST is not None else None
        # Optional backlight pin
        self.bl = Pin(PIN_BL, Pin.OUT, value=1) if PIN_BL is not None else None
        # Hardware SPI mode 0, most significant bit first (SPI0 pins SCK 18 / MOSI 19 are valid for the RP2350)
        self.spi = SPI(SPI_ID, baudrate=BAUD, polarity=0, phase=0, sck=Pin(PIN_SCK), mosi=Pin(PIN_MOSI))
        # Hardware reset, then the controller start-up sequence
        self.reset()
        self._init_controller()
        # Rotation also sets width and height
        self.set_rotation(rotation)
        self.fill(BLACK)

    # Pulse the reset pin (or do a software reset when there is no reset wire)
    def reset(self):
        # No reset wire: the start-up sequence begins with a software reset command instead
        if self.rst is None:
            time.sleep_ms(150)
            return
        # Reset low for 20 ms, then wait 150 ms for the panel to wake up
        self.rst(1)
        time.sleep_ms(10)
        self.rst(0)
        time.sleep_ms(20)
        self.rst(1)
        time.sleep_ms(150)

    # Send one command byte followed by optional data bytes
    def cmd(self, c, data=None):
        # Command phase: DC low
        self.cs(0)
        self.dc(0)
        self.spi.write(bytes([c]))
        # Data phase: DC high
        if data:
            self.dc(1)
            self.spi.write(data)
        self.cs(1)

    # Controller specific start-up commands
    def _init_controller(self):
        # Software reset, then leave sleep mode
        self.cmd(0x01)
        time.sleep_ms(150)
        self.cmd(0x11)
        time.sleep_ms(120)
        # 16 bit colour (RGB565) for every controller
        self.cmd(0x3A, b"\x55")
        # Controller specific tuning
        if self.kind == "ili9341":
            # The short start-up is enough for the common 2.8" modules; the long vendor power sequence made the panel stay white on the Zen
            pass
        elif self.kind == "st7735":
            # Frame rate and power for the 1.8" panel
            self.cmd(0xB1, b"\x01\x2C\x2D")
            self.cmd(0xB2, b"\x01\x2C\x2D")
            self.cmd(0xB3, b"\x01\x2C\x2D\x01\x2C\x2D")
            self.cmd(0xC0, b"\xA2\x02\x84")
            self.cmd(0xC1, b"\xC5")
            self.cmd(0xC2, b"\x0A\x00")
            self.cmd(0xC3, b"\x8A\x2A")
            self.cmd(0xC4, b"\x8A\xEE")
            self.cmd(0xC5, b"\x0E")
        else:
            # ST7789 normal porch and gate settings
            self.cmd(0xB2, b"\x0C\x0C\x00\x33\x33")
            self.cmd(0xB7, b"\x35")
            self.cmd(0xBB, b"\x19")
            self.cmd(0xC0, b"\x2C")
            self.cmd(0xC2, b"\x01")
            self.cmd(0xC3, b"\x12")
            self.cmd(0xC4, b"\x20")
            self.cmd(0xC6, b"\x0F")
            self.cmd(0xD0, b"\xA4\xA1")
        # Colour inversion (needed by ST7789 IPS panels), normal display mode, display on
        self.cmd(0x21 if self.invert else 0x20)
        self.cmd(0x13)
        self.cmd(0x29)
        time.sleep_ms(50)

    # Rotate the picture: 0, 90, 180 or 270 degrees
    def set_rotation(self, deg):
        # MADCTL bits: MY 0x80, MX 0x40, MV 0x20; base value adds the colour order bit of the controller
        base = self.base_madctl & 0x0F
        bits = {0: 0x00, 90: 0x60, 180: 0xC0, 270: 0xA0}[deg % 360]
        # ILI9341 modules are wired mirrored compared to ST7789, so use its own table
        if self.kind == "ili9341":
            bits = {0: 0x48, 90: 0x28, 180: 0x88, 270: 0xE8}[deg % 360] & 0xF0
        self.cmd(0x36, bytes([bits | base]))
        # Sideways rotations swap width and height
        if deg % 180:
            self.w, self.h = self.h0, self.w0
        else:
            self.w, self.h = self.w0, self.h0

    # Select the rectangle that following pixel data fills
    def set_window(self, x0, y0, x1, y1):
        # Column range then row range, with the panel offset added
        x0 += self.dx
        x1 += self.dx
        y0 += self.dy
        y1 += self.dy
        self.cmd(0x2A, bytes([x0 >> 8, x0 & 255, x1 >> 8, x1 & 255]))
        self.cmd(0x2B, bytes([y0 >> 8, y0 & 255, y1 >> 8, y1 & 255]))
        # Memory write: pixel bytes follow
        self.cmd(0x2C)

    # Send raw RGB565 bytes (high byte first) into the current window
    def _write_pixels(self, buf):
        self.cs(0)
        self.dc(1)
        self.spi.write(buf)
        self.cs(1)

    # Fill a rectangle with one colour (colour from color565)
    def fill_rect(self, x, y, w, h, color):
        # Clip to the screen
        if x < 0:
            w += x
            x = 0
        if y < 0:
            h += y
            y = 0
        w = min(w, self.w - x)
        h = min(h, self.h - y)
        if w <= 0 or h <= 0:
            return
        self.set_window(x, y, x + w - 1, y + h - 1)
        # Send one line at a time so the buffer stays small
        line = bytes([color >> 8, color & 255]) * w
        for _ in range(h):
            self._write_pixels(line)

    # Fill the whole screen
    def fill(self, color):
        self.fill_rect(0, 0, self.w, self.h, color)

    # Draw one pixel
    def pixel(self, x, y, color):
        if 0 <= x < self.w and 0 <= y < self.h:
            self.fill_rect(x, y, 1, 1, color)

    # Copy a ready RGB565 buffer (w*h*2 bytes, high byte first) to the screen at x, y
    def blit(self, buf, x, y, w, h):
        self.set_window(x, y, x + w - 1, y + h - 1)
        self._write_pixels(buf)

    # Draw text with the built-in 8x8 font, scaled up by an integer factor
    def text(self, s, x, y, color=WHITE, bg=BLACK, scale=1):
        # Render the string into a small RGB565 buffer, then send it in one go
        w = 8 * len(s)
        buf = bytearray(w * 8 * 2)
        fb = framebuf.FrameBuffer(buf, w, 8, framebuf.RGB565)
        # framebuf stores RGB565 little endian, so swap the colours back before drawing
        fb.fill(((bg & 0xFF) << 8) | (bg >> 8))
        fb.text(s, 0, 0, ((color & 0xFF) << 8) | (color >> 8))
        # Without scaling the buffer is already in the right byte order after the swap above
        if scale == 1:
            self.blit(buf, x, y, w, 8)
            return
        # Scaled text: repeat each pixel scale times across and down
        out = bytearray(w * scale * 2 * scale)
        for row in range(8):
            line = bytearray()
            for col in range(w):
                px = buf[(row * w + col) * 2:(row * w + col) * 2 + 2]
                line += bytes(px) * scale
            for k in range(scale):
                o = (row * scale + k) * len(line)
                out[o:o + len(line)] = line
        self.blit(out, x, y, w * scale, 8 * scale)

    # Switch the backlight when a GPIO is wired to it
    def backlight(self, on):
        if self.bl is not None:
            self.bl(1 if on else 0)
