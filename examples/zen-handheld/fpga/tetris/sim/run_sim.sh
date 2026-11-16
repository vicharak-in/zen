#!/bin/bash
# run_sim.sh - runs every FPGA test for Zen Tetris (needs iverilog and python3)
# Usage: bash run_sim.sh      (from the fpga/sim folder; takes about 40 seconds)
set -e
cd "$(dirname "$0")"
# The piece table in tetris_core.v is generated from the Python model, so regenerate it first
python3 gen_pieces.py tetris_core.v.template ../tetris_core.v
echo "== 1. game core against the Python model (12000 random events) =="
python3 gen_events.py
iverilog -g2005 -o /tmp/tb_core tb_core.v ../tetris_core.v
vvp /tmp/tb_core > core.log
python3 check_core.py core.log
echo "== 2. buttons, gravity and restart =="
iverilog -g2005 -o /tmp/tb_game tb_game.v ../tetris_tick.v ../tetris_buttons.v ../tetris_game.v ../tetris_core.v
vvp /tmp/tb_game | grep -E "FAIL|PASSED|FAILED"
echo "== 3. register map =="
iverilog -g2005 -o /tmp/tb_regs tb_regs.v ../tetris_regs.v
vvp /tmp/tb_regs | grep -E "FAIL|PASSED|FAILED"
echo "== 4. whole top compiles =="
iverilog -g2005 -Wall -o /tmp/top_chk ../tetris_fpga_top.v ../tetris_tick.v ../tetris_buttons.v ../tetris_game.v ../tetris_core.v ../tetris_regs.v ../btn_debounce.v ../zen_link.v ../zl_slave.v ../zl_regs.v
echo "ok"
