#!/bin/bash
# run-sim.sh - compile and run the picorv32-core testbenches with Icarus Verilog; exits non-zero unless the testbench passes
# Usage: bash sim/run-sim.sh            quick bring-up test (a few seconds)
#        bash sim/run-sim.sh selftest   full 9-test self-test over the UART (about 1 minute)
#        bash sim/run-sim.sh zink       the board top with the Zen Link: the RP2350 model reads the self-test report through real link frames (a few minutes)
set -e
# Go to the project root (the folder above this script) so the firmware paths inside the testbenches resolve
cd "$(dirname "$0")/.."
# Source files of the design, the register-file wrapper first so the core uses it
RTL="rtl/picorv32-regs-bram.v rtl/zen-picorv32-top.v rtl/picorv32.v"
# Choose the testbench from the first argument
if [ "$1" = "zink" ]; then
    # Zen Link testbench: the board top (two clocks), the bridge and the Zen Link in front of the unchanged CPU system
    iverilog -g2012 -Wall -Wno-timescale -Isim -o sim/sim.vvp sim/tb-picorv32-zink.v rtl/picorv32-zen4-top.v rtl/zink/zen-link.v rtl/zink/zl-slave.v rtl/zink/zl-regs.v rtl/zl-afifo.v rtl/zl-uart-bridge.v ${RTL}
elif [ "$1" = "selftest" ]; then
    # Self-test testbench: decodes the UART and expects "RESULT: ALL PASS"
    iverilog -g2012 -o sim/sim.vvp sim/tb-selftest.v ${RTL}
else
    # Basic bring-up testbench: small program, GPIO gets 0x42, no trap
    iverilog -g2012 -o sim/sim.vvp sim/tb-zen-picorv32-top.v ${RTL}
fi
# Run it and keep the log
vvp sim/sim.vvp | tee sim/sim.log
# Both testbenches print PASS on success
grep -q "PASS" sim/sim.log
# The Zen Link testbench must not report a failure either
! grep -q "FAIL" sim/sim.log
# Remove the build files
rm -f sim/sim.vvp sim/sim.log
