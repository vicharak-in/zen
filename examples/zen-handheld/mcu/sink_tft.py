# sink_tft.py - option B: every picture goes to the 2.8" ILI9341 TFT (240 x 320, SPI, no touch) wired to the RP2350; no computer needed
# Wiring (edit spi_display.py to change): SCK GPIO18, MOSI GPIO19, DC GPIO20, CS GPIO17, RST GPIO21, LED to 3V3, VCC 3V3, GND. MISO and the touch pins stay unconnected.
import gc
import time
import sys
import micropython
import framebuf
import gfx
import render
import spi_display

# Rotation of the picture: 90 = landscape, 270 = landscape upside down (use it when the picture is turned the wrong way)
ROTATION = 90
# Rows sent per SPI transfer: 16 rows of 320 pixels x 2 bytes = 10 KB of RAM
STRIP = 16
# Pause between frames (ms) and no repeated menu: the menu is only sent when it changes
PAUSE_MS = 2
REPEAT_MENU = False

# The display and the buffers for the colour conversion are made on first use
disp = None
strip = None
strip_fb = None
pal_buf = None
pal_fb = None
# The last menu that was drawn, to skip identical ones
_last_menu = None


# Open the display and make the buffers
def _open():
    global disp, strip, strip_fb, pal_buf, pal_fb
    disp = spi_display.Display("ili9341_240x320", ROTATION)
    strip = bytearray(gfx.W * STRIP * 2)
    strip_fb = framebuf.FrameBuffer(strip, gfx.W, STRIP, framebuf.RGB565)
    pal_buf = bytearray(32)
    pal_fb = framebuf.FrameBuffer(pal_buf, 16, 1, framebuf.RGB565)


# Send the finished picture: the palette is put in the byte order the display wants (high byte first), then the 4-bit picture is turned into
# RGB565 strip by strip by blit() with that palette, and each strip goes out over SPI
def flush():
    if disp is None:
        _open()
    for i in range(16):
        v = gfx.rgb565(gfx.pal[i])
        pal_buf[2 * i] = v >> 8
        pal_buf[2 * i + 1] = v & 255
    for y0 in range(0, gfx.H, STRIP):
        strip_fb.blit(gfx.fb, 0, -y0, -1, pal_fb)
        disp.blit(strip, 0, y0, gfx.W, STRIP)


# The menu (only when it changed)
def menu(sel, names):
    global _last_menu
    if _last_menu == sel:
        return
    _last_menu = sel
    render.menu(sel, names)
    flush()


# A short message
def notice(text):
    global _last_menu
    _last_menu = None
    render.notice(text)
    flush()


# An error message
def error(text):
    global _last_menu
    _last_menu = None
    render.error(text)
    flush()


# One frame of a game from its state bytes
def game(view, buf):
    render.game(view.GAME_ID, buf)
    flush()


# Camera state: the frame buffer, the previous button bits (both held at the start, so the press that opened the camera does nothing), frozen picture and mirror setting
cam = None
cam_buf = None
cam_small = None
cam_small_ok = False
cam_buf2 = None
cam_w = 0
cam_ready = None
cam_prev = 3
cam_frozen = False
cam_mirror = False


# Show the camera picture as 160 x 120 in the middle of the screen: that is a quarter of the data, so one screen write (about 15 ms) is shorter than one
# refresh of the panel and the picture does not tear. False shows the full 320 x 240 picture (it tears while things move).
CAM_SMALL = False
# Hold every picture still for this long (ms) before the next one is drawn: the tear then only happens a few times a second and the picture stays steady in between.
# 0 = update as fast as possible (the tear is then on the screen all the time). Press B in the camera app to freeze one picture completely.
CAM_HOLD_MS = 120
cam_next = 0
# SPI speed to the screen while the camera runs (Hz): faster means a shorter screen write and less tearing; the other apps keep spi_display.BAUD.
# If the picture shows speckles or wrong colours, lower it (32_000_000, then 20_000_000).
CAM_SPI_BAUD = 40_000_000


