#!/bin/bash
# run-sim.sh - compile and run the tb-stack-processor.v testbench with Icarus Verilog; exits non-zero unless ALL PASS is printed
set -e
cd "$(dirname "$0")"
iverilog -g2005-sv -Wall -Wno-timescale -o sim.vvp ../rtl/zink/zen-link.v ../rtl/zink/zl-slave.v ../rtl/zink/zl-regs.v ../rtl/lifo-bram.v ../rtl/stack-processor.v ../rtl/zl-byte-port.v ../rtl/stack-processor-zen4-top.v  tb-stack-processor.v
vvp sim.vvp | tee sim.log
grep -q "ALL PASS" sim.log
rm -f sim.vvp sim.log
