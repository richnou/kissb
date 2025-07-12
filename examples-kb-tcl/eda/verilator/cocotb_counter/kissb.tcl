package require kissb.eda.cocotb


@ sim {
    # Init Cocotb and select verilator
    cocotb.init 
    cocotb.simulator verilator

    # By Default, verilator will run using docker
    # Switch to a local installation 
    # You must have perl installed locally
    verilator.runtime.local
    verilator.verilate --version

    # Enable verilator coverage
    verilator.coverage.enable

    # Enable tracing
    cocotb.settings.trace


    # Set Verilog sources
    vars.set cocotb.sources counter.sv

    # Set the name of the python simulation module
    # if your testbench is located in "sim.py"
    cocotb.select.module sim 


    ## Run!
    cocotb.run

    ## Coverage output 
    verilator.coverage.toInfo coverage.dat coverage.info

    ## Generate reports
    > reports
}

@ reports {

    package require kissb.nodejs

    npx.run -y --package=@lcov-viewer/cli --  lcov-viewer lcov -o ./lcov-viewer-html ./coverage.info
    
    exec.withEnv [list PERL5LIB [list value /home/rleys/git/kissb/kb-tcl/native/lcov/builder/install/lib/lcov merge 1 ] PATH [list value /home/rleys/git/kissb/kb-tcl/native/lcov/builder/install/bin merge 1 ]] {
        exec.run genhtml coverage.info --flat -o lcov-html
    }
    
}
@ view {
    package require kissb.nodejs

    npx.run -y -- http-server ./lcov-html
    #npx.run -y -- http-server ./lcov-viewer-html
    
}
