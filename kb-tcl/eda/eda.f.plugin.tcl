package provide kissb.eda.f 1.0
package require kissb
package require TclOO

namespace eval ::eda::f {

    kissb.extension eda.f {


        substitute f {

            set content [files.read $f]
            return [split [subst $content]]
        }

        resolve f {
            ## Parses a provided f file and resolve its content to an object providing list of source files or arguments like incdir , defines etc...
            ## If an argument line -f /path/to/another/f is encountered, the next f file is parsed as well
            return [::eda::f::resolveInternal $f]
        }

        parse f {
            ## Parses a provided f file and resolve its content to an object providing list of source files or arguments like incdir , defines etc...
            ## If an argument line -f /path/to/another/f is encountered, the next f file is parsed as well
            return [::eda::f::parseInternal $f]
        }

    }

    proc parseInternal {f {fDIct {}}} {

    }

    proc resolveInternal {f {currentObj ""}} {
        ## Resolve f file, internal method
        kissb.assert.isFile $f "F File $f not found"

    }


    ## F File Model
    ###########
    oo::class create FFile {


    }
}
