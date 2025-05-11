# SPDX-FileCopyrightText: 2024 KISSB
#
# SPDX-License-Identifier: Apache-2.0

package provide kissb.eda.verilator 1.0
package require kissb.eda.f 

namespace eval verilator {

    set runtime "local"
    set version  "v5.024"

    vars.set verilator.version "v5.024"

    vars.set verilator.verilate.args {}

    kissb.packages.handler kissb.eda.verilator.local {

        log.info "Setting Local Verilator to version $version"
        if {![string match v* $version]} {
            set version v$version
        }
        vars.set verilator.version $version
        verilator.runtime.local

    }
    
    kissb.packages.handler kissb.eda.verilator.docker {

        log.info "Setting Docker Verilator to version $version"
        if {![string match v* $version]} {
            set version v$version
        }
        vars.set verilator.version $version
        verilator.runtime.docker

    }
    
    kiss::toolchain::register kissb-verilator {

        set vVersion [vars.resolve verilator.version]

        if {${verilator::runtime}=="local"} {
            set ::verilator::tcFolder $toolchainFolder/verilator-${vVersion}
            files.require ${::verilator::tcFolder}/bin/verilator {
                files.inDirectory $toolchainFolder {
                    files.download https://kissb.s3.de.io.cloud.ovh.net/hdl/verilator/verilator-${vVersion}.zip
                    files.extract verilator-${vVersion}.zip
                    files.delete verilator-${vVersion}.zip
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

                exec.run $exe {*}$args {*}[vars.resolve verilator.verilate.args]
                
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

        lint args {
            #-f $fFile
            verilator.verilate {*}$args  --lint-only --no-decoration 
        }

        coverage.enable args {
            vars.append verilator.verilate.args --coverage
        }

        coverage.toInfo {coverageDat coverageInfo} {
            exec.run [vars.get verilator.root]/bin/verilator_coverage $coverageDat --write-info $coverageInfo
        }
        
        image.run script {
            docker.run.script verilator/verilator:${verilator::version} -e CCACHE_DIR=/work/.ccache $script 
        }
    }

}