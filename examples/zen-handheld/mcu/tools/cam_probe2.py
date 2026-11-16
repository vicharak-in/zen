# cam_probe2.py - how wide is the camera's picture? run with  python -m mpremote connect COM8 run mcu\cam_probe2.py
# For several camera clock speeds: colour bars, then how far along the line the data goes (the rest reads as zeros)
import time
import camera_ov7670 as cam

buf = bytearray(cam.FRAME_BYTES)
LB = cam.LINE_BYTES


# Index of the last byte of the line that is not zero, and the number of non-zero bytes
def extent(y):
    row = buf[y * LB:(y + 1) * LB]
    last = -1
    nz = 0
    for i in range(LB):
        if row[i]:
            last = i
            nz += 1
    return last, nz


for hz in (5_000_000, 8_000_000, 10_000_000, 15_000_000, 20_000_000):
    cam.XCLK_HZ = hz
    try:
        cam.open()
    except Exception as e:
        print(hz, "open failed:", e)
        continue
    # Registers the picture size depends on
    regs = {r: cam.read_reg(r) for r in (0x12, 0x3E, 0x72, 0x73, 0x17, 0x18, 0x32, 0x19, 0x1A, 0x03, 0x0C, 0x40)}
    print("XCLK", hz // 1000000, "MHz regs", {hex(k): hex(v) for k, v in regs.items()})
    cam.write_reg(0x42, 0x08)
    time.sleep_ms(300)
    ok = cam.capture(buf, 1000)
    # Last non-zero byte of three lines (of 640), the capture result and the distinct values
    print("  captured", ok, "distinct", len(set(buf)), "row 10/120/230 (last non-zero byte, count of non-zero):", extent(10), extent(120), extent(230))
    cam.close()
    time.sleep_ms(200)
