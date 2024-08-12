# SPDX-FileCopyrightText: 2024 KISSB 2024
#
# SPDX-License-Identifier: GPL-3.0-or-later

package provide kissb.cocotb 1.0
package require kissb.python3

namespace eval cocotb {

    set simulator "-"
    set workdir .kb/work/cocotb

    kissb.extension cocotb {

        init args {
            python3.venv.init

            python3.venv.withNotBinOrRefresh cocotb-config COCOTB {
                python3.venv.install.pip cocotb pytest
                python3.venv.install.requirements requirements.txt
            }

            files.mkdir ${cocotb::workdir}
        }

        simulator name {

            switch $name {
                verilator {
                    set ::cocotb::simulator verilator
                    package require kissb.verilator
                }

                default {
                    log.error "Unknown simulator $verilator"
                }
            }
        }
        select.module name {
            env.set MODULE $name
        }
        settings.trace args {
            
            vars.append cocotb.compile.args --trace --trace-fst --trace-structs
            vars.append cocotb.args --trace
        }
        settings.traceFile name {
            vars.append cocotb.args --trace-file ${name}.fst
        }

        run args {

            log.withLogger cocotb {

                log.info "Sources: [vars.resolve cocotb/${::cocotb::simulator}.sources]"

                switch ${::cocotb::simulator} {
                    verilator {
                        
                        ## Compile
                        package require kissb.verilator 

                        
                        if {[verilator.isDockerRuntime]} {
                            set libDir [string map [list [pwd]/ "/work/"] [python3.venv.call cocotb-config --lib-dir]]
                            set shareDir [string map [list [pwd]/ "/work/"] [python3.venv.call cocotb-config --share]]
                        } else {
                            set libDir   [python3.venv.call cocotb-config --lib-dir]
                            set shareDir [python3.venv.call cocotb-config --share]
                        }
                        
                        
                        set compileArgs [concat [list --timescale 1ns/10ps] [vars.resolve cocotb/${::cocotb::simulator}.compile.args]]
                        log.info "Compilation extra args: $compileArgs "

                        set sources [vars.resolve cocotb/${::cocotb::simulator}.sources]
                        lappend sources $shareDir/lib/verilator/verilator.cpp
                        log.info "Sources: $sources"

                        #verilator.run -cc --exe -Mdir ${cocotb::workdir}  -DCOCOTB_SIM=1 --vpi --public-flat-rw --prefix Vtop -o Vtop -LDFLAGS "-Wl,-rpath,$libDir -L$libDir -lcocotbvpi_verilator" {*}$compileArgs {*}$sources
                        refresh.with BUILD {
                            log.warn "Build refresh requested, cleaning workdir"
                            files.delete ${cocotb::workdir}
                        }
                        verilator.run --cc --exe -Mdir ${cocotb::workdir}  -DCOCOTB_SIM=1 --vpi --public-flat-rw --prefix Vtop -o Vtop -LDFLAGS "-Wl,-rpath,$libDir -L$libDir -lcocotbvpi_verilator" {*}$compileArgs {*}$sources
                        
                        if {[verilator.isDockerRuntime]} {
                            verilator.image.run {
                                cd /work && CCACHE_DIR=${cocotb::workdir}/.ccache make -C ${cocotb::workdir}  -f Vtop.mk
                            }
                        } else {
                            exec.run make -C ${cocotb::workdir}  -f Vtop.mk 
                        }
                        

                        ## Run 
                        set runArgs [vars.resolve cocotb/${::cocotb::simulator}.args]
                        log.info "Run args: $runArgs"
                        #exec.withEnv [list LD_LIBRARY_PATH [list value [python3.venv.call cocotb-config --lib-dir] merge 1 ]] {
                            exec.run echo "source .kb/build/python3-venv/bin/activate && ${cocotb::workdir}/Vtop $runArgs " | /bin/bash 
                        #}
                        #verilator.image.run {
                        #    cd /work && source .kb/build/python3-venv/bin/activate && ${cocotb::workdir}/Vtop
                        #}
                        
                    }
                }
            }
        }
    }
}