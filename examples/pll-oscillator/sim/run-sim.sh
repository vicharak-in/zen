#!/bin/bash
# run-sim.sh - compile and run the tb-pll-counter.v testbench with Icarus Verilog; exits non-zero unless ALL PASS is printed
set -e
cd "$(dirname "$0")"
iverilog -g2005-sv -Wall -Wno-timescale -o sim.vvp ../rtl/pll-counter.v ../rtl/pll-oscillator-zen4-top.v  tb-pll-counter.v
vvp sim.vvp | tee sim.log
grep -q "ALL PASS" sim.log
rm -f sim.vvp sim.log
