# SPDX-FileCopyrightText: 2024 KISSB
#
# SPDX-License-Identifier: Apache-2.0

package provide kissb.eda.verilator 1.0
package require kissb.eda.f

namespace eval verilator {

    #set runtime "local"
    #set version  "v5.030"

    vars.set verilator.runtime "local"
    vars.set verilator.version "v5.040"


    vars.set verilator.verilate.args {}
    vars.set verilator.lint.args {--no-decoration}


    kiss::toolchain::register kissb-verilator {

        set vVersion [vars.resolve verilator.version]

        if {${::verilator.runtime}=="local"} {
            set ::verilator::tcFolder $toolchainFolder/verilator-${vVersion}
            files.require ${::verilator::tcFolder}/bin/verilator {
                files.inDirectory $toolchainFolder {
                    files.download https://kissb.s3.de.io.cloud.ovh.net/hdl/verilator/verilator-${vVersion}.zip
                    files.extract verilator-${vVersion}.zip
                    files.delete verilator-${vVersion}.zip
                }
            }
            files.makeExecutable ${::verilator::tcFolder}/bin/verilator
            files.makeExecutable ${::verilator::tcFolder}/bin/verilator_bin
            verilator.root ${::verilator::tcFolder}

        }
    }

    kissb.extension verilator {


        init.local args {

            kissb.args.contains -version {
                vars.set verilator.version v[kissb.args.get -version ""]
            }

            set ::verilator.runtime "local"
            kiss::toolchain::init kissb-verilator

            ## Check for ccache and g++
            foreach tool {ccache g++ perl} {
                if {[catch {exec.call $tool --version}]} {
                    log.fatal "Cannot find $tool"
                }
            }

            ## Add to Path?
            kissb.args.contains -addToPath {
                env.add PATH ${::verilator.root}/bin :
            }
        }

        init.docker args {

            kissb.args.contains -version {
                vars.set verilator.version v[kissb.args.get -version ""]
            }

            set ::verilator.runtime docker
            package require kissb.builder.container

        }

        root path {
            assert.isFile $path/bin/verilator "Verilator Root doesn't point to a valid root install, bin/verilator is missing"
            set ::verilator.runtime local
            vars.set verilator.root $path
        }



        isDockerRuntime args {
            if {${::verilator.runtime} == "docker"} {
                return true
            } else {
                return false
            }
        }

        verilate args {

            if {${::verilator.runtime} == "docker"} {

                builder.container.run [list -ti -e CCACHE_DIR=/work/.ccache -v [pwd]:/work]:rw verilator/verilator:${::verilator.version} {*}[vars.resolve verilator.verilate.args] {*}$args

            } elseif {${::verilator.runtime} == "local"} {

                if {[vars.get verilator.root false] == false } {
                    set exe "verilator"
                } else {
                    set exe [vars.get verilator.root]/bin/verilator
                }

                exec.run $exe {*}$args {*}[vars.resolve verilator.verilate.args]

            }
        }


        simulate {name args} {
             # Run simulation from exe located in obj_dir

            set fullPath ./obj_dir/$name
            if {![file exists $fullPath]} {
                log.error "Cannot run verilated design $fullPath, file not found"
                return
            }

            if {${::verilator.runtime} == "docker"} {
                verilator.image.run {
                    cd /build
                    $fullPath $args
                }
            } elseif {${::verilator.runtime} == "local"} {

                exec.run $fullPath {*}$args
            }

        }

        vrun {top compileArgs simulateArgs} {

            log.info "==== Verilator Verilating ===="
            verilator.verilate {*}$compileArgs

            log.info "==== Verilator Simulating ===="
            verilator.simulate V$top {*}$simulateArgs
        }

        lint args {
            # Run linter
            verilator.verilate --lint-only {*}${::verilator.lint.args} {*}$args
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
