---
tags:
  - HDL
  - Verilog
  - VHDL
  - Simulation
---
# Verilator

!!! note "Useful Links"
    - Homepage: <https://verilator.org/>
    - Documentation: <https://verilator.org/guide/latest>
    - ChangeLog: <https://verilator.org/guide/latest/changes.html>
    - Current default version: {{ verilator.version }}



## Initialisation

To use verilator, load the verilator package in your script, you can choose to use either a local binary provided by KISSB, or the docker image provided by verilator:

- To use the local version

    ~~~tcl
    package require kissb.eda.verilator
    verilator.init.local VERSION
    ~~~

    !!! warning
        Using verilator via local binary requires installing g++ and ccach on your host - the init command will check for their availability.

- To use the docker version

    ~~~tcl
    package require kissb.eda.verilator
    verilator.init.docker VERSION
    ~~~

To set the version, replace "vVERSION" by the desired version. For example 5.040 for version v5.040:

~~~tcl
package require kissb.eda.verilator

# For example:
verilator.init.local 5.040

# To use the official verilator docker image
verilator.init.docker 5.040
~~~

## Two Step verilator usage


### 1. Compilation

After initialisation, first you must compile your design using the verilator **verilate** command:

=== "kissb.tcl"

    ~~~tcl
    # For example to compile a counter design with a simple testbench
    verilator.verilate --binary counter.sv counter_tb.sv
    ~~~

=== "counter.sv"

    ~~~verilog
    // A very simple counter to demonstrate simulator usage
    module counter(
        input wire clk,
        input wire resn,
        output reg [3:0] value
    );

        always @(posedge clk) begin
            if (!resn) begin
                value <= 4'h0;
            end
            else begin
                value <= value + 4'd1;
            end

        end

    endmodule
    ~~~

=== "counter_tb.sv"

    ~~~verilog
    /**
    A very simple testbenck to demonstrate simulating the counter
    */
    module counter_tb;

        logic resn;
        logic clk;

        always begin
            #10ns clk <= ! clk;
        end

        initial begin
            $dumpfile("waves.fst");
            $dumpvars();
            resn = 0;
            clk = 0;
            @(posedge clk);
            @(posedge clk);
            resn=1;

            repeat(10) begin
                @(posedge clk);
            end

            #5000 $finish();
        end

        counter dut(
            .clk(clk),
            .resn(resn),
            .value()
        );
    endmodule
    ~~~


This command accepts the same arguments as the Verilator verilate command, see <https://verilator.org/guide/latest/verilating.html>

To enable waveform tracing, and add support for GtkWage fst file format, add the following arguments:

~~~tcl
# For example to compile a counter design with a simple testbench
verilator.verilate --binary --trace --trace-fst counter.sv counter_tb.sv
~~~

### 2. Running

After verilating, you can run your compiled design directly as executable, but best is to use the **verilator.simulate** command which
will execute the binary from your host or via the docker image depending on how you loaded the package.

~~~tcl
# Run
verilator.simulate Vcounter_tb
~~~

## Single Step Usage

To ease usage, users can use the **verilator.vrun** command, which will compile and run the design in one pass.


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


## Verilator Commands Reference

{%
    include-markdown "./verilator.methods.md"
    dedent=true
    heading-offset=1
%}
