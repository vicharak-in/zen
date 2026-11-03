#!/bin/bash
# run-sim.sh - regenerate the ROM and the vectors, then run every self-checking testbench for the Zen 4 and Zen 8 settings.
# Needs: iverilog (v11 or newer) and python3. Run it from anywhere: bash sim/run-sim.sh

# Stop at the first failing command
set -e
# Go to the sim folder (the folder this script lives in)
cd "$(dirname "$0")"
# Build folder for the compiled simulations
mkdir -p build

# Regenerate the S-box ROM (checks the S-box against FIPS-197 values while doing so)
python3 gen-sbox-rom.py
# Regenerate the test vectors (FIPS-197, NIST, random cases)
python3 gen-vectors.py

# Source files of the design
RTL="../rtl/aes-sbox-rom.v ../rtl/aes-core.v ../rtl/uart-rx.v ../rtl/uart-tx.v ../rtl/byte-fifo.v ../rtl/aes-top.v"
# Overall result, 0 = everything passed
FAIL=0

# Run one testbench: arguments are the testbench name, the S-box lanes, the MixColumns columns
run_tb () {
    # Name of the testbench module
    TB=$1
    # Lanes and columns of this configuration
    L=$2
    M=$3
    # Compile with the parameters overridden (the testbench file name is the module name with - instead of _)
    iverilog -g2012 -o build/${TB}_${L}_${M}.vvp -P ${TB}.LANES=${L} -P ${TB}.MCP=${M} ${TB//_/-}.v ${RTL}
    # Run it and keep the log
    vvp build/${TB}_${L}_${M}.vvp | tee build/${TB}_${L}_${M}.log | tail -n 2
    # Any FAIL in the log makes the whole run fail
    if grep -q "FAIL" build/${TB}_${L}_${M}.log; then FAIL=1; fi
}

# Zen 4 setting (1 lane, 1 column), Zen 8 setting (4 lanes, 4 columns) and two in-between settings
for CFG in "1 1" "4 4" "2 1" "4 1"; do
    echo "=== aes_core  LANES/MCP = ${CFG}"
    run_tb tb_aes_core ${CFG}
done
# The full UART engine is tested for the two real boards and one mixed setting
for CFG in "1 1" "4 4" "2 4"; do
    echo "=== aes_top   LANES/MCP = ${CFG}"
    run_tb tb_aes_top ${CFG}
done

# Zen 4 board top driven by Zen Link frames (link clock 50 MHz, engine clock 25 MHz)
echo "=== aes-zen4-top through the Zen Link"
iverilog -g2012 -Wall -Wno-timescale -I. -o build/tb_aes_zink.vvp tb-aes-zink.v ${RTL} ../rtl/zink/zen-link.v ../rtl/zink/zl-slave.v ../rtl/zink/zl-regs.v ../rtl/zl-afifo.v ../rtl/zl-uart-bridge.v ../rtl/aes-zen4-top.v
vvp build/tb_aes_zink.vvp | tee build/tb_aes_zink.log | tail -n 3
if grep -q "FAIL" build/tb_aes_zink.log || ! grep -q "ALL PASS" build/tb_aes_zink.log; then FAIL=1; fi

# Host tool against a Python model of the protocol (needs the cryptography package)
python3 test-host.py || FAIL=1

# Final verdict
if [ $FAIL -eq 0 ]; then echo "ALL TESTS PASSED"; else echo "SOME TESTS FAILED"; exit 1; fi
