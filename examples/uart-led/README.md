# uart-led

LED 1 follows the 0xAB / 0xFF bytes the RP2350 sends: 0xAB switches it on, 0xFF switches it off. The bytes go over the Zen Link; inside the FPGA a bridge turns them into the UART line the unchanged `uart_led` core listens to (115200 baud). btn1 resets the LED, and so does `fpga.write(0x10, 1)`.

**Board:** Vicharak Zen 4 (Efinix Trion T4F81 + RP2350). **Ported from:** the Vicharak Shrike example `examples/uart_led` (GPL-2.0).

## Status

| Check | Result |
| --- | --- |
| Simulation (Icarus Verilog, self-checking) | passes: the unchanged core on its own, and the board top driven by real Zen Link frames (`ALL PASS`) |
| Efinity project, pad assignment, timing | builds in Efinity for the T4F81: 627 / 3,888 logic elements (16%), 388 LUT4, 328 flip-flops, 1 RAM block; `clk` meets 50 MHz (maximum 51.5 MHz) |
| On hardware | works as designed on a Zen 4 over the Zen Link: `on` / `off` typed in the RP2350 REPL switches LED 1 |

## How the RP2350 reaches the design

The RP2350 talks to the FPGA over the Zen Link only. The core RTL is unchanged; the board top adds an adapter in front of it that turns Zen Link register accesses into the lines the core expects. The bytes are written and read with the helper class in `firmware/RP2350/` (copy it to the board with the main script). The FPGA is loaded with the board loader as for every other Zen Link example, so there is no bitstream in this folder until you build one in Efinity.

## Layout

- `rtl/` `uart-led-zen4-top.v`, `uart-led.v`, `uart-rx.v`, `zl-uart-bridge.v`, `zl-afifo.v`, `zink/zen-link.v`, `zink/zl-slave.v`, `zink/zl-regs.v`
- `sim/` `run-sim.sh`, `tb-uart-led-core.v` (the core alone), `tb-uart-led-zink.v` (through the Zen Link), `zink-host-model.vh`
- `firmware/RP2350/` `uart-led.py`, `zink_uart.py`
- Efinity: `uart-led.peri.xml`, `uart-led.xml`, and `sdc/` (`uart-led.sdc`)

## Clock

clk: 50 MHz (50 MHz oscillator on GPIOL_20 into the Efinity PLL), required by the Zen Link.

## Pins

Set in `uart-led.peri.xml`. Pads marked verified were used in the hardware tests of other examples (clock, buttons, LEDs, the RP2350 link pads and header pads R-05 / R-06). Pads marked placeholder are not verified against the Zen schematic: check them before wiring anything.

| Signal | FPGA pad | Mode | Status | Notes |
| --- | --- | --- | --- | --- |
| `clock input (to PLL)` | GPIOL_20 | input | verified | clock oscillator |
| `btn1` | GPIOR_15 | input | verified | button 1 |
| `led1` | GPIOL_13 | output | verified | LED 1 (active low) |
| `link_clk_in` | GPIOL_09 | input | verified | RP2350 GPIO28 |
| `link_csn_in` | GPIOL_10 | input | verified | RP2350 GPIO29 |
| `link_d[0]` | GPIOL_00 | inout | verified | RP2350 GPIO24 |
| `link_d[1]` | GPIOL_03 | inout | verified | RP2350 GPIO25 |
| `link_d[2]` | GPIOL_05 | inout | verified | RP2350 GPIO26 |
| `link_d[3]` | GPIOL_07 | inout | verified | RP2350 GPIO27 |
| `link_d[4]` | GPIOL_04 | inout | verified | RP2350 GPIO0 |
| `link_d[5]` | GPIOL_02 | inout | verified | RP2350 GPIO1 |
| `link_d[6]` | GPIOL_01 | inout | verified | RP2350 GPIO2 |
| `link_d[7]` | GPIOL_06 | inout | verified | RP2350 GPIO3 |

## Zen Link registers

| Address | Name | Use |
| --- | --- | --- |
| `0x100` | DATA | write: queue a byte for the core; read: take a byte the core sent (0 when none) |
| `0x101` | STATUS | bit0 data waiting, bit1 room to write, bit2 write overflow, bit3 receive overflow, bit4 idle; a write clears the sticky bits |
| `0x102` | RXCNT | bytes the core has sent that are waiting (max 255) |
| `0x103` | TXFREE | room for more bytes towards the core (max 255) |
| `0x104` / `0x105` | CPB_LO / CPB_HI | clocks per UART bit seen by the core (default set in the top) |
| `0x180`..`0x1FF` | window | every address acts like DATA, so up to 128 bytes move in one frame |
| `0x10` | CTRL0 | bit 0 = software reset of the design |


## Simulate

```
bash sim/run-sim.sh
```

Needs Icarus Verilog (`iverilog`, `vvp`). The script fails unless every testbench prints `ALL PASS`.

## Build and load

1. Open `uart-led.xml` in Efinity (Trion T4F81).
2. Open Interface Designer and check the PLL and pad assignments against the table above.
3. Run synthesis, place and route, then generate the bitstream (`outflow/uart-led.hex.bin`).
4. Copy the files in `firmware/RP2350/*.py` to the RP2350 (MicroPython). The script asks for input, so run it in the REPL: `python -m mpremote repl`, then `exec(open('uart-led.py').read())`, and type `on` or `off` (Ctrl-C stops it, Ctrl-] leaves the REPL).
5. Load the bitstream without the Efinity programmer, with the board loader (`main.py` must already be on the board):

```
python -m mpremote cp outflow/uart-led.hex.bin :
python -m mpremote exec "import main as m; m.FILE_NAME='uart-led.hex.bin'; m.configure()"
```

The last command prints `CDONE = 1` when the FPGA is configured.

## License

GPL-2.0, like the Shrike repository this is ported from.
