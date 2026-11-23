# check_board.py - bring-up check, run before the launcher: loads one bitstream and shows its ID and the buttons
# Run it with:  python -m mpremote connect COM8 exec "import check_board; check_board.run('menu.hex.bin')"
import time
import fpga
import loader


# Load a bitstream file, check the link and print the ID (1 menu, 2 Tetris, 3 Pac-Man) and the raw buttons for a few seconds
def run(name, seconds=10):
    print("loaded:", loader.load(name))
    fpga.init()
    fpga.set_pulse_delay(16)
    print("link ok:", fpga.link_ok(), " link ID (expect 90):", fpga.read(0x00), " bitstream ID:", fpga.read(0x141))
    for _ in range(seconds * 5):
        bits = fpga.read(0x140)
        print("buttons=%d  btn1=%d  btn2=%d" % (bits, bits & 1, (bits >> 1) & 1))
        time.sleep_ms(200)
