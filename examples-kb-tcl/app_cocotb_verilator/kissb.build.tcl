package require kissb.cocotb

# Init Cocotb and select verilator
cocotb.init 
cocotb.simulator verilator

# By Default, verilator will run using docker
# Switch to a local installation 
# You must have perl installed locally
verilator.runtime.local
verilator.verilate --version

# Enable tracing
cocotb.settings.trace

# Set Verilog sources
vars.set cocotb.sources counter.sv

# Set the name of the python simulation module
# if your testbench is located in "sim.py"
cocotb.select.module sim 


## Run!
cocotb.run