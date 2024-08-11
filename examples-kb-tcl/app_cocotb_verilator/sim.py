import cocotb
from cocotb.triggers    import Timer,RisingEdge
from cocotb.clock       import Clock

@cocotb.test(timeout_time = 1 , timeout_unit = "ms")
async def test_one(dut):
    ## Clock and reset
    cocotb.start_soon(Clock(dut.clk, 10, units='ns').start())
    
    await Timer(100, units="us")
    pass