#!/bin/bash
# run-sim.sh - compile and run the tb-ultrasonic-sensor.v testbench with Icarus Verilog; exits non-zero unless ALL PASS is printed
set -e
cd "$(dirname "$0")"
iverilog -g2005-sv -Wall -Wno-timescale -o sim.vvp ../rtl/ultrasonic-sensor.v ../rtl/ultrasonic-sensors.v ../rtl/ultrasonic-sensor-zen4-top.v  tb-ultrasonic-sensor.v
vvp sim.vvp | tee sim.log
grep -q "ALL PASS" sim.log
rm -f sim.vvp sim.log
