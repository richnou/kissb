
package require kissb.eda.verilator

kissb.args.contains --docker {
    verilator.init.docker 5.040
} else {
    verilator.init.local 5.040
}


#package require kissb.eda.verilator.docker 5.040



vars.set netlist {counter_tb.sv counter.sv}

@ verilate {

    # Compile enabling timing and tracing, see counter_tb.sv to see timing usage
    #verilator.verilate --binary --cc --timing -sv -CFLAGS -fcoroutines --trace-fst --trace {*}[vars.get netlist]
    verilator.verilate --binary  --trace  --trace-fst  {*}[vars.get netlist]
}

@ simulate : verilate {

    # Execute
    verilator.simulate Vcounter_tb


}

@ vrun {
    # Execute
    verilator.vrun counter_tb [list --binary  --trace  --trace-fst  {*}[vars.get netlist]] {}
}

@ lint {
    verilator.lint {*}[vars.get netlist] --timing -sv
}