# Take every second pixel of every second line of a 320 x 240 RGB565 picture (src) into a 160 x 120 picture (dst)
@micropython.viper
def _half(src: ptr8, dst: ptr8):
    for y in range(120):
        s = y * 1280
        d = y * 320
        for x in range(160):
            dst[d + 2 * x] = src[s + 4 * x]
            dst[d + 2 * x + 1] = src[s + 4 * x + 1]


# Start the camera and clear the screen; raises RuntimeError (shown on the screen) when the camera does not answer
def camera_begin():
    global cam, cam_buf, cam_small, cam_small_ok, cam_buf2, cam_w, cam_ready, cam_prev, cam_frozen, cam_mirror, cam_next
    if disp is None:
        _open()
    gc.collect()
    import camera_ov7670
    camera_ov7670.open()
    cam = camera_ov7670
    cam_buf = bytearray(cam.FRAME_BYTES)
    # A second buffer lets the next frame be captured while the last one is sent to the screen (skipped when memory is short)
    cam_buf2 = None
    if CAM_SMALL:
        cam_small = bytearray(160 * 120 * 2)
        cam_small_ok = False
    else:
        try:
            cam_buf2 = bytearray(cam.FRAME_BYTES)
        except MemoryError:
            cam_buf2 = None
    cam_w, cam_ready = 0, None
    cam_prev, cam_frozen, cam_mirror = 3, False, False
    cam_next = 0
    cam.mirror(False)
    # Faster SPI for the picture
    try:
        disp.spi.init(baudrate=CAM_SPI_BAUD)
    except Exception:
        pass
    disp.fill(0)


# One camera step: A (without B) mirrors the picture, B (without A) freezes or unfreezes it, otherwise grab a frame and show it
def camera(bits):
    global cam_prev, cam_frozen, cam_mirror, cam_w, cam_ready, cam_small_ok, cam_next
    if cam_prev == 0 and bits == 2:
        cam_mirror = not cam_mirror
        cam.mirror(cam_mirror)
    elif cam_prev == 0 and bits == 1:
        cam_frozen = not cam_frozen
    cam_prev = bits
    if cam_frozen:
        return
    # Hold mode: capture one frame, draw it whole, then leave it alone for CAM_HOLD_MS
    if CAM_HOLD_MS:
        if time.ticks_diff(time.ticks_ms(), cam_next) < 0:
            return
        if cam.capture(cam_buf):
            disp.blit(cam_buf, 0, 0, cam.W, cam.H)
        cam_next = time.ticks_add(time.ticks_ms(), CAM_HOLD_MS)
        return
    if CAM_SMALL:
        # Capture the next frame in the background while the last small picture is sent to the screen, then shrink the new frame
        h = cam.start(cam_buf)
        if cam_small_ok:
            disp.blit(cam_small, 80, 60, 160, 120)
        if cam.finish(h):
            _half(cam_buf, cam_small)
            cam_small_ok = True
        return
    if cam_buf2 is None:
        # One buffer: capture, then draw
        if cam.capture(cam_buf):
            disp.blit(cam_buf, 0, 0, cam.W, cam.H)
        return
    # Two buffers: start capturing into one, draw the last finished frame from the other meanwhile, then wait for the capture
    bufs = (cam_buf, cam_buf2)
    h = cam.start(bufs[cam_w])
    if cam_ready is not None:
        disp.blit(bufs[cam_ready], 0, 0, cam.W, cam.H)
    if cam.finish(h):
        cam_ready = cam_w
        cam_w = 1 - cam_w


# Stop the camera and free its memory
def camera_end():
    global cam, cam_buf, cam_small, cam_small_ok, cam_buf2, cam_ready, _last_menu
    if cam is not None:
        cam.close()
    # Back to the normal SPI speed
    try:
        disp.spi.init(baudrate=spi_display.BAUD)
    except Exception:
        pass
    cam = None
    cam_buf = None
    cam_small = None
    cam_small_ok = False
    cam_buf2 = None
    cam_ready = None
    _last_menu = None
    gc.collect()


