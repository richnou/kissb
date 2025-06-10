

package require kissb.eda.verilator

verilator.init


vars.set netlist {counter_tb.sv counter.sv}

@ verilate {

    # Compile enabling timing and tracing, see counter_tb.sv to see timing usage
    verilator.verilate --binary --cc --timing -sv -CFLAGS -fcoroutines --trace-fst --trace {*}[vars.get netlist]
}

@ simulate : verilate {

    # Execute
    verilator.simulate Vcounter_tb
    #exec.run obj_dir/Vcounter_tb

}

@ lint {
    verilator.lint {*}[vars.get netlist] --timing -sv
}
