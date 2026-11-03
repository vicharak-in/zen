# zink_pwm

The simplest zink example: the RP2350 sets the brightness of the two board LEDs with one register write each. A small PWM block lives in the FPGA, and the MCU only changes a number.

New to zink? Read this, then [examples/zink_alu](../zink_alu) for an example with results coming back, and [docs/USING_ZINK.md](../../docs/USING_ZINK.md) for the general recipe.

## Architecture

```
 RP2350                                   FPGA
 ┌──────────────────────┐                 ┌──────────────────────────────────────┐
 │ your MicroPython     │                 │ pwm.v x2   counter < duty -> out     │
 │  fpga.write(0x10, d) │                 │   ▲ duty1 = ctrl_flat[7:0]   │ out   │
 │  fpga.write(0x11, d) │                 │   │ duty2 = ctrl_flat[15:8]  ▼       │
 ├──────────────────────┤                 │ zink_pwm_top.v: ~out -> led1 / led2  │
 │ fpga.mpy (bus.c)     │   D0..D7        ├──────────────────────────────────────┤
 │ builds the frame,    │◄──────────────► │ zl_regs + zl_slave = zen_link        │
 │ drives the pins      │   CLK ────────► │ (samples pins with the 50 MHz clock) │
 │                      │   CS_N ───────► │                                      │
 └──────────────────────┘                 └──────────────────────────────────────┘

 write path:  fpga.write(0x10, 128) -> frame -> zl_slave -> CTRL0 -> ctrl_flat[7:0] -> pwm1.duty -> LED1
 nothing comes back: the PWM keeps running by itself after the write
```

The frame for `fpga.write(0x10, 128)` is four bytes: command `0x00` (write, 1 byte), address `0x00` `0x10`, data `0x80`. The general picture and the read frame are in [docs/USING_ZINK.md](../../docs/USING_ZINK.md).

## What happens

```
MicroPython                  FPGA
fpga.write(0x10, 128) ──> zen_link ──ctrl_flat[7:0]──> pwm ──> LED1
fpga.write(0x11, 30)  ──>          ──ctrl_flat[15:8]─> pwm ──> LED2
```

1. **The MCU writes a register.** `fpga.write(0x10, 128)` sends one frame over the 10 wires: a command byte, the address `0x0010`, then the data byte `128`.
2. **zink stores it.** The link IP puts the byte in CTRL0. CTRL0 is wired straight to the `duty` input of the PWM block, so the new brightness takes effect immediately.
3. **The PWM block runs by itself.** `pwm.v` has a counter that counts 0 to 255 over and over. The output is high while the counter is below `duty`, so in every 256 clocks it is high for exactly `duty` clocks. Duty 0 is off, 128 is half, 255 is almost full.
4. **The LED looks dimmer or brighter.** One period is 5 microseconds at 50 MHz, far too fast to see, so the eye just averages it into a brightness. The LED pins are active low, so the top inverts the PWM output.

The MCU does not need to keep talking. After one write the FPGA keeps the LED at that brightness on its own.

## Registers

| Register | Address | Meaning |
|---|---|---|
| CTRL0 | 0x10 | LED1 brightness, 0 off to 255 full |
| CTRL1 | 0x11 | LED2 brightness, 0 off to 255 full |

Both read back the value last written. No STAT registers are used. Consecutive registers auto-increment, so one frame can set both: `fpga.write_block(0x10, bytes([10, 90]))`.

## Files

```
zink_pwm/
├── rtl/
│   ├── pwm.v               the IP: a counter and a comparator, knows nothing about zink
│   └── zink_pwm_top.v      glue: CTRL0/1 -> two pwm blocks -> LEDs, plus zen_link
├── zink_pwm.xml            Efinity project (open this in Efinity)
├── sim/
│   ├── tb_zink_pwm.v       tri-state bus wrapper around the top
│   ├── test_zink_pwm.py    3 cocotb tests: on-time equals duty, channels independent, burst + readback
│   └── run_sim.py
```

## Run it

**Simulation** (needs `cocotb` 2.x and Icarus Verilog):

```
cd sim
python run_sim.py
```

Expect 3/3 passing. The tests count, over one 256-clock period, how many clocks each LED pin is on, and check it equals the duty value for 0, 1, 64, 128, 200 and 255.

**On the board:**

1. Open `zink_pwm.xml` (in this folder) in Efinity. It uses the link IP in `../../rtl` and the shared pin and timing files `../../zen_link.peri.xml` / `../../zen_link.sdc`. The first time, open Interface Designer, run Check Design and Generate Efinity Constraints. Then run the full flow. The bitstream is `outflow/zink_pwm.hex.bin` in this folder.
2. Copy it and set the loader's file name (run these from the zink folder):
   ```
   python -m mpremote cp examples/zink_pwm/outflow/zink_pwm.hex.bin :
   python -m mpremote exec "s=open('main.py').read().replace('zen_link.hex.bin','zink_pwm.hex.bin'); open('main.py','w').write(s)"
   ```
   If `main.py` already points at another example, replace that file name instead.
3. Load the FPGA onto the board (expect `CDONE = 1`):
   ```
   python -m mpremote exec "import main"
   ```

**Try it by typing commands.** Open the MicroPython shell on the board from the same terminal:

```
python -m mpremote
```

You get a `>>>` prompt. Type these lines one at a time and watch the LEDs:

```python
import fpga
fpga.init()
fpga.link_ok()              # True: the link is up
fpga.write(0x10, 255)       # LED1 bright
fpga.write(0x10, 20)        # LED1 dim
fpga.write(0x10, 0)         # LED1 off
fpga.write(0x11, 128)       # LED2 half brightness
fpga.read(0x10)             # 0    (registers read back what was written)
fpga.read(0x11)             # 128
```

Both LEDs in one frame, because consecutive registers auto-increment:

```python
fpga.write_block(0x10, bytes([10, 90]))   # LED1 = 10 (dim), LED2 = 90
```

A fade, typed by hand (press Enter twice after the last line):

```python
import utime
for d in range(0, 256, 5):
    fpga.write(0x10, d)
    utime.sleep_ms(10)

```

Press `Ctrl+X` to leave the shell.

**Without the shell**, one command from the terminal sets the LEDs and exits:

```
python -m mpremote exec "import fpga; fpga.init(); fpga.write(0x10, 255); fpga.write(0x11, 30)"
```

Tested on the Zen board: both LEDs fade smoothly when the duty values are changed over the link.

If nothing lights, check that `FILE_NAME` in the board's `main.py` is `zink_pwm.hex.bin`. A stale name loads the old design and still prints `CDONE = 1`.

## Build results (Efinity 2026.1, T4F81)

| | |
|---|---|
| Logic | 185 LUT4, 132 FF, 7 adders, 1 global buffer |
| Timing at 50 MHz | met: max clock 53.5 MHz, setup slack +1.3 ns, hold slack +0.64 ns |

The build prints warnings that `btn1` and `btn2` are unconnected, and a matching SDC warning on the button false path. They are expected and harmless: this example does not use the buttons, and the ports are only kept so the pin setup is shared with the other examples.

## Try changing it

- Make a third channel on CTRL2 (add one more `pwm` block and one more line in the top).
- Make the PWM slower (add a counter prescaler) and watch the LED actually blink.
