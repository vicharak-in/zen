# launcher.py - the handheld: boots to a menu, loads the chosen game's bitstream into the FPGA, runs it, and returns to the menu when both buttons are held
# Bitstreams live in the RP2350's flash: menu.hex.bin and one file per game (tetris, pacman, runner, flyer, pong, snake, shooter, doom, chess). The PC window shows whatever this prints:
#   M:<selected> <name>,<name>   the menu          N:<text>   a notice          E:<text>   an error
#   F:...  a Tetris frame    P:...  a Pac-Man frame    R:...  a Mario Lite frame    G:<id>:...  a frame of Flyer (5), Pong (6), Snake (7), Guard (8), Doom (9), Chess (10)
import time
import fpga
import loader
import tetris_view
import runner_view
import chess_view

# The games in menu order (Zen 4 has 3.9k LEs: Tetris, the Mario-style Runner and Chess fit; Chess keeps the rules and the legal-move generator in the FPGA and the search on the RP2350). The menu also lists Camera and Flight from sink_tft.APPS
GAMES = (tetris_view, runner_view, chess_view)
# Menu bitstream and the ID it reports at 0x141
MENU_FILE = "menu.hex.bin"
MENU_ID = 1
# Registers every bitstream has: buttons (bit0 = btn1, bit1 = btn2, 1 = pressed) and the bitstream ID
BTN_ADDR = 0x140
ID_ADDR = 0x141
# Link clock setting for the 25 MHz fabric clock
PULSE_DELAY = 16
# How often and how long (ms) the link is asked after a load
LINK_TRIES = 10
LINK_WAIT_MS = 5
# Both buttons held this long (ms) leave the game
EXIT_MS = 2000
# How often the menu line is sent and how often the buttons are read in the menu (ms)
MENU_LINE_MS = 100
MENU_POLL_MS = 10


# Load a bitstream and check that the right one is running; retries once if the load or the check fails
def start(file, want_id):
    for attempt in range(2):
        print("N:Loading %s" % file)
        ok = loader.load(file)
        # Start the link pins and set the link clock
        fpga.init()
        if hasattr(fpga, "set_pulse_delay"):
            fpga.set_pulse_delay(PULSE_DELAY)
        # The link must answer and the bitstream must be the one we asked for
        # The FPGA may need a few ms before the link answers, so ask again for a short while instead of reloading
        link = False
        for _ in range(LINK_TRIES):
            link = fpga.link_ok()
            if link:
                break
            time.sleep_ms(LINK_WAIT_MS)
        got = fpga.read(ID_ADDR) if link else -1
        if ok and link and got == want_id:
            return
        why = "CDONE=%s link=%s id=%s want=%s" % (ok, link, got, want_id)
    raise RuntimeError("could not start %s (%s)" % (file, why))


# Show the menu until a game is chosen: A (btn2) moves the selection, B (btn1) starts the game; returns the index
def run_menu():
    # Load the menu bitstream
    start(MENU_FILE, MENU_ID)
    # Selected game, previous button levels and the time of the last menu line
    sel = 0
    prev_a = prev_b = True
    last = time.ticks_ms() - MENU_LINE_MS
    names = ",".join(g.NAME for g in GAMES)
    while True:
        # Buttons: A is bit 1 (btn2), B is bit 0 (btn1)
        bits = fpga.read(BTN_ADDR) & 3
        a = bool(bits & 2)
        b = bool(bits & 1)
        # A new press of A: next game
        if a and not prev_a:
            sel = (sel + 1) % len(GAMES)
            last = time.ticks_ms() - MENU_LINE_MS
        # A new press of B: start the selected game (the press that chose it is not held over)
        if b and not prev_b:
            return sel
        prev_a, prev_b = a, b
        # The menu line, ten times a second
        if time.ticks_diff(time.ticks_ms(), last) >= MENU_LINE_MS:
            last = time.ticks_ms()
            print("M:%d %s" % (sel, names))
        time.sleep_ms(MENU_POLL_MS)


# Run one game: send frames until both buttons have been held for EXIT_MS
def run_game(game):
    # Load the game's bitstream
    start(game.FILE, game.GAME_ID)
    # When both buttons were first seen down together (None while not)
    both_since = None
    while True:
        # One frame to the PC
        print(game.format_line(game.read_state()))
        # Both buttons held long enough: back to the menu
        if (fpga.read(BTN_ADDR) & 3) == 3:
            now = time.ticks_ms()
            if both_since is None:
                both_since = now
            elif time.ticks_diff(now, both_since) >= EXIT_MS:
                print("N:Back to the menu")
                return
        else:
            both_since = None
        time.sleep_ms(game.FRAME_MS)


# The handheld: menu, game, menu, game, forever; an error is shown on the PC and the menu comes back
def main():
    while True:
        try:
            run_game(GAMES[run_menu()])
        except Exception as e:
            print("E:%s" % e)
            time.sleep_ms(2000)
