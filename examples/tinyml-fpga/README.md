# tinyml-fpga

An int8 neural-network (MLP) accelerator for the Vicharak Zen 4 (Trion T4F81). The RP2350 loads a model and an input through the Zen Link; the FPGA runs the network and returns the output. The engine is plain Verilog-2001 with one RAM wrapper, so it can be moved to other FPGAs.

```
tinyml-fpga/
├── rtl/                 tml-ram.v (only memory primitive), tml-engine.v (sequencer + MAC), tml-zink.v (Zink user bus), tml-zink-top.v (board top)
│   └── zink/            zen-link.v, zl-slave.v, zl-regs.v (the Zink core)
├── sim/                 tb-tinyml.v (self-checking testbench), run-sim.sh (regression), fake_fpga.py + test-driver.py (tests the RP runtime on the PC)
├── firmware/
│   ├── RP2350/          MicroPython for the board: tinyml_zink.py (runtime), sensor_tml.py, bmi323.py, digits-board.py, record-motions.py,
│   │                    and the model files model-demo.tml, model-digits.tml, model-sensor.tml, labels.txt, digits-test.bin
│   └── pc-tools/        PC side: tinyml_model.py (golden model, quantiser, packer, .tml writer), demo-mlp.py (train + compact),
│                        gen_vectors.py (test vectors), train_digits.py, train-sensor.py, sensor-data.csv
├── tinyml-fpga.xml       Efinity project (T4F81, top = tml_zink_top)
├── tinyml-fpga.peri.xml  pins and PLL (same as the other Zink examples)
├── sdc/                 tinyml-fpga.sdc
├── bitstream/           tinyml-fpga.hex.bin (loads with the board loader)
└── README.md
```

Python modules that other scripts import keep underscores in their file names (`tinyml_model.py`, `tinyml_zink.py`, `gen_vectors.py`, `train_digits.py`, `sensor_tml.py`, `bmi323.py`, `fake_fpga.py`), because a hyphen cannot appear in an `import` name.

## What it computes

Per layer, in integers (the Python model is bit-exact with the RTL):

```
acc[o] = bias[o] + sum_i weight[o][i] * x[i]                      int8 x int8 -> int32
y[o]   = saturate_int8( relu?( (acc[o] + (1 << (shift-1))) >> shift ) )
```

One MAC per clock at 50 MHz. A layer takes `5 + out * (in + 9) + 1` clocks, plus 4 clocks per run to drain the requantisation pipeline; the demo network (8 -> 16 -> 3) takes 363 clocks = 7.3 us.

## Register map (Zink user bus)

| Address | Name | Notes |
|---|---|---|
| 0x0100 | CMD (W) | 1 = run. Any other value only clears the error flag |
| 0x0101 | STATUS (R) | bit0 busy, bit1 done, bit2 error (also mirrored on STAT0 = 0x20) |
| 0x0102 | NLAYERS (RW) | 1..16 |
| 0x0103 | CONFIG (R) | `{W_AW, 1}`, 0xC1 for the default build |
| 0x0104..07 | CYCLES (R) | clocks of the last run, byte 0 first |
| 0x0200..3F | LAYER TABLE | 4 bytes per layer: in_dim, out_dim, shift, flags (bit0 = ReLU) |
| 0x0600..FF | INPUT | int8 vector, up to 255 values |
| 0x0700..FF | OUTPUT (R) | int8 result vector |
| 0x2000.. | WEIGHTS | 4 KB default; int8, one run of in_dim bytes per output neuron, neurons and layers back to back |
| 0x4000.. | BIASES | 1 KB default; int32 little endian, one per output neuron |

Memory windows are write-protected while running (the write is dropped and the error flag is set). The input buffer is never overwritten by the engine, so a run can be repeated without reloading it.

## Limits of the default build

Up to 16 layers, 255 inputs or outputs per layer, 4096 weights, 256 neurons in total. Raise `W_AW` (max 13) in `tml-zink-top.v` for more weights.

## Simulate

```
./sim/run-sim.sh          # 30 random networks + 2 saturation edge cases (needs iverilog and python3)
python3 firmware/pc-tools/demo-mlp.py && (cd sim/build/demo && vvp ../tb.vvp)     # the trained demo network in RTL
```

The testbench checks read-back, the output against the golden model, the cycle count against the formula, write-while-running protection, re-runs, and the zero-layer error.

`python3 sim/test-driver.py` tests the RP2350 runtime (`tinyml_zink.py`) on the PC against a fake `fpga` module: file parsing, loading, read-back, inference, float-input quantization and the stored self-test.

## Who does what

Same split as any TinyML flow: the PC trains and compacts once, the MCU deploys and runs.

| Where | Step |
|---|---|
| PC | Train the float model, quantize to int8, pick the shifts, pack everything into one `.tml` file (`demo-mlp.py`, `tinyml_model.py`) |
| RP2350 | Read the `.tml` from flash, load it into the FPGA, quantize live sensor values, start the run, read the result, argmax (`tinyml_zink.py`) |
| FPGA | The int8 network itself (`rtl/`) |

## Build and run on the Zen 4

1. Open `tinyml-fpga.xml` in Efinity, synthesize, place and route, generate the bitstream, load it on the board.
2. `mpremote cp firmware/RP2350/tinyml_zink.py firmware/RP2350/model-demo.tml :`
3. `mpremote exec "import tinyml_zink; tinyml_zink.demo()"`

Your own program on the RP:
```python
import tinyml_zink as tml
tml.start()
tml.load("model-demo.tml")
best, scores = tml.predict(features)    # float features in, class index and int8 scores out
```

## Status

Verified in simulation, and the whole flow was tested on a Zen 4 (it works). Built in Efinity 2026.1 for the T4F81: 1,008 / 3,888 logic elements (26%), 757 LUT4, 467 flip-flops, 71 adders, 1 multiplier, 13 of 15 block RAMs; `clk` meets 50 MHz (maximum 52.4 MHz). The board test was run on an earlier build of this RTL; the bitstream in `bitstream/` is a rebuild of the same RTL that was not run again.

## Porting to another FPGA

Replace the body of `rtl/tml-ram.v` with the vendor RAM (same ports), and replace the Zink wrapper (`tml-zink.v` is the only file that knows the bus) with whatever bus the host uses. The engine and the Python tools do not change.
