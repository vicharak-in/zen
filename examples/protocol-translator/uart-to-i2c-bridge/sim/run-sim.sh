#!/bin/bash
# run-sim.sh - compile and run tb-uart-to-i2c-bridge.v with Icarus Verilog; exits non-zero unless ALL PASS is printed
set -e
cd "$(dirname "$0")"
iverilog -g2005-sv -Wall -Wno-timescale -o sim.vvp ../rtl/i2c-master-core.v ../rtl/uart-rx.v ../rtl/uart-tx.v ../rtl/uart-to-i2c-bridge.v ../rtl/uart-to-i2c-bridge-zen4-top.v  tb-uart-to-i2c-bridge.v
vvp sim.vvp | tee sim.log
grep -q "ALL PASS" sim.log

rm -f sim.vvp sim.log
