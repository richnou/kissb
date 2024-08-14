---
tags:
  - HDL
  - Verilog
  - VHDL
  - Simulation
---
# Verilator

!!! note "Useful Links"
    - Homepage: https://verilator.org/
    - Documentation: https://verilator.org/guide/latest
    - Current default version: {{ verilator.version }}

!!! tip "Example Build"
    --


## Initialisation 
To use verilator, load the **kissb.verilator** package in your build file: 

~~~tcl 
package require kissb.verilator
~~~

Then you can init the toolchain:

~~~tcl 
verilator.init
~~~

The default runtime will be a pre-build binary downloaded to the toolchain folders.

## Compilation

After initialisation, you can call verilator using the **verilator.run** command:

~~~tcl 
# For example to compile
verilator.verilate --binary counter.sv
~~~

## Running 

To run a compiled model, you can directly execute the binary, or you can execute the binary from the docker image.
The **verilator.simulate** method will run through the correct path.

~~~tcl 
# Run
verilator.simulate Vcounter
~~~



## Pre-Build Binaries

{{ read_csv("./verilator_uploads.csv") }}