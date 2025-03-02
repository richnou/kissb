package provide kissb.eda.f 1.0
package require kissb

namespace eval eda::f {

    kissb.extension eda.f {


        substitute f {

            set content [files.read $f]
            return [split [subst $content]]
        }

    }

}