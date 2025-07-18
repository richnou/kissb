# SPDX-FileCopyrightText: 2024 KISSB
#
# SPDX-License-Identifier: Apache-2.0

package provide kissb.python3 1.0
package require kissb

#puts "Loading python3"

## This package assumes python3 is installed already
namespace eval python3 {

    set venvPath [file normalize ".kb/build/python3-venv"]

    vars.define python3.version   3
    vars.define python3.pythonExe python${::python3.version}

    ## Register a venv toolchain
    kiss::toolchain::register python3-venv {

        ## Clean
        refresh.withExact CLEAN {
            log.warn "Cleaning Python3 venv: ${::python3::venvPath}"
            files.delete ${::python3::venvPath}
        }

        ## Create venv folder
        file mkdir ${::python3::venvPath}

        ## Install venv
        if {![file exists ${::python3::venvPath}/pyvenv.cfg]} {
            kiss::terminal::execIn ${::python3::venvPath} ${::python3.pythonExe} -m venv .
            return true
        } else {
            return false
        }


    }

    proc ::python3.venv.init {{script {}}} {
        if {[kiss::ifRefresh] || [kiss::toolchain::init python3-venv]} {
            eval $script
        }
    }

    #####################
    ## Venv utils
    ###################

    ## install requirements
    proc ::python3.venv.require args {
        # write requirements
        kiss::files::writeText ${::python3::venvPath}/.tmp.requirements.txt [join $args \n]
        kiss::terminal::execIn ${::python3::venvPath} ./bin/pip install -r .tmp.requirements.txt

    }

    ## install requirements
    proc venv.requirements {files args} {
        foreach rFile [concat $files $args] {
            kiss::terminal::execIn ${::python3::venvPath} ./bin/pip install -r $rFile
        }
    }

    ## Returns true if an exe is in the bin folder
    proc venv.hasBin name {
        return [file exists ${::python3::venvPath}/bin/$name]
    }

    ## Runs a specific bin with arguments
    ## Run folder is the current folder!
    proc venv.runBin {bin args} {
        kiss::terminal::execIn [pwd] ${::python3::venvPath}/bin/$bin {*}$args
    }

    ## Runs a specific script
    ## Run folder is the current folder!
    proc ::python3.venv.run {script args} {
        ::python3::venv.runBin ${::python3.pythonExe} $script {*}$args
    }

    ################
    ## KISSB Extension
    ###################
    kissb.extension python3.venv {

        init args {

            ## Clean
            refresh.withExact CLEAN {
                log.warn "Cleaning Python3 venv: ${::python3::venvPath}"
                files.delete ${::python3::venvPath}
            }

            ## Create venv folder
            file mkdir ${::python3::venvPath}

            ## Install venv
            if {![file exists ${::python3::venvPath}/pyvenv.cfg]} {
                kiss::terminal::execIn ${::python3::venvPath} ${::python3.pythonExe} -m venv .
                set res true
            } else {
                log.info "Python3 venv present (${::python3::venvPath}/pyvenv.cfg)"
                set res false
            }

            ## run script
            if {$res==true || [refresh.is VENV] } {
                uplevel [list eval [lindex $args end]]
            }

            ## Install local folder Requirements if needed
            make ${::python3::venvPath}/kissb.requirements.timestamp < requirements.txt {
                python3.venv.install.requirements requirements.txt
                files.writeText ${::python3::venvPath}/kissb.requirements.timestamp DONE

            }

            return $res
        }

        hasBin name {
            return [file exists ${::python3::venvPath}/bin/$name]
        }

        withNotBinOrRefresh {bin key script} {
            if {[refresh.is $key] || ![python3.venv.hasBin $bin]} {
                uplevel [list eval $script]
            }
        }

        run {bin args} {
            exec.run ${::python3::venvPath}/bin/$bin {*}$args
        }

        call {bin args} {
            exec.call ${::python3::venvPath}/bin/$bin {*}$args
        }

        run.script {script args} {
            python3.venv.run python3 $script {*}$args
        }

        install.pip args {
            foreach p $args {
                python3.venv.run pip install $p
            }
        }

        install.requirements {files args} {
            foreach rFile [concat $files $args] {
                if {[file exists $rFile]} {
                    python3.venv.run pip install -r $rFile
                }

            }
        }
    }
}
