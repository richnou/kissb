package provide kissb.critcl 1.0
package require critcl

namespace eval kissb.critcl {

    vars.define critcl.runtime "local" -doc "Use Local or Container to run critcl in a container with a proper compiling environment"


    kissb.extension critcl {

        assertCompiling args {

            if {[critcl::compiling]} {
                log.success "CRITCL compiler found"
            } else {
                log.error "CRITCL cannot compile"
            }
        }

        package {script} {
            package require critcl::app

            ::critcl::app::main [list -cache .kb/build/critcl -libdir .kissb/pkgs/ -pkg $script]

        }
    }

}
