# cam_probe.py - camera test: run with  python -m mpremote connect COM8 run mcu\cam_probe.py
# 1) the sensor's own colour bars (8 vertical bars) must show clean on the TFT: that proves the data wires and the sampling
# 2) the live scene: prints statistics of the picture so we can see what is wrong
import time
import sink_tft
import camera_ov7670 as cam

# Open the display and the camera
sink_tft._open()
disp = sink_tft.disp
cam.open()
buf = bytearray(cam.FRAME_BYTES)


# Print numbers about one captured frame: did it arrive, how many different bytes, are the rows alike, and sample bytes of a row
def report(name):
    ok = cam.capture(buf, 1000)
    print(name, "captured:", ok)
    print("  distinct byte values:", len(set(buf)))
    print("  row 0 first 24 bytes:", list(buf[:24]))
    r = 120 * cam.LINE_BYTES
    print("  row 120 first 24 bytes:", list(buf[r:r + 24]))
    same = sum(1 for y in range(1, 240) if buf[y * cam.LINE_BYTES:y * cam.LINE_BYTES + 64] == buf[:64])
    print("  rows whose first 64 bytes equal row 0:", same, "of 239")
    # Eight samples across row 120 (pixel 20, 60, ... : high byte, low byte)
    print("  row 120 across:", [(buf[r + 2 * x], buf[r + 2 * x + 1]) for x in range(20, 320, 40)])
    disp.blit(buf, 0, 0, cam.W, cam.H)


# Colour bars from the sensor (COM17 bit 3)
cam.write_reg(0x42, 0x08)
time.sleep_ms(300)
report("COLOUR BARS")
time.sleep_ms(4000)
# Live picture
cam.write_reg(0x42, 0x00)
time.sleep_ms(500)
report("LIVE")
time.sleep_ms(4000)
cam.close()
