#!/usr/bin/env bash
# This script runs the upstream PicoRV32 test suite (rv32ui/um/mi + irq + mul/div) on the Zen 4 wrapper.
# Needs: iverilog, git, and a RISC-V toolchain (Ubuntu/WSL: sudo apt install iverilog gcc-riscv64-unknown-elf).
set -e

# This is the folder this script lives in, used to find the wrapper RTL.
HERE="$(cd "$(dirname "$0")" && pwd)"
# This is the wrapper register file under test.
WRAP="$HERE/../rtl/picorv32-regs-bram.v"
# This is the scratch folder where the upstream repo is cloned.
WORK="${TMPDIR:-/tmp}/picorv32_official"
# This is the toolchain prefix (riscv64 elf gcc can target rv32 with -march/-mabi).
TC=riscv64-unknown-elf-

# This clones the upstream repo once and reuses it afterwards.
[ -d "$WORK" ] || git clone --depth 1 https://github.com/YosysHQ/picorv32.git "$WORK"
cd "$WORK"

# This function builds the test firmware, simulates it, and prints the verdict line.
#   $1 = label, $2 = COMPRESSED_ISA (C or empty), $3 = extra iverilog flags
run () {
  # This removes old objects so the firmware is rebuilt for this ISA choice.
  rm -f firmware/*.o firmware/firmware.elf firmware/firmware.bin firmware/firmware.hex tests/*.o
  # This builds firmware.hex with the chosen compressed-ISA setting.
  make firmware/firmware.hex TOOLCHAIN_PREFIX=$TC COMPRESSED_ISA="$2" >/dev/null 2>&1
  # This compiles the upstream testbench together with the core (and the wrapper if asked).
  iverilog -o t.vvp $3 testbench.v picorv32.v
  # This runs the simulation and keeps only the verdict lines.
  echo "== $1"; vvp -N t.vvp | grep -E "ALL TESTS PASSED|ERROR|TRAP after"
}

# Stock flop-based register file as the reference.
run "stock regs, compressed"        C "-DCOMPRESSED_ISA"
# Block-RAM wrapper with compressed instructions (the Zen 4 configuration).
run "BRAM wrapper, compressed"      C "-DCOMPRESSED_ISA -DPICORV32_REGS=picorv32_regs_bram $WRAP"
# Block-RAM wrapper without compressed instructions.
run "BRAM wrapper, no compressed"   "" "-DPICORV32_REGS=picorv32_regs_bram $WRAP"
# Block-RAM wrapper with the single-port register-read variant.
run "BRAM wrapper, single-port"     C "-DSP_TEST -DCOMPRESSED_ISA -DPICORV32_REGS=picorv32_regs_bram $WRAP"
