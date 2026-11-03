#!/bin/bash
# run-sim.sh - compile and run the tb-dspi-pio-echo.v testbench with Icarus Verilog; exits non-zero unless ALL PASS is printed
set -e
cd "$(dirname "$0")"
iverilog -g2005-sv -Wall -Wno-timescale -o sim.vvp ../rtl/dual-spi-target.v ../rtl/dspi-pio-echo.v ../rtl/dspi-pio-echo-zen4-top.v  tb-dspi-pio-echo.v
vvp sim.vvp | tee sim.log
grep -q "ALL PASS" sim.log
rm -f sim.vvp sim.log
