# launcher_gfx.py - the handheld with the RP2350 doing the drawing: menu, game, menu, game, forever (same behaviour as launcher.py, but it draws instead of printing text)
# main(sink) gets the place the pictures go: sink_usb (PC window shows them, option A) or sink_tft (SPI TFT on the board, option B).
# A sink has: menu(sel, names), notice(text), error(text), game(view, buf), and the numbers PAUSE_MS and REPEAT_MENU.
import time
import fpga
import loader
import launcher

# The games, the menu bitstream and the registers are the same as in launcher.py
GAMES = launcher.GAMES
MENU_FILE = launcher.MENU_FILE
MENU_ID = launcher.MENU_ID
BTN_ADDR = launcher.BTN_ADDR
ID_ADDR = launcher.ID_ADDR
PULSE_DELAY = launcher.PULSE_DELAY
EXIT_MS = launcher.EXIT_MS
MENU_LINE_MS = launcher.MENU_LINE_MS
MENU_POLL_MS = launcher.MENU_POLL_MS
# After the games the menu lists the sink's extra apps (sink.APPS = (name, begin, step, end) ...); they need no bitstream, the menu bitstream stays loaded and gives the buttons


# Load a bitstream and check that the right one is running; retries once if the load or the check fails (the notice goes to the screen)
def start(sink, file, want_id):
    for attempt in range(2):
        sink.notice("Loading " + file.split(".")[0])
        ok = loader.load(file)
        # Start the link pins and set the link clock
        fpga.init()
        if hasattr(fpga, "set_pulse_delay"):
            fpga.set_pulse_delay(PULSE_DELAY)
        # The link must answer and the bitstream must be the one we asked for
        # The FPGA may need a few ms before the link answers, so ask again for a short while instead of reloading
        link = False
        for _ in range(launcher.LINK_TRIES):
            link = fpga.link_ok()
            if link:
                break
            time.sleep_ms(launcher.LINK_WAIT_MS)
        got = fpga.read(ID_ADDR) if link else -1
        if ok and link and got == want_id:
            return
        why = "CDONE=%s link=%s id=%s want=%s" % (ok, link, got, want_id)
    raise RuntimeError("could not start %s (%s)" % (file, why))


# Show the menu until a game is chosen: A (btn2) moves the selection, B (btn1) starts the game; returns the index
def run_menu(sink):
    start(sink, MENU_FILE, MENU_ID)
    # Selected game, previous button levels, the time of the last picture and whether the picture is out of date
    sel = 0
    prev_a = prev_b = True
    last = time.ticks_ms() - MENU_LINE_MS
    stale = True
    names = [g.NAME for g in GAMES] + [a[0] for a in sink.APPS]
    while True:
        # Buttons: A is bit 1 (btn2), B is bit 0 (btn1)
        bits = fpga.read(BTN_ADDR) & 3
        a = bool(bits & 2)
        b = bool(bits & 1)
        # A new press of A: next game
        if a and not prev_a:
            sel = (sel + 1) % len(names)
            stale = True
        # A new press of B: start the selected game
        if b and not prev_b:
            return sel
        prev_a, prev_b = a, b
        # Draw when something changed (and ten times a second when the sink wants a steady stream)
        if stale or (sink.REPEAT_MENU and time.ticks_diff(time.ticks_ms(), last) >= MENU_LINE_MS):
            last = time.ticks_ms()
            stale = False
            sink.menu(sel, names)
        time.sleep_ms(MENU_POLL_MS)


# Run one game: draw frames until both buttons have been held for EXIT_MS
def run_game(sink, game):
    start(sink, game.FILE, game.GAME_ID)
    # When both buttons were first seen down together (None while not)
    both_since = None
    while True:
        # One frame
        buf = game.read_state()
        sink.game(game, buf)
        # Games with a computer opponent run its search here (the frame above already shows the human's move)
        if hasattr(game, "think"):
            game.think(buf)
        # Both buttons held long enough: back to the menu
        if (fpga.read(BTN_ADDR) & 3) == 3:
            now = time.ticks_ms()
            if both_since is None:
                both_since = now
            elif time.ticks_diff(now, both_since) >= EXIT_MS:
                sink.notice("Back to the menu")
                return
        else:
            both_since = None
        time.sleep_ms(sink.PAUSE_MS)


# Run an extra app: begin(), then step(buttons) over and over until both buttons have been held for EXIT_MS, then end()
def run_app(sink, app):
    begin, step, end = app[1], app[2], app[3]
    begin()
    both_since = None
    try:
        while True:
            # Buttons: bit 1 = A, bit 0 = B; the app uses them for its own functions
            bits = fpga.read(BTN_ADDR) & 3
            step(bits)
            # Both buttons held long enough: back to the menu
            if bits == 3:
                now = time.ticks_ms()
                if both_since is None:
                    both_since = now
                elif time.ticks_diff(now, both_since) >= EXIT_MS:
                    return
            else:
                both_since = None
            time.sleep_ms(2)
    finally:
        end()


# The handheld: menu, game, menu, game, forever; an error is shown on the screen and the menu comes back
def main(sink):
    while True:
        try:
            sel = run_menu(sink)
            if sel >= len(GAMES):
                run_app(sink, sink.APPS[sel - len(GAMES)])
            else:
                run_game(sink, GAMES[sel])
        except Exception as e:
            sink.error(str(e))
            time.sleep_ms(2000)
