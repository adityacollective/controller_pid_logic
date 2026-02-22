# tests/test_controller_pid_logic_hidden.py

from __future__ import annotations
import os
from pathlib import Path

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import Timer, RisingEdge
from cocotb.utils import get_sim_time
from cocotb_tools.runner import get_runner


EXPECTED = EXPECTED = EXPECTED = [
    (27, 120),   # 0000000001111000
    (33, 140),   # 0000000010001100
    (39, 180),   # 0000000010110100
    (45, 214),   # 0000000011010110
    (51, 253),   # 0000000011111101
    (57, 267),   # 0000000100001011
    (63, 301),   # 0000000100101101
    (69, 331),   # 0000000101001011
    (75, 343),   # 0000000101010111
    (81, 370),   # 0000000101110010
    (87, 382),   # 0000000101111110
    (93, 404),   # 0000000110010100
    (99, 424),   # 0000000110101000
    (105, 426),  # 0000000110101010
    (111, 443)   # 0000000110111011
]


@cocotb.test()
async def pid_tb_like(dut):


    dut.clk.value = 0
    dut.rst_n.value = 0
    dut.setpoint.value = 0
    dut.feedback.value = 0
    dut.Kp.value = 0
    dut.Ki.value = 0
    dut.Kd.value = 0
    dut.clk_prescaler.value = 0

    cocotb.start_soon(Clock(dut.clk, 1, unit="ns").start())

    async def monitor_and_check():
        idx = 0
        while True:
            await RisingEdge(dut.clk)

            t = int(get_sim_time(unit="ns"))
            cs = dut.control_signal.value
            fb = dut.feedback.value
            rst = dut.rst_n.value


            cocotb.log.info(
                f"t={t}ns control={str(cs)} fb={str(fb)} rst={str(rst)}"
            )

            if str(rst) == "1" and idx < len(EXPECTED):
                exp_time, exp_val = EXPECTED[idx]

                if t == exp_time:
                    got = int(cs)
                    assert got == exp_val, \
                        f"FAILED @ {t}ns : got={got} expected={exp_val}"
                    idx += 1

    cocotb.start_soon(monitor_and_check())


    dut.clk_prescaler.value = 5
    dut.setpoint.value = 20
    dut.Kp.value = 5
    dut.Ki.value = 2
    dut.Kd.value = 1


    await Timer(20, unit="ns")
    dut.rst_n.value = 1
    cocotb.log.info("RESET RELEASED")


    await Timer(20, unit="ns"); dut.feedback.value = 1
    await Timer(15, unit="ns"); dut.feedback.value = 5
    await Timer(15, unit="ns"); dut.feedback.value = 8
    await Timer(15, unit="ns"); dut.feedback.value = 10
    await Timer(15, unit="ns"); dut.feedback.value = 13
    await Timer(15, unit="ns"); dut.feedback.value = 15
    await Timer(15, unit="ns"); dut.feedback.value = 16
    await Timer(15, unit="ns"); dut.feedback.value = 25

    await Timer(25, unit="ns")
    cocotb.log.info("FINISH")



def test_controller_pid_logic_hidden_runner():
    sim = os.getenv("SIM", "icarus")
    #proj = Path(__file__).resolve().parent.parent
    proj_path = Path(__file__).resolve().parent.parent

    sources = [
        proj_path / "sources/top.sv",
        proj_path / "sources/pid_controller.sv",
    ]

    runner = get_runner(sim)
    runner.build(sources=sources, hdl_toplevel="top", always=True)
    runner.test(hdl_toplevel="top", test_module=Path(__file__).stem)
