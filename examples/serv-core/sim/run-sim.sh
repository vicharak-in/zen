#!/usr/bin/env bash
# Runs the serv-core simulations with Icarus Verilog and prints one TEST_PASS/TEST_FAIL (or ALL PASS) line per run.
# Usage: bash sim/run-sim.sh          quick: the two shipped Zen 4 images on the SoC, then the board top through the Zen Link (about 2 minutes, no RISC-V compiler needed)
#        bash sim/run-sim.sh full     also rebuilds the firmware and runs the whole SERV/QERV, C extension matrix (needs riscv64-unknown-elf-gcc, about 6 more minutes)
# Needs: iverilog (>= 11), python3. Run from anywhere; it changes into the project root.
set -u
cd "$(dirname "$0")/.."
mkdir -p sim/build
FAIL=0
# RTL of the SoC and the vendored SERV files it uses
SRC="rtl/servxzen-soc.v rtl/servxzen-uart-tx.v rtl/vendor/serv/servile/*.v rtl/vendor/serv/rtl/*.v rtl/vendor/serv/servant/*.v"
# Build log folder
B=sim/build

# Stack bytes the testbench allows (the linker script reserves 480). The stack-depth check needs the end addresses the firmware build writes, so for the shipped images
# (no compiler needed) it is switched off by setting this to the whole RAM; the "full" runs below keep the real limit.
SR=480

# Runs one SoC simulation: label, hex file, end file ("" = none), width, compressed, memsize, time limit in microseconds
sim() {
  local label=$1 hex=$2 end=$3 w=$4 c=$5 mem=$6 lim=$7
  iverilog -g2012 -DCCGM -P tb_soc.FIRMWARE=\"$hex\" -P tb_soc.ENDFILE=\"$end\" -P tb_soc.NAME=\"$label\" -P tb_soc.STACK_RESERVE=$SR \
    -P tb_soc.WIDTH=$w -P tb_soc.COMPRESSED=$c -P tb_soc.MEMSIZE=$mem -P tb_soc.LIMIT_US=$lim \
    -o $B/$label.vvp sim/tb-soc.v $SRC > $B/$label.cc.log 2>&1 || { echo "COMPILE_FAIL $label (see $B/$label.cc.log)"; FAIL=1; return; }
  vvp $B/$label.vvp > $B/$label.log 2>&1
  local line; line=$(grep -a "^TEST_" $B/$label.log | tail -1)
  echo "${line:-TEST_FAIL $label (no result line, see $B/$label.log)}"
  case "$line" in TEST_PASS*) ;; *) FAIL=1;; esac
}

# Writes an end file for a shipped image: nothing is checked against the code (0), the image ends after the last word of the hex file
endfile() { echo "0 $(( $(grep -c . $1) * 4 ))" > $2; }

# Board top: the RP2350 model reads the self-test report through real Zen Link frames (reports ALL PASS or SOME FAILED)
zink() {
  iverilog -g2012 -Wall -Wno-timescale -Isim -DCCGM -o $B/zink.vvp sim/tb-serv-zink.v rtl/serv-zen4-top.v rtl/zink/zen-link.v rtl/zink/zl-slave.v rtl/zink/zl-regs.v \
    rtl/zl-afifo.v rtl/zl-uart-bridge.v $SRC > $B/zink.cc.log 2>&1 || { echo "COMPILE_FAIL zink (see $B/zink.cc.log)"; FAIL=1; return; }
  vvp $B/zink.vvp > $B/zink.log 2>&1
  local line; line=$(grep -a "^ALL PASS\|^SOME FAILED\|^FAIL" $B/zink.log | tail -1)
  echo "${line:-FAIL zink (no result line, see $B/zink.log)}"
  case "$line" in "ALL PASS"*) ;; *) FAIL=1;; esac
}

echo "== simulation (shipped Zen 4 images)"
endfile firmware/riscv/selftest.hex $B/selftest.end
endfile firmware/riscv/trapperf.hex $B/trapperf.end
SR=4096
sim zen4_core firmware/riscv/selftest.hex $B/selftest.end 1 0 4096 200000
sim zen4_trap firmware/riscv/trapperf.hex $B/trapperf.end 1 0 4096 400000
SR=480
zink

if [ "${1:-}" = "full" ]; then
  FW=firmware/riscv/src/out
  # Builds one firmware image: name, march, memsize, extra compiler flags
  fw() { bash firmware/riscv/src/build.sh "$2" "$3" "$1" "$4" > $B/fw_$1.log 2>&1 || { echo "BUILD_FAIL $1 (see $B/fw_$1.log)"; FAIL=1; }; }
  echo "== firmware images"
  fw selftest   rv32i_zicsr  4096  ""
  fw trapperf   rv32i_zicsr  4096  "-DWITH_TRAP -DWITH_PERF"
  fw full       rv32i_zicsr  16384 "-DWITH_CORE -DWITH_TRAP -DWITH_SOFT -DWITH_PERF"
  fw selftest_c rv32ic_zicsr 4096  ""
  fw full_c     rv32ic_zicsr 16384 "-DWITH_CORE -DWITH_TRAP -DWITH_SOFT -DWITH_PERF"
  for i in selftest trapperf full selftest_c full_c; do [ -f $FW/$i.hex ] && echo "  $(grep -a "^built" $B/fw_$i.log)"; done
  echo "== simulation (rebuilt images, full matrix)"
  sim built_core  $FW/selftest.hex   $FW/selftest.end   1 0 4096  200000
  sim built_trap  $FW/trapperf.hex   $FW/trapperf.end   1 0 4096  400000
  sim full_w1     $FW/full.hex       $FW/full.end       1 0 16384 400000
  sim qerv_core   $FW/selftest.hex   $FW/selftest.end   4 0 4096  200000
  sim qerv_trap   $FW/trapperf.hex   $FW/trapperf.end   4 0 4096  400000
  sim qerv_full   $FW/full.hex       $FW/full.end       4 0 16384 400000
  sim rvc_core    $FW/selftest_c.hex $FW/selftest_c.end 1 1 4096  200000
  sim rvc_full    $FW/full_c.hex     $FW/full_c.end     1 1 16384 400000
  sim qerv_rvc    $FW/selftest_c.hex $FW/selftest_c.end 4 1 4096  200000
fi
[ $FAIL -eq 0 ] && echo "ALL PASS" || echo "SOME FAILED"
exit $FAIL