# PC webcam app: the PC script pc/webcam_to_tft.py sends 16 colour pictures (same format as option A) over the USB serial port, one per "R" the board sends
_WEB_MAGIC = b"ZGB\x01"
# Show the board's own timing (ms to read the picture over USB and ms to draw it) in the corner of the picture while tuning the speed
DEBUG_TIMING = True
web_ms = (0, 0)
# Half size picture: 160 x 120 pixels, 4 times less data over USB, doubled in width and height here
_WEB_MAGIC_HALF = b"ZGB\x03"
# Four-shade picture: 160 x 120 pixels of 2 bits (4 shades), 4800 bytes, the fastest to send
_WEB_MAGIC_GB = b"ZGB\x04"
# Black and white picture: 320 x 240 pixels of 1 bit, 9600 bytes, full screen resolution
_WEB_MAGIC_MONO = b"ZGB\x05"
web_small = None
web_poll = None
web_head = bytearray(52)
web_last_ask = 0


# Double a 160 x 120 picture of 4 bit pixels (src, 80 bytes per row) into the 320 x 240 frame buffer (dst, 160 bytes per row): every pixel becomes 2 x 2
@micropython.viper
def _up2(src: ptr8, dst: ptr8):
    for y in range(120):
        s = y * 80
        d0 = y * 320
        # Each source byte holds two pixels; each becomes a byte with the same pixel twice
        for i in range(80):
            b = int(src[s + i])
            hi = b >> 4
            lo = b & 15
            dst[d0 + 2 * i] = (hi << 4) | hi
            dst[d0 + 2 * i + 1] = (lo << 4) | lo
        # The second output row is a copy of the first
        for i in range(160):
            dst[d0 + 160 + i] = dst[d0 + i]


# Double a 160 x 120 picture of 2 bit pixels (src, 40 bytes per row, leftmost pixel in the top bits) into the 4 bit frame buffer (dst, 160 bytes per row): every pixel becomes 2 x 2
@micropython.viper
def _up2_2bpp(src: ptr8, dst: ptr8):
    for y in range(120):
        s = y * 40
        d0 = y * 320
        # Each source byte holds four pixels; each becomes one output byte with that pixel twice
        for i in range(40):
            b = int(src[s + i])
            p0 = (b >> 6) & 3
            p1 = (b >> 4) & 3
            p2 = (b >> 2) & 3
            p3 = b & 3
            o = d0 + 4 * i
            dst[o] = (p0 << 4) | p0
            dst[o + 1] = (p1 << 4) | p1
            dst[o + 2] = (p2 << 4) | p2
            dst[o + 3] = (p3 << 4) | p3
        # The second output row is a copy of the first
        for i in range(160):
            dst[d0 + 160 + i] = dst[d0 + i]


# Turn a 320 x 240 picture of 1 bit pixels (src, 40 bytes per row, leftmost pixel in the top bit) into the 4 bit frame buffer (dst, 160 bytes per row): colour 0 or 1
@micropython.viper
def _expand_1bpp(src: ptr8, dst: ptr8):
    for i in range(9600):
        b = int(src[i])
        o = i * 4
        # Eight pixels become four bytes of two pixels each
        dst[o] = (((b >> 7) & 1) << 4) | ((b >> 6) & 1)
        dst[o + 1] = (((b >> 5) & 1) << 4) | ((b >> 4) & 1)
        dst[o + 2] = (((b >> 3) & 1) << 4) | ((b >> 2) & 1)
        dst[o + 3] = (((b >> 1) & 1) << 4) | (b & 1)


