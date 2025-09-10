package provide kissb.eda.verible 1.0


namespace eval  eda::verible {




    vars.define verible.version v0.0-4023-gc1271a00
    vars.define verible.path ""

    kiss::toolchain::register verible {


        files.inDirectory $toolchainFolder {

            files.require  verible-${::verible.version}/bin/verible-verilog-lint {
                files.downloadOrRefresh https://github.com/chipsalliance/verible/releases/download/${::verible.version}/verible-${::verible.version}-linux-static-x86_64.tar.gz verible
                files.extract verible-${::verible.version}-linux-static-x86_64.tar.gz
            }
            vars.set verible.path $toolchainFolder/verible-${::verible.version}/bin/

        }


    }

    kissb.extension verible {

        init args {
            kiss::toolchain::init verible
        }

        lint args {
            exec.run ${::verible.path}/verible-verilog-lint {*}$args
        }
    }



    # Always init verible on package require
    verible.init
}
