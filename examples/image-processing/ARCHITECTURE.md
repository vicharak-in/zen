# Camera pipeline architecture (320x240 SystemVerilog set, SUPERSEDED)

**This set does not fit the Zen boards.** A 320x240 8-bit frame is 614,400 bits. The Zen 4 (T4F81) has 76.8 kbit of block RAM
(15 blocks) and the Zen 8 (T8F81) has 122.88 kbit (24 blocks). The earlier numbers in this file (144 KB and 1.15 MB) were wrong.

The working design is in `zen4/` (plain Verilog-2001, 80x60 frame buffer, Efinity project included). See `zen4/README.md`.
The `.sv` files in this folder still simulate correctly and are kept as a reference for the QVGA line-streaming step.

## Data path (same idea in both sets)

```
RP2350 --(pixel, we, vsync)--> writer --(waddr,wdata,we)--> frame buffer
vga_timing --(x,y,active,syncs)--> vga_reader --(raddr)--> frame buffer --(rdata)--> vga_reader --> VGA
```

## Frame buffer sizes (8-bit unless noted)

| Frame | Bits | RAM blocks | Zen 4 (15) | Zen 8 (24) |
|---|---|---|---|---|
| 320x240 | 614,400 | 120 | no | no |
| 128x96 | 98,304 | 20 | no | yes |
| 160x120, 4-bit | 76,800 | 15 | whole chip | yes |
| 80x60 | 38,400 | 8 | yes | yes |

QVGA on the Zen 4 needs line streaming from the RP2350 (a few line buffers in the FPGA instead of a frame buffer).
