# CocoTB

!!! note "Useful Links"
    - Homepage: https://www.cocotb.org/
    - Tutorial: https://docs.cocotb.org/en/stable/quickstart.html


Cocotb is a Python library that allows writing simulation testbenches for (System)Verilog and VHDL designs in python. It hooks to your simulator via the Standard VPI/DPI interfaces to read and write signals. Your testing logic can be written in Python.

The KISSB CoCotb Package installs cocotb using a python virtual environment, and will start the selected simulator directly. 

!!! warning 

    While Cocotb provides a Makefile based way to run simulations, the Kissb Package is running cocotb without these, by using Kissb style configuration.
    There might be some differences between Cocotb Makefiles and Kissb package way of starting simulators

## Quick Start

=== "kiss.build.tcl"

    ~~~~tcl

    package require kissb.cocotb

    # Init Cocotb and select verilator
    cocotb.init 
    cocotb.simulator verilator

    # By Default, verilator will run using docker
    # Switch to a local installation 
    # You must have perl installed locally
    verilator.runtime.kissb
    verilator.run --version

    # Enable tracing
    cocotb.settings.trace

    # Set Verilog sources
    vars.set cocotb.sources counter.sv

    # Set the name of the python simulation module
    # if your testbench is located in "sim.py"
    cocotb.select.module sim 


    ## Run!
    cocotb.run


    ~~~~

=== "counter.sv"

    ~~~~verilog 
    // That's a very bad counter to demonstrate cocotb
    module counter(input wire clk,output reg [3:0] value);

        initial begin
            value = 0;
        end

        always @(posedge clk) begin
            value <= value +1;
        end

    endmodule 

    ~~~~

Now run kissb: 

    $ kissb

You should get a verilator and cocotb output:

~~~~bash 
- V e r i l a t i o n   R e p o r t: Verilator 5.024 2024-04-05 rev v5.024
- Verilator: Built from 0.015 MB sources in 2 modules, into 0.036 MB in 11 C++ files needing 0.000 MB
- Verilator: Walltime 0.068 s (elab=0.008, cvt=0.031, bld=0.000); cpu 0.000 s on 1 threads; alloced 11.840 MB
[...]
INFO.cocotb Run args: --trace
     -.--ns INFO     gpi                                ..mbed/gpi_embed.cpp:108  in set_program_name_in_venv        Using Python virtual environment interpreter at /.../python
     -.--ns INFO     gpi                                ../gpi/GpiCommon.cpp:101  in gpi_print_registered_impl       VPI registered
     0.00ns INFO     cocotb                             Running on Verilator version 5.024 2024-04-05
     0.00ns INFO     cocotb                             Running tests with cocotb v1.9.0 from /.../.kb/build/python3-venv/lib/python3.10/site-packages/cocotb
     0.00ns INFO     cocotb                             Seeding Python random module with 1723485106
     0.00ns INFO     cocotb.regression                  pytest not found, install it to enable better AssertionError messages
     0.00ns INFO     cocotb.regression                  Found test sim.test_one
     0.00ns INFO     cocotb.regression                  running test_one (1/1)
100000.01ns INFO     cocotb.regression                  test_one passed
100000.01ns INFO     cocotb.regression                  **************************************************************************************
                                                        ** TEST                          STATUS  SIM TIME (ns)  REAL TIME (s)  RATIO (ns/s) **
                                                        **************************************************************************************
                                                        ** sim.test_one                   PASS      100000.01           0.73     137314.32  **
                                                        **************************************************************************************
                                                        ** TESTS=1 PASS=1 FAIL=0 SKIP=0             100000.01           0.73     136227.77  **
                                                        **************************************************************************************
~~~~

To refresh the cocotb installation and check for updates:

    $ kissb --refresh-cocotb

## Application Requirements

You can add any additional requirements to a local requirements.txt file. For example, add pytest