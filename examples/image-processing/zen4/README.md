# image-processing / zen4: OV7670 -> RP2350 -> FPGA -> VGA (step 1: 80x60 frame buffer)

Plain Verilog-2001 for Efinity (project `cam_zen.xml`, device T4F81, top `cam_zen_top`). Step 1 of the plan:
get a picture on the monitor with a small frame buffer. Step 2 (line streaming for QVGA and Sobel) comes after.

## Why 80x60

The Zen 4 has 76.8 kbit of block RAM in total (15 blocks of 5.12 kbit). A frame of 80x60 at 8 bits is 38,400 bits (8 blocks).
Each camera pixel is shown 8x8 screen pixels wide (`SHIFT = 3`). 160x120 at 4 bits would fill the whole chip.
The older `.sv` files one folder up (320x240) do not fit any Zen and are superseded by this folder.

## Files

| File | Job |
|---|---|
| `cam_zen_top.v` | Board top: power-on reset, button, LEDs, grayscale R = G = B = pixel[7:4] |
| `cam_top.v` | Core: writer + frame buffer + VGA timing + VGA reader, one 25 MHz clock |
| `ov7670_writer.v` | Synchronises the RP2350 strobes, captures pixels, counts addresses |
| `cam_bram.v` | Frame buffer (registered read) |
| `vga_timing.v` | 640x480 @ 60 Hz sync and position |
| `vga_reader.v` | Screen position -> frame buffer address, 3-clock pipeline |
| `tb_cam_zen_top.v` | Self-checking testbench (loads a frame, checks a whole VGA frame) |
| `cam_zen.xml`, `cam_zen.peri.xml`, `cam_zen.sdc` | Efinity project, pads + PLL, timing |

## Simulate (PowerShell, Icarus Verilog)

```powershell
cd C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\zen4
iverilog -g2005 -o sim vga_timing.v cam_bram.v ov7670_writer.v vga_reader.v cam_top.v cam_zen_top.v tb_cam_zen_top.v
vvp sim
```

Expect `pixel errors = 0, sync errors = 0` and `PASS`.

## RP2350 -> FPGA (no wires, the ten internal Zen Link pads used as plain GPIO)

| Port | FPGA pad | RP2350 GPIO |
|---|---|---|
| `cam_pixel[0]` | GPIOL_00 | 24 |
| `cam_pixel[1]` | GPIOL_03 | 25 |
| `cam_pixel[2]` | GPIOL_05 | 26 |
| `cam_pixel[3]` | GPIOL_07 | 27 |
| `cam_pixel[4]` | GPIOL_04 | 0 |
| `cam_pixel[5]` | GPIOL_02 | 1 |
| `cam_pixel[6]` | GPIOL_01 | 2 |
| `cam_pixel[7]` | GPIOL_06 | 3 |
| `cam_we` | GPIOL_09 | 28 |
| `cam_vsync` | GPIOL_10 | 29 |

Protocol: put the pixel byte on the bus, wait at least 2 clocks (80 ns), raise `cam_we` for at least 80 ns, drop it for at least 80 ns, repeat.
A rising `cam_vsync` (hold at least 80 ns) starts a frame; then send 4,800 pixels row by row. Extra pixels are ignored until the next `cam_vsync`.
GPIO 0 to 3 are also the FPGA configuration pins: load the bitstream before driving them. This design does not use the Zen Link protocol.
LED 1 lights when a whole frame was captured, LED 2 when a frame start was seen.

## VGA wiring (proposed pads, read from the board photo: check them against your silkscreen)

Each colour channel is a 4-bit resistor ladder. Bit 0 is the least significant bit.

| Bit | Resistor from pad to the colour pin |
|---|---|
| 3 (MSB) | 510 ohm |
| 2 | 1 kohm |
| 1 | 2 kohm |
| 0 (LSB) | 4.02 kohm (4.3 kohm also works) |

| Signal | Pads (bit 0 first) | DB15 pin |
|---|---|---|
| `vga_r[3:0]` | R-05, R-06, R-07, R-08 | 1 |
| `vga_g[3:0]` | R-10, R-11, R-12, R-13 | 2 |
| `vga_b[3:0]` | R-14, R-17, R-18, R-19 | 3 |
| `vga_hs` | L-11, through 100 ohm | 13 |
| `vga_vs` | L-12, through 100 ohm | 14 |
| GND | any GND | 5, 6, 7, 8, 10 |

Full scale is about 0.72 V into the monitor's 75 ohm input (calculated, not measured).

## Camera on the RP2350 (proposed, not yet implemented)

D0 to D7 -> GPIO 6 to 13, PCLK -> 14, HREF -> 15, VSYNC -> 16, SIOD/SIOC -> 18/19, XCLK <- 23, RESET -> 3V3, PWDN -> GND.

## Before the first build

- Efinity: open `cam_zen.xml`, check the Interface Designer accepts every pad in `cam_zen.peri.xml` (R-xx and L-xx pads are proposals).
- Check the PLL output `clk25` is connected, and that the memory maps to about 8 RAM blocks.
- Not yet synthesized or tested on hardware.
