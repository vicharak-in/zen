#!/bin/bash
# run-sim.sh - compile and run the morse-blink testbenches with Icarus Verilog; exits non-zero unless every one prints ALL PASS
# The core testbench checks the unchanged core on its own; the Zink testbench drives real Zen Link frames into the board top.
set -e
cd "$(dirname "$0")"
# unchanged core on its own
iverilog -g2005-sv -Wall -Wno-timescale -I. -o sim.vvp ../rtl/morse-blink.v ../rtl/uart-rx.v tb-morse-blink-core.v
vvp sim.vvp | tee sim.log
grep -q "ALL PASS" sim.log
# board top driven by Zen Link frames (about 0.4 s of simulated time)
iverilog -g2005-sv -Wall -Wno-timescale -I. -o sim.vvp ../rtl/morse-blink-zen4-top.v ../rtl/morse-blink.v ../rtl/uart-rx.v ../rtl/zink/zen-link.v ../rtl/zink/zl-slave.v ../rtl/zink/zl-regs.v ../rtl/zl-afifo.v ../rtl/zl-uart-bridge.v tb-morse-blink-zink.v
vvp sim.vvp | tee sim.log
grep -q "ALL PASS" sim.log
rm -f sim.vvp sim.log
