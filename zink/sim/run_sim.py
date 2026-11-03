"""
run_sim.py - builds zen_link with Icarus and runs the cocotb tests.

Uses the cocotb Python Runner (works on Windows/WSL without a Makefile).
Two suites run, each with a combinational AND a registered (BRAM-style) user-RAM
read, since the user bus must tolerate both:

  test_zen_link    protocol/RTL tests with a behavioural RP2350 master model
  test_mcu_driver  the REAL mcu/bus.c driver (host build) driving the same RTL

    python run_sim.py            # run everything
    WAVES=1 python run_sim.py    # also dump waveforms for GTKWave
    SEED=7 python run_sim.py     # different random traffic
"""

import os
import subprocess
import sys
from pathlib import Path
from cocotb_tools.runner import get_runner, get_results

HERE = Path(__file__).resolve().parent
RTL = HERE.parent / "rtl"
MCU = HERE.parent / "mcu"


def build_host_driver():
    """Compile mcu/bus.c for the host (bus.h hooks redirected to Python through host_shim.c)."""
    out_dir = HERE / "sim_build"
    out_dir.mkdir(exist_ok=True)
    lib = out_dir / ("bus_host.dll" if sys.platform == "win32" else "libbus_host.so")
    cmd = ["gcc", "-shared", "-fPIC", "-O1", "-Wall", "-Wextra", "-DBUS_HOST_TEST",
           "-I", str(MCU), "-o", str(lib), str(MCU / "bus.c"), str(HERE / "host_shim.c")]
    subprocess.run(cmd, check=True)
    return lib


def main():
    """Build and run both suites for both user-RAM read styles."""
    waves = os.environ.get("WAVES", "0") == "1"
    os.environ["BUS_HOST_LIB"] = str(build_host_driver())
    failed = 0
    for ram_reg in (0, 1):
        runner = get_runner("icarus")
        build_dir = HERE / "sim_build" / f"ram_reg_{ram_reg}"
        runner.build(
            sources=[
                HERE / "tb_zen_link.v",
                RTL / "zl_slave.v",
                RTL / "zl_regs.v",
                RTL / "zen_link.v",
            ],
            hdl_toplevel="tb_zen_link",
            build_dir=build_dir,
            parameters={"RAM_REG": ram_reg},
            timescale=("1ns", "1ps"),
            always=True,
            waves=waves,
        )
        for module in ("test_zen_link", "test_mcu_driver"):
            results_xml = runner.test(
                hdl_toplevel="tb_zen_link",
                test_module=module,
                build_dir=build_dir,
                test_dir=HERE,
                results_xml=build_dir / f"results_{module}.xml",
                waves=waves,
            )
            num_tests, num_failed = get_results(results_xml)
            print(f"RAM_REG={ram_reg} {module}: {num_tests - num_failed}/{num_tests} passed")
            failed += num_failed
    raise SystemExit(1 if failed else 0)


if __name__ == "__main__":
    main()