# Start the PC webcam app: stop USB Ctrl+C handling (the picture bytes could contain it), throw away old input and tell the user what to run on the PC
def webcam_begin():
    global web_poll, web_last_ask, web_small
    import select
    import time
    if disp is None:
        _open()
    micropython.kbd_intr(-1)
    web_small = bytearray(9600)
    web_poll = select.poll()
    web_poll.register(sys.stdin, select.POLLIN)
    while web_poll.poll(0):
        sys.stdin.buffer.read(1)
    notice("Start PC script")
    web_last_ask = time.ticks_add(time.ticks_ms(), -1000)


# One webcam step: ask the PC for a picture every 300 ms until one arrives, then read it and show it
def webcam(bits):
    global web_last_ask, web_ms
    import time
    # Ask for a picture (again after 300 ms without an answer)
    if time.ticks_diff(time.ticks_ms(), web_last_ask) >= 300:
        sys.stdout.write("R")
        web_last_ask = time.ticks_ms()
    # Nothing arrived yet: the caller checks the buttons and calls again
    if not web_poll.poll(10):
        return
    # Header (magic + 16 palette colours), then the pixels straight into the frame buffer
    t0 = time.ticks_ms()
    sys.stdin.buffer.readinto(web_head)
    magic = bytes(web_head[:4])
    if magic != _WEB_MAGIC and magic != _WEB_MAGIC_HALF and magic != _WEB_MAGIC_GB and magic != _WEB_MAGIC_MONO:
        while web_poll.poll(20):
            sys.stdin.buffer.read(1)
        web_last_ask = time.ticks_add(time.ticks_ms(), -1000)
        return
    gfx.pal = [(web_head[4 + 3 * i], web_head[5 + 3 * i], web_head[6 + 3 * i]) for i in range(16)]
    if magic == _WEB_MAGIC:
        sys.stdin.buffer.readinto(gfx.buf)
    elif magic == _WEB_MAGIC_MONO:
        sys.stdin.buffer.readinto(web_small)
        _expand_1bpp(web_small, gfx.buf)
    elif magic == _WEB_MAGIC_GB:
        sys.stdin.buffer.readinto(memoryview(web_small)[:4800])
        _up2_2bpp(web_small, gfx.buf)
    else:
        sys.stdin.buffer.readinto(web_small)
        _up2(web_small, gfx.buf)
    t1 = time.ticks_ms()
    # Ask for the next picture before drawing this one, so the PC works while the screen is being drawn
    sys.stdout.write("R")
    web_last_ask = t1
    if DEBUG_TIMING:
        gfx.rect(0, 228, 112, 12, 0)
        gfx.text("rd %d dr %d" % (web_ms[0], web_ms[1]), 2, 230, 15, 1)
    flush()
    web_ms = (time.ticks_diff(t1, t0), time.ticks_diff(time.ticks_ms(), t1))


# Leave the PC webcam app: Ctrl+C works again
def webcam_end():
    global web_poll, web_small, _last_menu
    micropython.kbd_intr(3)
    web_poll = None
    web_small = None
    _last_menu = None


# Flight simulator app: loads the flight bitstream (the FPGA runs the CORDIC engine), then flight.py reads the GY-91 and draws the plane
FLIGHT_FILE = "flight.hex.bin"
FLIGHT_ID = 0xF1


# Start the flight app: load its bitstream, check it, make the flight object
def flight_begin():
    global _last_menu
    if disp is None:
        _open()
    import launcher_gfx
    import flight
    launcher_gfx.start(sys.modules[__name__], FLIGHT_FILE, FLIGHT_ID)
    flight.begin(disp, True)
    _last_menu = None


# One flight step (A recentres, the app draws one frame)
def flight_step(bits):
    import flight
    flight.step(bits)


# Stop the flight app and free its memory
def flight_end():
    global _last_menu
    import flight
    flight.end()
    _last_menu = None


# The extra apps of the menu (name, begin, step, end); the PC webcam app is still here (webcam_begin) but not in the menu
APPS = (("Camera", camera_begin, camera, camera_end), ("Flight", flight_begin, flight_step, flight_end))
