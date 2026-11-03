# i2c-led

The FPGA is an I2C slave (address 0x32) and LED 1 follows the 0xAA (on) / 0xFF (off) writes; a read returns the last byte written. The RP2350 reaches the slave over the Zen Link: a small block lets it pull SCL and SDA of the unchanged `i2c_led` core low or release them (the I2C master is done in software, `zink_i2c.py`). btn1 resets the slave, and so does `fpga.write(0x10, 1)`.

**Board:** Vicharak Zen 4 (Efinix Trion T4F81 + RP2350). **Ported from:** the Vicharak Shrike example `examples/i2c_led` (GPL-2.0). The I2C slave core is from Renesas (shipped in the Shrike examples).

## Status

| Check | Result |
| --- | --- |
| Simulation (Icarus Verilog, self-checking) | passes: the unchanged core on its own, and the board top driven by real Zen Link frames (`ALL PASS`) |
| Efinity project, pad assignment, timing | built in Efinity 2026.1 for the T4F81: 408 / 3,888 logic elements (10%), 267 LUT4, 195 flip-flops; `clk` meets 50 MHz (maximum 55.6 MHz) |
| On hardware | works as designed on a Zen 4 over the Zen Link (the LED test passes) |

## How the RP2350 reaches the design

The RP2350 talks to the FPGA over the Zen Link only. The core RTL is unchanged; the board top adds an adapter in front of it that turns Zen Link register accesses into the lines the core expects. The bytes are written and read with the helper class in `firmware/RP2350/` (copy it to the board with the main script). The FPGA is loaded with the board loader as for every other Zen Link example, so there is no bitstream in this folder until you build one in Efinity.

## Layout

- `rtl/` `i2c-led-zen4-top.v`, `i2c-led.v`, `i2c-slave.v`, `zl-i2c-pins.v`, `zink/zen-link.v`, `zink/zl-slave.v`, `zink/zl-regs.v`
- `sim/` `run-sim.sh`, `tb-i2c-led-core.v` (the core alone), `tb-i2c-led-zink.v` (through the Zen Link), `zink-host-model.vh`
- `firmware/RP2350/` `i2c-led.py`, `zink_i2c.py`
- Efinity: `i2c-led.peri.xml`, `i2c-led.xml`, and `sdc/` (`i2c-led.sdc`)

## Clock

clk: 50 MHz (50 MHz oscillator on GPIOL_20 into the Efinity PLL), required by the Zen Link.

## Pins

Set in `i2c-led.peri.xml`. Pads marked verified were used in the hardware tests of other examples (clock, buttons, LEDs, the RP2350 link pads and header pads R-05 / R-06). Pads marked placeholder are not verified against the Zen schematic: check them before wiring anything.

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
| `0x100` | LINES | write: bit 0 = pull SCL low, bit 1 = pull SDA low (0 releases a line); read: bit 0 = SCL level, bit 1 = SDA level as the slave sees it |
| `0x10` | CTRL0 | bit 0 = software reset of the slave |

The lines are open drain inside the FPGA: the RP2350 and the slave can both pull SDA low, and a released line reads high.


## Simulate

```
bash sim/run-sim.sh
```

Needs Icarus Verilog (`iverilog`, `vvp`). The script fails unless every testbench prints `ALL PASS`.

## Build and load

1. Open `i2c-led.xml` in Efinity (Trion T4F81).
2. Open Interface Designer and check the PLL and pad assignments against the table above.
3. Run synthesis, place and route, then generate the bitstream (`bitstream/i2c-led.hex.bin`).
4. Copy the files in `firmware/RP2350/*.py` to the RP2350 (MicroPython) and run the main script.
5. Load the bitstream without the Efinity programmer, with the board loader (`main.py` must already be on the board):

```
python -m mpremote cp outflow/i2c-led.hex.bin :
python -m mpremote exec "import main as m; m.FILE_NAME='i2c-led.hex.bin'; m.configure()"
```

The last command prints `CDONE = 1` when the FPGA is configured.

## License

GPL-2.0, like the Shrike repository this is ported from.
