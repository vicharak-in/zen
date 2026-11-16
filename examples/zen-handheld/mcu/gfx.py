# gfx.py - the picture of the handheld screen: one 320 x 240 frame buffer with 16 colours, drawn on the RP2350
# The same picture goes to the PC window over USB (option A) or to the SPI TFT (option B); the colours are looked up in a 16 entry palette per screen.
import framebuf
from array import array

# Screen size in pixels (landscape) and the frame buffer: 4 bits per pixel, two pixels per byte
W = 320
H = 240
buf = bytearray(W * H // 2)
fb = framebuf.FrameBuffer(buf, W, H, framebuf.GS4_HMSB)
# Scratch buffer to build big text: one row of 8 x 8 characters in black and white
_MAX_CHARS = 40
_sbuf = bytearray(_MAX_CHARS * 8)
_sfb = framebuf.FrameBuffer(_sbuf, _MAX_CHARS * 8, 8, framebuf.MONO_HLSB)

# The 16 colours of the screen as (r, g, b) tuples; set by palette()
pal = [(0, 0, 0)] * 16


# Set the palette of the next picture (a sequence of up to 16 (r, g, b) tuples) and clear the picture to colour 0
def palette(colors):
    global pal
    pal = list(colors) + [(0, 0, 0)] * (16 - len(colors))
    fb.fill(0)


# The palette as 48 bytes r, g, b, r, g, b ... (for the USB stream)
def palette_bytes():
    out = bytearray(48)
    for i in range(16):
        out[3 * i], out[3 * i + 1], out[3 * i + 2] = pal[i]
    return out


# One colour as RGB565 (5 bits red, 6 bits green, 5 bits blue)
def rgb565(c):
    return ((c[0] & 0xF8) << 8) | ((c[1] & 0xFC) << 3) | (c[2] >> 3)


# Filled rectangle
def rect(x, y, w, h, c):
    fb.fill_rect(x, y, w, h, c)


# Rectangle outline with a given line thickness (drawn inside the rectangle)
def frame(x, y, w, h, c, t=1):
    fb.fill_rect(x, y, w, t, c)
    fb.fill_rect(x, y + h - t, w, t, c)
    fb.fill_rect(x, y, t, h, c)
    fb.fill_rect(x + w - t, y, t, h, c)


# Filled circle
def disc(cx, cy, r, c):
    fb.ellipse(cx, cy, r, r, c, True)


# Filled or outlined polygon from a list of (x, y) points, moved by (ox, oy)
def poly(points, ox, oy, c, fill=True):
    flat = array("h")
    for p in points:
        flat.append(int(p[0]))
        flat.append(int(p[1]))
    fb.poly(int(ox), int(oy), flat, c, fill)


# Line
def line(x1, y1, x2, y2, c):
    fb.line(int(x1), int(y1), int(x2), int(y2), c)


# Text in the built-in 8 x 8 font, scale 1 (fast) or a whole number bigger (each font pixel becomes a square)
def text(s, x, y, c, scale=1):
    # Plain size: draw directly
    if scale == 1:
        fb.text(s, x, y, c)
        return
    # Big text: draw into the scratch row, then copy every set pixel as a scale x scale square
    s = s[:_MAX_CHARS]
    _sfb.fill(0)
    _sfb.text(s, 0, 0, 1)
    for gy in range(8):
        for gx in range(8 * len(s)):
            if _sfb.pixel(gx, gy):
                fb.fill_rect(x + gx * scale, y + gy * scale, scale, scale, c)


# Text centred on the screen width at row y
def center(s, y, c, scale=1):
    text(s, (W - 8 * scale * len(s)) // 2, y, c, scale)
