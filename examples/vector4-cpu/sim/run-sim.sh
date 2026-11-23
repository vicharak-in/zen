#!/bin/bash
# run-sim.sh - compile and run the tb-vector4-cpu.v testbench with Icarus Verilog; exits non-zero unless ALL PASS is printed
set -e
cd "$(dirname "$0")"
iverilog -g2005-sv -Wall -Wno-timescale -o sim.vvp ../rtl/zink/zen-link.v ../rtl/zink/zl-slave.v ../rtl/zink/zl-regs.v ../rtl/cpu-core.v ../rtl/vector4-cpu.v ../rtl/zl-byte-port.v ../rtl/vector4-cpu-zen4-top.v  tb-vector4-cpu.v
vvp sim.vvp | tee sim.log
grep -q "ALL PASS" sim.log
rm -f sim.vvp sim.log
