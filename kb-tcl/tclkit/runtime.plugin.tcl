package provide kissb.runtime 1.0


namespace eval kissb::runtime {


    kissb.extension kissb.runtime {


        sf.create {name args} {

            package require kissb.tcl9.kit

            ## Call package runner
            set exe_path [zipfs mount //zipfs:/app]
            log.info "Building Runtime from: $exe_path,${::tcl9.kit.home}/packager_run.tcl"

            set pRunner [files.moveFileToTemp ${::tcl9.kit.home}/packager_run.tcl]

            exec.run $exe_path --nobuild $pRunner --extract  --outdir .kb/dist --kit

            foreach confFile [kissb.args.get --conf {}] {
                files.cp $confFile .kb/dist/kissb-${::kissb.version}
            }

            foreach packageFolder [kissb.args.get --package {}] {
            
                files.cp $packageFolder .kb/dist/
            }

            exec.run $exe_path --nobuild $pRunner --continue --outdir .kb/dist  --kit --name $name --main ${::kissb.mainScript}

        }

    }

}
