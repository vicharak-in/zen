# Testing

Layers from cheapest to most real. Everything here runs from the repository root.

## 1. Self-checking firmware with an independent golden model

`firmware/riscv/src/selftest.c` runs on the core and compares results with values computed by `firmware/riscv/src/gen-golden.py`, a separate Python model of RV32I. The C compiler is not the reference, so a core bug cannot hide behind a matching compiler bug.

| Group | What it checks |
|---|---|
| alu | 19 operations (add, sub, and, or, xor, slt, sltu, sll, srl, sra and the immediate forms) over 8 edge pairs and 56 pseudo-random pairs; one folded checksum per operation |
| branch | beq, bne, blt, bge, bltu, bgeu, taken and not taken, on 7 operand pairs including sign-boundary cases |
| mem | lw, lb, lbu, lh, lhu, sb, sh, sign extension, neighbouring words untouched |
| flow | jal, jalr, lui, auipc, recursion (stack frames) |
| csr | csrrw, csrrs, csrrc, csrrwi on mscratch |
| trap | ecall, ebreak, misaligned load and store (mcause 11, 3, 4, 6), machine timer interrupt (mcause 0x80000007) |
| soft | software multiply and divide loops against Python (simulation image only) |
| perf | clocks per instruction from the hardware cycle counter (informational) |

`tb-soc.v` decodes the UART at 115200 baud, checks the `RESULT: ALL PASS` line and the LED register, and watches every RAM write: a write into code or constants, or a stack deeper than the 480 bytes reserved at link time, fails the run.

## 2. Configuration matrix

`bash sim/run-sim.sh full` rebuilds the firmware (needs a RISC-V compiler) and runs it on SERV and QERV, with and without the C extension, with the 4 KB images and the 16 KB `full` image, after the quick run. Uninitialised register-file RAM is left as X, so a program that reads a register it never wrote shows up as X instead of passing by luck.

`bash sim/run-sim.sh` (quick) runs the two shipped Zen 4 images on the SoC and the board top through the Zen Link; it needs no compiler. For the shipped images the build's end addresses are not available, so the stack-depth check of the testbench is switched off there (`STACK_RESERVE` set to the whole RAM); the full run keeps it.

## 3. Mutation test

`bash sim/mutation-test.sh` copies the core, breaks it on purpose (signed compare made unsigned; equality compare inverted) and requires the self-test to fail. It shows the checks react to real faults.

## 4. Board top through the Zen Link

`tb-serv-zink.v` drives the board top (`serv_zen4_top`) with the 50 MHz and 25 MHz clocks and a model of the RP2350 (`zink-host-model.vh`) that sends real Zen Link frames: it checks the link ID, polls the bridge's receive count, reads the report bytes through the burst window and passes when it has seen `RESULT: ALL PASS`, `led1` is lit (active low), `led2` is off and the bridge's overflow flags are clear.

## 5. Hardware

Run on the Zen 4 as described in the top-level README (the numbers below are from the earlier version with the UART line on an RP2350 pin). The perf numbers printed by the board match simulation exactly, because the logic is synchronous and the RAM acknowledges in one clock.

The report repeats on hardware, so firmware state must be reset at the start of every pass. Simulation halts after one pass and cannot see this; a simulation build with `-DNO_HALT -DREPEAT_CLKS=200000` repeats the report and was used to check the trap counters across several passes.

## Ideas not done yet

- **Differential fuzzing.** Generate random legal RV32I instruction streams, run them on the RTL and on a small Python instruction-set simulator, and compare every register write and store.
- **RISCOF architecture compliance.** SERV ships a RISCOF plugin (reference model: sail-riscv); `servile_mux` already supports `+signature=`.
- **Formal.** The core has an `RISCV_FORMAL` option for riscv-formal with SymbiYosys.
- **Post-synthesis simulation.** Run the testbench on the netlist Efinity writes (`write_efx_verilog`) to catch synthesis and RAM-inference differences.
- **Clock sweep.** Raise the PLL output until the self-test fails; Fmax from timing analysis is 33.5 MHz.
- **Interrupt stress.** Fire timer interrupts at random points of the ALU test and require unchanged results.
- **Reset soak.** Reset at random moments in simulation and require a clean restart each time.
