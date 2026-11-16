# cam_probe4.py - run with  python -m mpremote connect COM8 run mcu\cam_probe4.py
# Prints one line of the sensor's colour bars as runs of equal bytes: (value, how many in a row), and the same for the live scene
import time
import camera_ov7670 as cam

buf = bytearray(cam.FRAME_BYTES)
LB = cam.LINE_BYTES


# Runs of equal bytes in row y
def runs(y):
    row = buf[y * LB:(y + 1) * LB]
    out = []
    cur, n = row[0], 1
    for v in row[1:]:
        if v == cur:
            n += 1
        else:
            out.append((cur, n))
            cur, n = v, 1
    out.append((cur, n))
    return out


cam.open()
for name, com17 in (("COLOUR BARS", 0x08), ("LIVE", 0x00)):
    cam.write_reg(0x42, com17)
    time.sleep_ms(400)
    ok = cam.capture(buf, 1000)
    print(name, "captured", ok)
    # Registers that decide brightness and the test pattern
    print("  COM8 %02x COM9 %02x COM17 %02x AEC %02x %02x GAIN %02x" % (cam.read_reg(0x13), cam.read_reg(0x14), cam.read_reg(0x42), cam.read_reg(0x10), cam.read_reg(0x07), cam.read_reg(0x00)))
    for y in (2, 120):
        print("  row", y, runs(y))
cam.close()
