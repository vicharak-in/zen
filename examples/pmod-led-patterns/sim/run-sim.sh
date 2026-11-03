#!/bin/bash
# run-sim.sh - compile and run the tb-pmod-led-patterns.v testbench with Icarus Verilog; exits non-zero unless ALL PASS is printed
set -e
cd "$(dirname "$0")"
iverilog -g2005-sv -Wall -Wno-timescale -o sim.vvp ../rtl/pmod-led-patterns.v ../rtl/pmod-led-patterns-zen4-top.v  tb-pmod-led-patterns.v
vvp sim.vvp | tee sim.log
grep -q "ALL PASS" sim.log
rm -f sim.vvp sim.log
