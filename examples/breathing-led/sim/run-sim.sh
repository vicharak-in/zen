#!/bin/bash
# run-sim.sh - compile and run the tb-breathing-led.v testbench with Icarus Verilog; exits non-zero unless ALL PASS is printed
set -e
cd "$(dirname "$0")"
iverilog -g2005-sv -Wall -Wno-timescale -o sim.vvp ../rtl/breathing-led.v ../rtl/breathing-led-zen4-top.v  tb-breathing-led.v
vvp sim.vvp | tee sim.log
grep -q "ALL PASS" sim.log
rm -f sim.vvp sim.log
