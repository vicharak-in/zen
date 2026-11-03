# Zen Link: RP2350 <-> Trion T4F81 register bus

A fast, small register link between the RP2350 and the FPGA on the Vicharak Zen board. From MicroPython:

```python
import fpga
fpga.init()
fpga.write(0x10, 1)      # drive a CTRL register (LED1 on in the example top)
fpga.read(0x20)          # read a STAT register (buttons in the example top)
```

The same registers appear as plain buses (`ctrl_flat`, `stat_flat`) in Verilog. 8-bit registers, 10 wires, no clock-domain crossing, no CRC. About 182 LUT4 / 128 FF on the T4F81 (4 CTRL + 4 STAT registers). Measured on the board: about 2.3 MB/s with 128-byte bursts at the default speed, zero errors in the stress test.

Full protocol, pinout, timing and speed measurements: [docs/PROTOCOL.md](./docs/PROTOCOL.md). Want to connect your own design? See [docs/USING_ZINK.md](./docs/USING_ZINK.md) and the worked examples [examples/zink_pwm](./examples/zink_pwm) (simplest) and [examples/zink_alu](./examples/zink_alu).

## Repository layout

```
zink/
├── README.md
├── docs/
│   ├── PROTOCOL.md             pinout, frame format, registers, timing, speed table, integration
│   └── USING_ZINK.md           how to plug your own design into zink (start with examples/zink_alu)
├── examples/
│   ├── zink_pwm/               LED brightness set from the MCU (simplest example), with its own Efinity project
│   └── zink_alu/               8-bit ALU controlled over zink (rtl, sim, mcu demo), with its own Efinity project
├── rtl/                        FPGA design (Verilog)
│   ├── top.v                     example top: LEDs on CTRL0, buttons on STAT0
│   ├── zen_link.v                link IP top (ports, ctrl/stat buses, user bus)
│   ├── zl_slave.v                frame state machine (CMD / ADDR / data / turnaround)
│   └── zl_regs.v                 register block (ID, SCRATCH, VERSION, CTRL, STAT)
├── mcu/                        RP2350 side: MicroPython native module `fpga`
│   ├── bus.c, bus.h              pin driver and frame engine
│   ├── fpga.c                    MicroPython API (write, read, write_block, read_block, ...)
│   ├── Makefile.txt              build recipe for fpga.mpy
│   └── fpga.mpy                  prebuilt module
├── sim/                        verification (cocotb + Icarus Verilog)
│   ├── run_sim.py                runs everything
│   ├── tb_zen_link.v             DUT wrapper
│   ├── test_zen_link.py          9 RTL tests (frames, bursts, abort, speed sweep, random traffic)
│   ├── test_mcu_driver.py        6 tests running the real mcu/bus.c against the RTL
│   ├── host_shim.c               host-side stand-in for the RP2350 pins, lets bus.c run in the simulation
│   └── stress.py                 on-board stress test and speed sweep (runs on the board, not in the simulation)
├── zen_link.xml                Efinity project for the base LED/button example
├── zen_link.peri.xml           Efinity pin and PLL setup
├── zen_link.sdc                timing constraints
└── package_settings.xml        Efinity package setting (T4F81)
```

Efinity writes `outflow/`, `work_*/`, `ooc/` and `ip/` when you build. They are generated, listed in `.gitignore`, and not part of the source.

## Build and load

1. Open `zen_link.xml` in Efinity (device **T4F81**), run the full flow. The bitstream is `outflow/zen_link.hex.bin`. Close Efinity before editing `zen_link.peri.xml` by hand, because Efinity overwrites it.
2. Copy the bitstream and the driver to the board:
   ```
   python -m mpremote cp outflow/zen_link.hex.bin :
   python -m mpremote cp mcu/fpga.mpy :
   ```
   The FPGA loader is the one already in this repository, `bring-up/mcu/rp_fpga_flash.py`. Open it, change `FILE_NAME` to `'zen_link.hex.bin'`, and copy it to the board as `main.py`:
   ```
   python -m mpremote cp <path to rp_fpga_flash.py> :main.py
   ```
3. Load the FPGA after every power cycle. Expect `CDONE = 1`:
   ```
   python -m mpremote exec "import main"
   ```
4. Open the MicroPython shell with `python -m mpremote` and try:
   ```python
   import fpga
   fpga.init()
   fpga.link_ok()            # True: ID 0x5A and ID_INV 0xA5 read back
   fpga.write(0x10, 1)       # LED1 on
   fpga.read(0x20)           # 1 while button 1 is held, 2 for button 2
   ```

To rebuild the driver: `cd mcu && make -f Makefile.txt MPY_DIR=<micropython checkout>` (use `rm -rf build-armv7m fpga.mpy` first when rebuilding).

## Register map

| Address | Name | Access | Notes |
|---|---|---|---|
| 0x00 | ID | R | 0x5A |
| 0x01 | ID_INV | R | 0xA5 |
| 0x02 | SCRATCH | R/W | free test register |
| 0x03 | VERSION | R | 0x01 |
| 0x10-0x13 | CTRL0-3 | R/W | MCU to FPGA, `ctrl_flat[8k+7:8k]`. In the example top: bit 0 = LED1, bit 1 = LED2 |
| 0x20-0x23 | STAT0-3 | R | FPGA to MCU, `stat_flat[8k+7:8k]`. In the example top: bit 0 = button 1, bit 1 = button 2 |
| 0x100 and up | user bus | R/W | `usr_addr`, `usr_wr`, `usr_wdata`, `usr_rd`, `usr_rdata` for your own logic |

## Tests

```
cd sim
python run_sim.py
```

Needs `cocotb` 2.x and Icarus Verilog. Expect 9/9 and 6/6 passing, for both RAM read styles (`RAM_REG` 0 and 1). On the board, run `python -m mpremote run sim/stress.py`.
