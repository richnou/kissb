import cocotb
from cocotb.triggers    import Timer,RisingEdge
from cocotb.clock       import Clock

@cocotb.test(timeout_time = 1 , timeout_unit = "ms")
async def test_one(dut):

    dut.enable = 0

    ## Clock and reset
    cocotb.start_soon(Clock(dut.clk, 10, units='ns').start())

    await Timer(100, units="us")
    dut.enable = 1
    await Timer(100, units="us")

    await Timer(100, units="us")
    pass

@cocotb.test(timeout_time = 1 , timeout_unit = "ms")
async def test_enable(dut):

    dut.enable = 0

    ## Clock and reset
    cocotb.start_soon(Clock(dut.clk, 10, units='ns').start())

    await Timer(100, units="us")
    dut.enable = 1
    await Timer(200, units="us")