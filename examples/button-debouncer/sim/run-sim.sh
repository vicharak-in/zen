#!/bin/bash
# run-sim.sh - compile and run the tb-button-debouncer.v testbench with Icarus Verilog; exits non-zero unless ALL PASS is printed
set -e
cd "$(dirname "$0")"
iverilog -g2005-sv -Wall -Wno-timescale -o sim.vvp ../rtl/debouncer.v ../rtl/button-debouncer.v ../rtl/button-debouncer-zen4-top.v  tb-button-debouncer.v
vvp sim.vvp | tee sim.log
grep -q "ALL PASS" sim.log
rm -f sim.vvp sim.log
