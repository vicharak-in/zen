#!/bin/bash
# mutate.sh - breaks the generated core in several small ways and checks that the comparison catches every one
cd "$(dirname "$0")"
run() {
  name="$1"; from="$2"; to="$3"
  sed "s/$from/$to/" ../runner_core.v > /tmp/mut_core.v
  if cmp -s ../runner_core.v /tmp/mut_core.v; then echo "NOT APPLIED: $name"; return; fi
  iverilog -g2005 -o /tmp/tb_mut tb_runner_core.v /tmp/mut_core.v && vvp /tmp/tb_mut > /tmp/mut.log
  if python3 check_runner.py /tmp/mut.log > /dev/null 2>&1; then echo "MISSED: $name"; else echo "caught: $name"; fi
}
# Equivalent mutant: enemies stand on the ground, so the feet can never be more than 10 pixels into one; a limit of 11 or 12 behaves the same
run "stomp depth 12 -> 11 (equivalent, expected MISSED)" "<= 9'd12);" "<= 9'd11);"
run "jump -12 -> -11" "JUMP    = -5'sd12" "JUMP    = -5'sd11"
run "run speed 3 -> 2" "RUN     = 2'd3" "RUN     = 2'd2"
run "bounce -6 -> -5" "BOUNCE  = -5'sd6" "BOUNCE  = -5'sd5"
run "pit at y>=192 -> y>=224" "y\[7\] \& y\[6\]" "y[7] \& y[6] \& y[5]"
run "coin points 50 -> 40" "24'd50" "24'd40"
run "enemy width 12 -> 11" "ex_i + 12'd12" "ex_i + 12'd11"
run "hero height 14 -> 13 in enemy test" "y + 9'd14 > e_y" "y + 9'd13 > e_y"
run "ceiling removed" "y == 8'd0 ||" ""
run "cut-off -4 -> -3" "CUT     = -5'sd4" "CUT     = -5'sd3"
run "enemy turn at hi" "ed\[ei\] <= 1'b1;" "ed[ei] <= 1'b0;"
run "right edge column +12 -> +11" "(x + 12'd12) >> 4" "(x + 12'd11) >> 4"
run "goal bonus" "24'd1000" "24'd900"
run "press needs ground removed" "(press \&\& ground)" "(press)"
run "lives 3 -> 2" "lives <= 2'd3" "lives <= 2'd2"
