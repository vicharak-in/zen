#!/bin/bash
# run-sim.sh - compile and run the tb-cordic.v testbench with Icarus Verilog; exits non-zero unless ALL PASS is printed
set -e
cd "$(dirname "$0")"
iverilog -g2005-sv -Wall -Wno-timescale -o sim.vvp ../rtl/zink/zen-link.v ../rtl/zink/zl-slave.v ../rtl/zink/zl-regs.v ../rtl/cordic-circular.v ../rtl/cordic-multiply.v ../rtl/cordic-divide.v ../rtl/cordic.v ../rtl/zl-byte-port.v ../rtl/cordic-zen4-top.v  tb-cordic.v
vvp sim.vvp | tee sim.log
grep -q "ALL PASS" sim.log
rm -f sim.vvp sim.log
