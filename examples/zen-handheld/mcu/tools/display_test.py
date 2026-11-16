# display_test.py - first check of an SPI display on the Zen 8: colour bars, text and a moving square
# Copy spi_display.py and this file to the board, then run:  python -m mpremote connect COM8 run mcu\display_test.py
# Change PRESET to your panel: st7789_240x320, st7789_240x240, ili9341_240x320 or st7735_128x160
import time
import spi_display as d

PRESET = "ili9341_240x320"

# Start the panel
lcd = d.Display(PRESET, rotation=90)
# Eight vertical colour bars: if the colours look wrong, the order or inversion setting of the preset is off
bars = (d.WHITE, d.YELLOW, d.color565(0, 255, 255), d.GREEN, d.color565(255, 0, 255), d.RED, d.BLUE, d.BLACK)
bw = lcd.w // len(bars)
for i, c in enumerate(bars):
    lcd.fill_rect(i * bw, 0, bw, lcd.h, c)
# Text over the bars
lcd.text("Zen 8", 10, 10, d.WHITE, d.BLACK, 3)
lcd.text(PRESET, 10, 50, d.WHITE, d.BLACK, 1)
time.sleep_ms(2000)
# A square bouncing for about 5 s on a black screen
lcd.fill(d.BLACK)
x, y, vx, vy, s = 10, 10, 3, 2, 24
for _ in range(150):
    lcd.fill_rect(x, y, s, s, d.BLACK)
    x += vx
    y += vy
    if x < 0 or x + s > lcd.w:
        vx = -vx
        x += 2 * vx
    if y < 0 or y + s > lcd.h:
        vy = -vy
        y += 2 * vy
    lcd.fill_rect(x, y, s, s, d.GREEN)
    time.sleep_ms(20)
lcd.text("done", 10, 10, d.WHITE, d.BLACK, 2)
