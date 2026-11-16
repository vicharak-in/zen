# cam_probe5.py - run with  python -m mpremote connect COM8 run mcu\cam_probe5.py
# Counts the PCLK pulses while HREF is high (one line) with a PIO program, for several lines. A QVGA RGB565 line must have 640.
import time
import rp2
import machine
from machine import Pin
import camera_ov7670 as cam


# PIO: wait for HREF to rise, count the rising PCLK edges until HREF is low again, push the count (PCLK = GPIO 14, HREF = GPIO 15)
@rp2.asm_pio()
def _count():
    mov(x, invert(null))
    wait(0, gpio, 15)
    wait(1, gpio, 15)
    label("loop")
    wait(1, gpio, 14)
    jmp(x_dec, "chk")
    label("chk")
    wait(0, gpio, 14)
    jmp(pin, "loop")
    mov(isr, invert(x))
    push()


cam.open()
cam.write_reg(0x42, 0x08)
time.sleep_ms(300)
for hz_label in ("now",):
    sm = rp2.StateMachine(9, _count, freq=machine.freq(), jmp_pin=Pin(15))
    counts = []
    for i in range(8):
        sm.active(0)
        sm.restart()
        sm.active(1)
        t0 = time.ticks_ms()
        while sm.rx_fifo() == 0 and time.ticks_diff(time.ticks_ms(), t0) < 500:
            pass
        counts.append(sm.get() if sm.rx_fifo() else -1)
    sm.active(0)
    print("PCLK pulses while HREF high, 8 lines:", counts)
cam.close()
