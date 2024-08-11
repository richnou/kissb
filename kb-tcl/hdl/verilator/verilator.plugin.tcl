# SPDX-FileCopyrightText: 2024 KISSB 2024
#
# SPDX-License-Identifier: GPL-3.0-or-later

package provide kissb.verilator 1.0

namespace eval verilator {

    set runtime "docker"
    set version  "v5.024"
    
    kiss::toolchain::register kissb-verilator {
        set ::verilator::tcFolder $toolchainFolder/verilator-${verilator::version}
        files.require ${::verilator::tcFolder}/bin/verilator {
            files.inDirectory $toolchainFolder {
                files.download https://kissb.s3.de.io.cloud.ovh.net/hdl/verilator/verilator-${verilator::version}.zip
                files.extract verilator-${verilator::version}.zip
                files.delete verilator-${verilator::version}.zip
            }
        }
    }

    kissb.extension verilator {
        
        init args {
            verilator.runtime.kissb
        }
        root path {
            assert.isFile $path/bin/verilator "Verilator Root doesn't point to a valid root install, bin/verilator is missing"
            set verilator::runtime "local"
            vars.set verilator.root $path
            
        }

        runtime.docker args {
            set verilator::runtime "docker"
            package require kissb.docker
        }

        runtime.kissb args {
            set verilator::runtime "local"
            kiss::toolchain::init kissb-verilator
            verilator.root ${::verilator::tcFolder}
        }

        isDockerRuntime args {
            if {${verilator::runtime} == "docker"} {
                return true
            } else {
                return false
            }
        }

        run args {
            if {${verilator::runtime} == "docker"} {
                package require kissb.docker

                docker.run -ti -u [exec id -u]:[exec id -g] -e CCACHE_DIR=/work/.ccache -v [pwd]:/work verilator/verilator:${verilator::version} {*}$args
            } elseif {${verilator::runtime} == "local"} {
                if {[vars.get verilator.root false] == false } {
                    set exe "verilator"
                } else {
                    set exe [vars.get verilator.root]/bin/verilator
                }

                exec.run $exe {*}$args
                
            }
        }

        binary args {
            verilator.run --binary {*}$args
        }

        
        image.run script {
            docker.run.script verilator/verilator:${verilator::version} $script /work -e CCACHE_DIR=/work/.ccache
        }
    }

}