# tft_probe_hat.py - screen test with the display wired to the numbered pins 1-10 of the Zen hat (only for checking the display, not for the Game Boy)
# Those hat pins are the Zen Link lines, so the FPGA shares them: this is fine while no game is running.
# Use:  python -m mpremote connect COM4 cp mcu\tft_probe_hat.py :
#       python -m mpremote connect COM4 exec "import tft_probe_hat; tft_probe_hat.run(5, 6, 7, 8, 9)"
# The five numbers are the HAT pin of SCK, SDI(MOSI), DC, RESET and CS, in that order.
from machine import Pin, SoftSPI
import time

# Hat pin number (1-10) to RP2350 GPIO number, from the Zen Link table in the zen repo
HAT = {1: 24, 2: 2, 3: 1, 4: 25, 5: 0, 6: 26, 7: 3, 8: 27, 9: 28, 10: 29}


# Start the display on the given hat pins and turn the screen through the given colours (one second each)
def run(sck, mosi, dc, rst, cs, colors=(("red", 0xF800), ("green", 0x07E0), ("blue", 0x001F))):
    g = [HAT[p] for p in (sck, mosi, dc, rst, cs)]
    print("GPIO used: SCK %d MOSI %d DC %d RST %d CS %d" % tuple(g))
    # Slow software SPI so that long wires do not matter; the unused MISO pin is GPIO 11
    spi = SoftSPI(baudrate=1_000_000, polarity=0, phase=0, sck=Pin(g[0]), mosi=Pin(g[1]), miso=Pin(11))
    dcp = Pin(g[2], Pin.OUT, value=0)
    rstp = Pin(g[3], Pin.OUT, value=1)
    csp = Pin(g[4], Pin.OUT, value=1)

    # Send one command byte and its data bytes
    def cmd(c, data=b""):
        csp(0)
        dcp(0)
        spi.write(bytes([c]))
        if data:
            dcp(1)
            spi.write(data)
        csp(1)

    # Reset, sleep out, 16 bit colour, rotation, display on
    rstp(0)
    time.sleep_ms(50)
    rstp(1)
    time.sleep_ms(150)
    cmd(0x01)
    time.sleep_ms(150)
    cmd(0x11)
    time.sleep_ms(120)
    cmd(0x3A, b"\x55")
    cmd(0x36, b"\x48")
    cmd(0x29)
    time.sleep_ms(50)
    # Three colours over the whole 240 x 320 screen
    for name, color in colors:
        print(name)
        cmd(0x2A, bytes([0, 0, 0, 239]))
        cmd(0x2B, bytes([0, 0, 1, 63]))
        cmd(0x2C)
        csp(0)
        dcp(1)
        line = bytes([color >> 8, color & 255]) * 240
        for _ in range(320):
            spi.write(line)
        csp(1)
        time.sleep_ms(1000)
    print("done")


# Try the five wires on neighbouring hat pins: start 1 means SCK on 1, SDI on 2, DC on 3, RESET on 4, CS on 5, and so on up to start 6
# Each try turns the screen red; tell which "start" printed when it turned red. Also tries the wires in reverse order (SCK on the highest pin).
def sweep():
    for start in range(1, 7):
        print("--- forward start", start)
        run(start, start + 1, start + 2, start + 3, start + 4, (("red", 0xF800),))
        time.sleep_ms(300)
    for start in range(1, 7):
        print("--- reverse start", start)
        run(start + 4, start + 3, start + 2, start + 1, start, (("red", 0xF800),))
        time.sleep_ms(300)
    print("sweep done")
