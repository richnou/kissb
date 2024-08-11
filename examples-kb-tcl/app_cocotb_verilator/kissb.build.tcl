package require kissb.cocotb
package require kissb.verilator

cocotb.init

cocotb.simulator verilator

#verilator.root /home/rleys/git/promd/kissbuild/kb-tcl/hdl/verilator/builder/build/verilator-stable

verilator.run --version


cocotb.settings.trace
cocotb.settings.traceFile out


#vars.set cocotb.args.verilator
vars.set cocotb.sources counter.sv
#vars.set cocotb/verilator.compile.args --trace --trace-fst --trace-structs

env.set MODULE sim
#env.set COCOTB_LOG_LEVEL DEBUG
cocotb.run 