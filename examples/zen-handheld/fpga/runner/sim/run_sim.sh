#!/bin/bash
# run_sim.sh - runs every FPGA test for the platformer (needs iverilog and python3)
# Usage: bash run_sim.sh      (from the runner/sim folder)
set -e
cd "$(dirname "$0")"
# The level ROM in runner_core.v is generated from the Python level, so regenerate it first
python3 gen_level.py runner_core.v.template ../runner_core.v
echo "== 1. platformer core against the Python model (20000 random events) =="
python3 gen_events.py
iverilog -g2005 -o /tmp/tb_runner_core tb_runner_core.v ../runner_core.v
vvp /tmp/tb_runner_core > runner.log
python3 check_runner.py runner.log
echo "== 2. timers, buttons, pauses and restart =="
iverilog -g2005 -o /tmp/tb_runner_game tb_runner_game.v ../runner_game.v ../runner_core.v
vvp /tmp/tb_runner_game | grep -E "FAIL|PASSED|FAILED"
echo "== 3. register map =="
iverilog -g2005 -o /tmp/tb_runner_regs tb_runner_regs.v ../runner_regs.v
vvp /tmp/tb_runner_regs | grep -E "FAIL|PASSED|FAILED"
echo "== 4. whole top compiles =="
iverilog -g2005 -Wall -o /tmp/runner_top ../runner_fpga_top.v ../runner_game.v ../runner_core.v ../runner_regs.v ../tetris_tick.v ../btn_debounce.v ../zen_link.v ../zl_slave.v ../zl_regs.v
echo "ok"
