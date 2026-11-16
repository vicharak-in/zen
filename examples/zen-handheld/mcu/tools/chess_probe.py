# chess_probe.py - checks the chess move service of the FPGA: run with  python -m mpremote connect COM8 run mcu\chess_probe.py
import loader, fpga, time
import chess_engine as E

# Load the chess bitstream and start the link
print("load:", loader.load("chess.hex.bin"))
fpga.init()
fpga.set_pulse_delay(16)
print("id (want 10):", fpga.read(0x141))
# Status before any request: {flags, from, to, promo}
st = bytearray(4)
fpga.read_block(0x1A8, st)
print("status before:", list(st))
# The start position, white to move
b = [4, 2, 3, 5, 6, 3, 2, 4] + [1] * 8 + [0] * 32 + [9] * 8 + [12, 10, 11, 13, 14, 11, 10, 12]
p = E.Pos(b, 0, 15, -1, [4, 60], 0)
e = E.Engine(fpga, 1, 3000)
# Upload it and ask for the legal moves
e.load(p)
fpga.write(0x1A8, 1)
time.sleep_ms(50)
# Read five moves (expect flags 1 and a different from/to each time)
for i in range(5):
    fpga.read_block(0x1A8, st)
    print("move", i, list(st))
    fpga.write(0x1A9, 1)
    time.sleep_ms(5)

# Finish reading the list so the FPGA is ready for the next request
e.drain()

# Speed of the link: 100 status reads
t = time.ticks_ms()
for i in range(100):
    fpga.read_block(0x1A8, st)
print("100 status reads (ms):", time.ticks_diff(time.ticks_ms(), t))
# One full move list of the start position, and the search at depth 1 and 2 from it
e = E.Engine(fpga, 2, 60000)
e.deadline = time.ticks_add(time.ticks_ms(), 60000)
t = time.ticks_ms()
n = len(e.legal(p))
print("one move list: %d moves, %d ms" % (n, time.ticks_diff(time.ticks_ms(), t)))
for d in (1, 2):
    e = E.Engine(fpga, d, 60000)
    t = time.ticks_ms()
    m, v = e.best_move(p)
    print("depth", d, "move", m, "value", v, "lists", e.gens, "ms", time.ticks_diff(time.ticks_ms(), t))
