"""
run_sim.py - builds zink_alu_top with Icarus and runs the cocotb tests.

    cd examples/zink-alu/sim
    python run_sim.py            # run everything
    WAVES=1 python run_sim.py    # also dump waveforms for GTKWave
"""

import os
import sys
from pathlib import Path
from cocotb_tools.runner import get_runner, get_results

HERE = Path(__file__).resolve().parent
RTL = HERE.parent / "rtl"       # example sources
ZINK_RTL = RTL / "zink"         # link IP sources
BASE_SIM = HERE                 # test_zen_link.py (LinkMaster) sits next to this file


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
            HERE / "tb-zink-alu.v",
            RTL / "alu.v",
            RTL / "zink-alu-top.v",
            ZINK_RTL / "zl-slave.v",
            ZINK_RTL / "zl-regs.v",
            ZINK_RTL / "zen-link.v",
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
