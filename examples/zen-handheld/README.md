# Zen Tetris

Tetris on the Vicharak Zen 4 board. The two buttons go to the Trion FPGA, the FPGA passes their state to the RP2350 over the Zen Link, the RP2350 runs the game, and the PC only draws the board.

```
buttons -> Trion (debounce, register 0x140) -> Zen Link -> RP2350 (game logic) -> USB serial -> PC (pygame window)
```

## Folder layout

| Folder | Contents |
|---|---|
| `fpga/` | `tetris_zink_top.v`, `btn_debounce.v` (Verilog for Efinity) |
| `mcu/` | `tetris_main.py`, `buttons.py`, `tetris_game.py`, `loader_main.py`, `boot_main.py` (MicroPython, copied to the board) |
| `pc/` | `tetris_display.py` (pygame + pyserial), `test_game.py` (game tests on the PC) |

## Controls

| Input | Action |
|---|---|
| A tap | move left |
| B tap | move right |
| A and B together | rotate |
| A or B long press | hard drop |

A long press is a press held for 450 ms (`HOLD_MS` in `buttons.py`). Holding does not repeat a move, so tap for each column.

## 1. FPGA

1. Make a new Efinity project named `tetris_zink` for the T4F81.
2. Copy `zink_aes/zink_aes.peri.xml` and `zink_aes/zink_aes.sdc` into the project and rename them to `tetris_zink.peri.xml` and `tetris_zink.sdc`. The periphery file name must match the project name. The buttons are already set up there: `btn1` on GPIOR_15 and `btn2` on GPIOR_16, weak pull-up, active low.
3. Copy `zen_link.v`, `zl_slave.v` and `zl_regs.v` from `aesxzen/rtl/zink/`.
4. Add `fpga/tetris_zink_top.v` and `fpga/btn_debounce.v`.
5. Set the top module to `tetris_zink_top`, synthesise, and load the bitstream.

The fabric clock is 25 MHz. The debouncer's default count (249999) gives 10 ms at that rate. If you use a 50 MHz clock, change `CNT_MAX` to `18'd499999`.

Before the first build, check the two pad numbers against the silkscreen of your board.

## 2. Board

The FPGA is configured by the RP2350, which reads the bitstream file from its own flash. Compiling in Efinity alone changes nothing on the board. Do not copy the game over the board's `main.py`: that file is the loader.

```
cd zen_tetris
python -m mpremote connect COM8 cp fpga\outflow\tetris_zink.hex.bin :tetris_zink.hex.bin
cd mcu
python -m mpremote connect COM8 run loader_main.py       (expect: sent 167580 bytes, CDONE = 1)
python -m mpremote connect COM8 run button_test.py       (expect: Link ID 90, buttons=1 / 2 / 3 when pressed)
python -m mpremote connect COM8 cp tetris_game.py :
python -m mpremote connect COM8 cp buttons.py :
python -m mpremote connect COM8 cp tetris_main.py :
python -m mpremote connect COM8 cp loader_main.py :
python -m mpremote connect COM8 cp boot_main.py :main.py
python -m mpremote connect COM8 reset
```

After this, every power-up loads the FPGA and starts the game. Close `mpremote` before starting the PC display, because the display needs the serial port.

## 3. PC display

```
pip install pygame pyserial
python pc/tetris_display.py COM5          (Windows; use your port)
python pc/tetris_display.py /dev/ttyACM0  (Linux)
```

## 4. Tests on the PC

No board needed. Run from the `pc` folder:

```
python test_game.py
```

## Notes

- The frame is 25 bytes of board data, sent about 30 times a second as a text line starting with `F:`.
- Soft drop is not included. Gravity speeds up with each level.
- Game over shows for 3 seconds, then a new game starts.
