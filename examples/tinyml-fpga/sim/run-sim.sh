#!/bin/bash
# run-sim.sh - compile the RTL once, then run the testbench on many random networks (seeds 1..N) plus the saturation edge cases.
#   ./sim/run-sim.sh        30 random networks + 2 edge cases
#   ./sim/run-sim.sh 100    100 random networks + 2 edge cases
# Needs iverilog (Icarus Verilog) and python3. Build products go to sim/build, which can be deleted at any time.
set -e
cd "$(dirname "$0")"
mkdir -p build
iverilog -g2005 -Wall -o build/tb.vvp tb-tinyml.v ../rtl/tml-ram.v ../rtl/tml-engine.v ../rtl/tml-zink.v
N=${1:-30}
pass=0
fail=0
for c in $(seq 1 "$N") edge1 edge2; do
    d="build/case_$c"
    mkdir -p "$d"
    case "$c" in
        edge1) python3 ../firmware/pc-tools/gen_vectors.py --edge 1 --out "$d" > "$d/gen.txt" ;;
        edge2) python3 ../firmware/pc-tools/gen_vectors.py --edge 2 --out "$d" > "$d/gen.txt" ;;
        *)     python3 ../firmware/pc-tools/gen_vectors.py --seed "$c" --out "$d" > "$d/gen.txt" ;;
    esac
    (cd "$d" && vvp ../tb.vvp > log.txt)
    if grep -q "^PASS" "$d/log.txt"; then
        pass=$((pass + 1))
    else
        fail=$((fail + 1))
        echo "case $c FAILED:"
        head -5 "$d/log.txt"
    fi
done
echo "RESULT: $pass passed, $fail failed"
[ "$fail" -eq 0 ]
