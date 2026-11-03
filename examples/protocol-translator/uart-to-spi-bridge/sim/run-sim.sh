#!/bin/bash
# run-sim.sh - compile and run the tb-uart-to-spi-bridge.v testbench with Icarus Verilog; exits non-zero unless ALL PASS is printed
set -e
cd "$(dirname "$0")"
iverilog -g2005-sv -Wall -Wno-timescale -o sim.vvp ../rtl/bridge-controller.v ../rtl/fifo-8x8.v ../rtl/spi-master.v ../rtl/uart-rx.v ../rtl/uart-tx.v ../rtl/uart-tx-handler.v ../rtl/uart-to-spi-bridge.v ../rtl/uart-to-spi-bridge-zen4-top.v  tb-uart-to-spi-bridge.v
vvp sim.vvp | tee sim.log
grep -q "ALL PASS" sim.log
rm -f sim.vvp sim.log
