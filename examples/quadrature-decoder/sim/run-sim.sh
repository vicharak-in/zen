#!/bin/bash
# run-sim.sh - compile and run the quadrature-decoder testbenches with Icarus Verilog; exits non-zero unless every one prints ALL PASS
# The core testbench checks the unchanged core on its own; the Zink testbench drives real Zen Link frames into the board top.
set -e
cd "$(dirname "$0")"
# unchanged core on its own
iverilog -g2005-sv -Wall -Wno-timescale -I. -o sim.vvp ../rtl/quadrature-decoder-uart.v ../rtl/quadrature-decoder.v ../rtl/uart-packetizer.v ../rtl/uart-tx.v tb-quadrature-decoder-core.v
vvp sim.vvp | tee sim.log
grep -q "ALL PASS" sim.log
# board top driven by Zen Link frames
iverilog -g2005-sv -Wall -Wno-timescale -I. -o sim.vvp ../rtl/quadrature-decoder-zen4-top.v ../rtl/quadrature-decoder-uart.v ../rtl/quadrature-decoder.v ../rtl/uart-packetizer.v ../rtl/uart-tx.v ../rtl/zink/zen-link.v ../rtl/zink/zl-slave.v ../rtl/zink/zl-regs.v ../rtl/zl-afifo.v ../rtl/zl-uart-bridge.v tb-quadrature-decoder-zink.v
vvp sim.vvp | tee sim.log
grep -q "ALL PASS" sim.log
rm -f sim.vvp sim.log
