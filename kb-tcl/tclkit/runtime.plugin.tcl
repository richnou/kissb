package provide kissb.runtime 1.0


namespace eval kissb::runtime {


    kissb.extension runtime {


        create {name args} {

            package require kissb.tcl9.kit

            ## Call package runner
            set exe_path [zipfs mount //zipfs:/app]
            log.info "Building Runtime from: $exe_path,${::tcl9.kit.home}/packager_run.tcl"

            set pRunner [files.moveFileToTemp ${::tcl9.kit.home}/packager_run.tcl]

            set tclExe ${exe_path}
            set packagerArgs {}
            if {${::kissb.distribution}=="kit"} {
                lappend tclExe --nobuild
                lappend packagerArgs --kit
            }

            ## Run First TCLSH and if needed WISH to create a proper base distribution
            exec.run {*}$tclExe $pRunner --extract  --outdir .kb/dist {*}$packagerArgs

            foreach confFile [kissb.args.get --conf {}] {
                files.cp $confFile .kb/dist/kissb-${::kissb.version}
            }

            foreach packageFolder [kissb.args.get --packages {}] {

                files.cp $packageFolder .kb/dist/
            }

            exec.run {*}$tclExe $pRunner --continue --outdir .kb/dist  {*}$packagerArgs --name $name --main ${::kissb.mainScript}

        }

    }

}
