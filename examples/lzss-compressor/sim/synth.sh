#!/usr/bin/env bash
# This script synthesizes the hardware compressor with Yosys for a generic 4-input-LUT FPGA (iCE40 flow: LUT4, carry, block RAM) and prints the resource report.
# Needs yosys (or: pip install yowasp-yosys, which provides yowasp-yosys). Run from anywhere:  bash sim/synth.sh [top]
cd "$(dirname "$0")"
TOP=${1:-lzss_hw_top}
Y=$(command -v yosys || command -v yowasp-yosys)
$Y -q -l synth_${TOP}.log -p "read_verilog ../rtl/uart-rx.v ../rtl/uart-tx.v ../rtl/lzss-core.v ../rtl/rx-fifo.v ../rtl/lzss-hw-top.v; synth_ice40 -top $TOP; stat" >/dev/null
sed -n '/Printing statistics/,$p' synth_${TOP}.log | grep -v "^$"
