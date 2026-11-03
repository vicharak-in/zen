#!/bin/bash
# run-sim.sh - compile and run the tb-spi-to-uart-bridge.v testbench with Icarus Verilog; exits non-zero unless ALL PASS is printed
set -e
cd "$(dirname "$0")"
iverilog -g2005-sv -Wall -Wno-timescale -o sim.vvp ../rtl/fifo-8x8.v ../rtl/spi-slave.v ../rtl/uart-rx.v ../rtl/uart-tx.v ../rtl/spi-to-uart-bridge.v ../rtl/spi-to-uart-bridge-zen4-top.v  tb-spi-to-uart-bridge.v
vvp sim.vvp | tee sim.log
grep -q "ALL PASS" sim.log
rm -f sim.vvp sim.log
