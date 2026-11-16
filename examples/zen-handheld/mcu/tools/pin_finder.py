# pin_finder.py - finds which RP2350 GPIO number sits behind each numbered pin of the Zen hat
# Run:  python -m mpremote connect COM4 run mcu\pin_finder.py
# Take the display signal wires off the hat first. Put one end of a jumper in the hat's 3V3 hole and touch the other end to hat pin 1,
# wait for the line, then pin 2, then 3 ... up to 10. Every touch prints which GPIO went high (a touch can print twice: contact bounce).
# It prints "alive" every 5 s so you know it is running. Stops after 3 minutes (or Ctrl+C).
from machine import Pin
import time


# Every GPIO except 4 and 5 (CDONE and CRESET of the FPGA)
pins = []
for n in [g for g in range(0, 48) if g not in (4, 5)]:
    try:
        pins.append((n, Pin(n, Pin.IN, Pin.PULL_DOWN)))
    except ValueError:
        pass
print("ready (%d GPIOs watched), touch 3V3 to hat pin 1" % len(pins))
last = {n: p.value() for n, p in pins}
# GPIOs that already read high before any touch (a wire or something holds them)
for n, p in pins:
    if last[n]:
        print("GPIO", n, "is already high (a wire holds it)")
end = time.ticks_add(time.ticks_ms(), 180000)
beat = time.ticks_add(time.ticks_ms(), 5000)
while time.ticks_diff(end, time.ticks_ms()) > 0:
    for n, p in pins:
        v = p.value()
        # A GPIO that just went high is the one under the jumper
        if v and not last[n]:
            print("GPIO", n, "went high")
        last[n] = v
    if time.ticks_diff(time.ticks_ms(), beat) >= 0:
        print("alive")
        beat = time.ticks_add(time.ticks_ms(), 5000)
    time.sleep_ms(5)
print("done")
