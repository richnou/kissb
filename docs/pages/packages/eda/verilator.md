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
package require kissb.eda.verilator
~~~

Then you can init the toolchain:

~~~tcl
verilator.init
~~~

The default runtime will be a pre-build binary downloaded to the toolchain folders.

## Specifying Verilator version

To quickly load the verilator runtime at a specific version, you can load the following package:

~~~tcl
# This package downloads a local binary version of verilator
package require kissb.eda.verilator.local VERSION

# For example:
package require kissb.eda.verilator.local 5.032

# To use the official verilator docker image
package require kissb.eda.verilator.docker 5.032
~~~

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


## Verilator Package Variables

Before or after Loading the flow, you can set configuration variables:

~~~tcl
package require kissb.eda.verilator

vars.set CONFIGURATION VALUE
~~~

{%
    include-markdown "./_verilator.vars.inc.md"
%}
