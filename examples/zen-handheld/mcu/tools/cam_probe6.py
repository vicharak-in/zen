# cam_probe6.py - run with  python -m mpremote connect COM8 run mcu\cam_probe6.py
# Records the pins GPIO 6..21 at every rising PCLK edge (bit 0..7 = D0..D7, bit 8 = PCLK, bit 9 = HREF, bit 10 = VSYNC) and measures how long HREF and VSYNC stay high
import time
import array
import rp2
import machine
from machine import Pin
import camera_ov7670 as cam

N = 6000


# PIO: on every rising PCLK edge push the 16 pins GPIO 6..21 (PCLK = GPIO 14)
@rp2.asm_pio(in_shiftdir=rp2.PIO.SHIFT_LEFT, autopush=True, push_thresh=16)
def _log():
    wait(1, gpio, 14)
    in_(pins, 16)
    wait(0, gpio, 14)


# Lengths of the runs of equal bits (bit number b) in the samples: [(value, length), ...]
def runs(samples, b):
    out = []
    cur = (samples[0] >> b) & 1
    n = 1
    for s in samples[1:]:
        v = (s >> b) & 1
        if v == cur:
            n += 1
        else:
            out.append((cur, n))
            cur, n = v, 1
    out.append((cur, n))
    return out


cam.open()
cam.write_reg(0x42, 0x08)
time.sleep_ms(300)
samples = array.array("H", bytes(2 * N))
sm = rp2.StateMachine(9, _log, freq=machine.freq(), in_base=Pin(6))
dma = rp2.DMA()
ctrl = dma.pack_ctrl(size=1, inc_read=False, inc_write=True, treq_sel=cam._RX_DREQ)
dma.config(read=cam._RX_FIFO, write=samples, count=N, ctrl=ctrl)
dma.active(True)
sm.active(1)
t0 = time.ticks_ms()
while dma.active() and time.ticks_diff(time.ticks_ms(), t0) < 1000:
    pass
sm.active(0)
dma.close()
print("samples", N, "HREF runs (value, pclk samples):", runs(samples, 9)[:12])
print("VSYNC runs:", runs(samples, 10)[:8])
cam.close()
