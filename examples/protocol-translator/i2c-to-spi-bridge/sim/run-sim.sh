#!/bin/bash
# run-sim.sh - compile and run the tb-i2c-to-spi-bridge.v testbench with Icarus Verilog; exits non-zero unless ALL PASS is printed
set -e
cd "$(dirname "$0")"
iverilog -g2005-sv -Wall -Wno-timescale -o sim.vvp ../rtl/bridge-controller-sync-fifo.v ../rtl/fifo-8x8.v ../rtl/i2c-slave.v ../rtl/spi-master.v ../rtl/i2c-to-spi-bridge.v ../rtl/i2c-to-spi-bridge-zen4-top.v  tb-i2c-to-spi-bridge.v
vvp sim.vvp | tee sim.log
grep -q "ALL PASS" sim.log
rm -f sim.vvp sim.log
