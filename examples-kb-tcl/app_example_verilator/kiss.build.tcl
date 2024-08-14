

package require kissb.verilator 

verilator.init 

# Compile enabling timing and tracing, see counter_tb.sv to see timing usage
verilator.verilate --binary --cc --timing -sv -CFLAGS -fcoroutines --trace-fst --trace counter_tb.sv counter.sv

# Execute
verilator.simulate Vcounter_tb
#exec.run obj_dir/Vcounter_tb