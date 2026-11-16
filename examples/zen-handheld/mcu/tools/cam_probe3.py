# cam_probe3.py - run with  python -m mpremote connect COM8 run mcu\cam_probe3.py   while the camera looks at a BRIGHT plain surface (white paper, a window)
# A bright surface gives non-zero bytes everywhere, so any zeros show where the capture really stops
import time
import camera_ov7670 as cam

buf = bytearray(cam.FRAME_BYTES)
LB = cam.LINE_BYTES
cam.open()
print("point the camera at a bright plain surface now (4 s)")
time.sleep_ms(4000)
for n in range(3):
    ok = cam.capture(buf, 1000)
    print("frame", n, "captured", ok)
    for y in (5, 60, 120, 180, 235):
        row = buf[y * LB:(y + 1) * LB]
        # Non-zero bytes in each tenth of the line (64 bytes each), the last non-zero byte and the largest byte
        parts = [sum(1 for v in row[i * 64:(i + 1) * 64] if v) for i in range(10)]
        last = max((i for i in range(LB) if row[i]), default=-1)
        print("  row", y, "non-zero per 64 bytes:", parts, "last:", last, "max:", max(row))
    time.sleep_ms(500)
cam.close()
