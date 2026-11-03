"""
run_sim.py - builds zink_alu_top with Icarus and runs the cocotb tests.

    cd examples/zink_alu/sim
    python run_sim.py            # run everything
    WAVES=1 python run_sim.py    # also dump waveforms for GTKWave
"""

import os
import sys
from pathlib import Path
from cocotb_tools.runner import get_runner, get_results

HERE = Path(__file__).resolve().parent
ZINK = HERE.parents[2]          # zink/ root
RTL = ZINK / "rtl"              # link IP sources
BASE_SIM = ZINK / "sim"         # base testbench helpers (LinkMaster)


def main():
    """Build and run the ALU suite."""
    waves = os.environ.get("WAVES", "0") == "1"
    # Lets test_zink_alu.py import LinkMaster from the base testbench.
    os.environ["PYTHONPATH"] = os.pathsep.join([str(BASE_SIM), os.environ.get("PYTHONPATH", "")])
    sys.path.insert(0, str(BASE_SIM))
    runner = get_runner("icarus")
    build_dir = HERE / "sim_build"
    runner.build(
        sources=[
            HERE / "tb_zink_alu.v",
            HERE.parent / "rtl" / "alu.v",
            HERE.parent / "rtl" / "zink_alu_top.v",
            RTL / "zl_slave.v",
            RTL / "zl_regs.v",
            RTL / "zen_link.v",
        ],
        hdl_toplevel="tb_zink_alu",
        build_dir=build_dir,
        timescale=("1ns", "1ps"),
        always=True,
        waves=waves,
    )
    results_xml = runner.test(
        hdl_toplevel="tb_zink_alu",
        test_module="test_zink_alu",
        build_dir=build_dir,
        test_dir=HERE,
        results_xml=build_dir / "results.xml",
        waves=waves,
    )
    num_tests, num_failed = get_results(results_xml)
    print(f"zink_alu: {num_tests - num_failed}/{num_tests} passed")
    raise SystemExit(1 if num_failed else 0)


if __name__ == "__main__":
    main()
