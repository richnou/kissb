package provide kissb.eda.ghdl 1.0


namespace eval ghdl {

    vars.define ghdl.runtime "kissb-llvm" -doc "Runtime selected, default is to download KISSB LLVM build (kissb-llvm)"
    vars.define ghdl.version "5.1.1"
    vars.define ghdl.installFolder false

    kiss::toolchain::register ghdl {

        switch ${::ghdl.runtime} {

            kissb-llvm {

                set outFolder $toolchainFolder/ghdl-${::ghdl.version}
                files.requireOrRefresh $outFolder/bin/ghdl ghdl {
                    files.inDirectory $toolchainFolder {
                        files.downloadOrRefresh https://kissb.s3.de.io.cloud.ovh.net/hdl/ghdl/ghdl-${::ghdl.version}-llvm-rhel9.zip GHDL
                        files.extract           ghdl-${::ghdl.version}-llvm-rhel9.zip
                    }
                }
                files.makeExecutable $outFolder/bin/ghdl
                files.makeExecutable $outFolder/bin/ghdl1-llvm
                vars.set ghdl.installFolder $outFolder
                env.set LD_LIBRARY_PATH $outFolder/bin
            }

            default {
                log.fatal "Unknown GHDL runtime ${::ghdl.runtime}"
            }
        }


    }

    kissb.extension ghdl {

        init.kissb-llvm  args {
             kiss::toolchain::init ghdl
        }

        init.system args {
            vars.set ghdl.runtime system
        }

        run args {

            switch ${::ghdl.runtime} {
                system {
                    exec.run ghdl {*}$args
                }
                kissb-llvm {
                    exec.run ${::ghdl.installFolder}/bin/ghdl {*}$args
                }

                default {
                    log.fatal "Unknown GHDL runtime ${::ghdl.runtime}"
                }
            }

        }

        analyze args {
            ghdl.run -a {*}$args
        }

        elaborate args {
            ghdl.run -e {*}$args
        }

        simulate args {
            ghdl.run -r {*}$args
        }

        vrun {top sources} {

        }
    }
}
