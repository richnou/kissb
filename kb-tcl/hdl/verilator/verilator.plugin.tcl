# SPDX-FileCopyrightText: 2024 KISSB
#
# SPDX-License-Identifier: Apache-2.0

package provide kissb.verilator 1.0

namespace eval verilator {

    set runtime "local"
    set version  "v5.024"
    
    kiss::toolchain::register kissb-verilator {

        if {${verilator::runtime}=="local"} {
            set ::verilator::tcFolder $toolchainFolder/verilator-${verilator::version}
            files.require ${::verilator::tcFolder}/bin/verilator {
                files.inDirectory $toolchainFolder {
                    files.download https://kissb.s3.de.io.cloud.ovh.net/hdl/verilator/verilator-${verilator::version}.zip
                    files.extract verilator-${verilator::version}.zip
                    files.delete verilator-${verilator::version}.zip
                }
            }
            verilator.root ${::verilator::tcFolder}

        }

        
        
    }

    kissb.extension verilator {
        
        init args {
            kiss::toolchain::init kissb-verilator
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

        runtime.local args {
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

        verilate args {
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

        # Run simulation from exe located in obj_dir
        simulate {name args} {

            set fullPath ./obj_dir/$name
            if {![file exists $fullPath]} {
                log.error "Cannot run verilated design $fullPath, file not found"
                return
            }

            if {${verilator::runtime} == "docker"} {
                verilator.image.run {
                    cd /build
                    $fullPath $args
                }
            } elseif {${verilator::runtime} == "local"} {
                
                exec.run $fullPath {*}$args
            }
            
        }

        
        image.run script {
            docker.run.script verilator/verilator:${verilator::version} -e CCACHE_DIR=/work/.ccache $script 
        }
    }

}