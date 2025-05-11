package provide kissb.tcl9.kit 1.0
package require kissb
package require kissb.docker

namespace eval kissb::tcl9::kit {

    vars.set tcl9.kit.home    [files.getScriptDirectory]
    vars.set tcl9.kit.version 9.0.1

    kissb.extension tcl9.kit {


        ## This Method prepares a base kit, arguments used to add code to the package an startup app
        make args {

            log.info "Making TCL9 Kit"

            set outFile kit9

            set addITCL true

            #rleys/kissb-tclsh9-static-full:latest
            kissb.args.get -image rleys/kissb-tclsh9-static:[vars.resolve tcl9.kit.version] -> image

            ## Prepare Work
            files.inDirectory .kb/build/kit9 {
    
                ## Run TCL9 from image
                files.cp [vars.resolve tcl9.kit.home]/packager_run.tcl packager_run.tcl
                docker.image.run $image -env [list NAME [kissb.args.get -name tclkit9]] -workdirPath /app -imgArgs [list packager_run.tcl -name  [kissb.args.get -name tclkit9] ]
                files.cp *kit* ../../../
            }
            

        }

    }

}