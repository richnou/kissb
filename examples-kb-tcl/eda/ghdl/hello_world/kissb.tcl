package require kissb.eda.ghdl


ghdl.init.kissb-llvm

files.inDirectory ${::kissb.buildDir} {

    ghdl.analyze   ${::kissb.projectFolder}/hello_world.vhdl
    ghdl.elaborate hello_world
    ghdl.simulate  hello_world
}
