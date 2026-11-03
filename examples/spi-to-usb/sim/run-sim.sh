#!/bin/bash
# run-sim.sh - compile and run tb-spi-to-usb.v with Icarus Verilog; exits non-zero unless ALL PASS is printed
set -e
cd "$(dirname "$0")"
iverilog -g2005-sv -Wall -Wno-timescale -o sim.vvp ../rtl/zink/zen-link.v ../rtl/zink/zl-slave.v ../rtl/zink/zl-regs.v ../rtl/spi-target.v ../rtl/spi-to-usb.v ../rtl/zl-byte-port.v ../rtl/spi-to-usb-zen4-top.v  tb-spi-to-usb.v
vvp sim.vvp | tee sim.log
grep -q "ALL PASS" sim.log

rm -f sim.vvp sim.log
