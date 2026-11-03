# webcam-sobel: laptop webcam -> Zen FPGA Sobel -> live window (max version)

```
webcam -> Python (gray W x H) -> USB serial -> RP2350 (UART bridge) -> FPGA Sobel -> RP2350 -> USB serial -> Python window
```

The FPGA does the filtering. The picture size is chosen per frame by Python (3 x 3 up to 640 x 480), so one bitstream
covers every size. Keys in the window: 1 = 80x60, 2 = 128x96, 3 = 160x120, 4 = 256x192, 5 = 320x240, 6 = 640x480, q = quit.
The window shows three panes: colour (laptop only), black & white (what is sent to the FPGA) and the FPGA Sobel result, plus fps, link speed and "diff vs numpy" (should be 0).

## Who does what

| Part | Job |
|---|---|
| Laptop CPU (OS, OpenCV) | Webcam capture, gray + resize, USB serial driver, window drawing, software Sobel for the check |
| `webcam_sobel.py` | Size choice, frame header, padding, send/receive threads, timeouts and resend, comparison, keys, fps |
| Zen MicroPython (RP2350) | Byte relay between USB and the FPGA UART (started by Python), no processing |
| Zen RTL (FPGA) | UART, header parsing, line buffer, 3x3 window, Sobel, border, flush, result FIFO, stall recovery |

## Frame format (host -> FPGA)

`0xA5`, width (2 bytes, low first), height (2 bytes), then width x height gray bytes (row by row). Python pads the
end with `0xFF` to a multiple of 128 bytes (the bridge block size); the FPGA ignores bytes between frames. Sizes outside
3..640 x 3..1023 are ignored. The result is width x height bytes; the 1-pixel border is 0.
Pixel value 3 is sent as 4 (3 is the Ctrl-C byte and would stop the RP2350 program).

## Files

| File | Job |
|---|---|
| `sobel_core.v` | Streaming 3x3 Sobel, line buffer for up to 640 pixels, runtime width/height |
| `sobel_uart_top.v` | UART in/out, header parsing, flush, result FIFO, drops a stalled frame (100 ms) |
| `sobel_zen_top.v` | Board top: reset, LEDs, instance (3.125 Mbaud, `CLKS_PER_BIT = 8`) |
| `uart_rx.v` | UART receiver (sample point centred for the high baud rate), `uart_tx.v` transmitter |
| `tb_sobel_uart.v` | Self-checking testbench (6 cases: sizes, padding, bad headers, stalled frame) |
| `sobel_zen.xml`, `sobel_zen.peri.xml`, `sobel_zen.sdc` | Efinity project, pads + PLL, timing |
| `webcam_sobel.py` | PC program |

## Simulate

```powershell
iverilog -g2005 -o sim uart_rx.v uart_tx.v sobel_core.v sobel_uart_top.v tb_sobel_uart.v
vvp sim
```

Expect six `ok` lines and `PASS` (also with `-Ptb_sobel_uart.CPB=12`).

## On the board

1. Build `sobel_zen.xml` in Efinity (the line buffer should map to RAM blocks, about 3 of 15; check timing at 25 MHz).
2. Load it (same as before):
   ```powershell
   python -m mpremote connect COM8 cp outflow\sobel_zen.hex.bin :
   python -m mpremote connect COM8 exec "src=open('main.py').read().replace('AES-Zen.hex.bin','sobel_zen.hex.bin'); exec(src)"
   ```
3. Close mpremote / Thonny, then `python webcam_sobel.py --port COM8`.

## Speed (estimates scaled from your 14.5 fps at 80x60 on the 921,600 baud build, not measured)

| Size | Bytes per frame | UART limit at 3.125 Mbaud |
|---|---|---|
| 160x120 | 19,200 | about 12 to 16 fps |
| 320x240 | 76,800 | about 3 to 4 fps |
| 640x480 | 307,200 | about 0.8 fps |

The window shows the real KB/s. If it stays near 70 to 100 KB/s whatever the baud rate, the MicroPython bridge or USB is the limit, not the UART.

## If the 3.125 Mbaud link is unreliable (garbage, many "no answer" frames)

Use 2.083 Mbaud: in `sobel_zen_top.v` change `.CLKS_PER_BIT(8)` to `12`, rebuild, and run Python with `--baud 2083333`.
For the original proven speed use `.CLKS_PER_BIT(27)` and `--baud 921600`.

## Not verified

Simulation (three baud settings) and a fake-board test of the Python side only. Efinity build, RP2350 at 3.125 Mbaud, the
bridge speed and real timing are untested on hardware.
