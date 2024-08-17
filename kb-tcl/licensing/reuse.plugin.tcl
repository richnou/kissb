# SPDX-FileCopyrightText: 2024 KISSB
#
# SPDX-License-Identifier: Apache-2.0

package provide kissb.reuse 1.0
package require kissb.python3


namespace eval reuse {


    kissb.extension reuse {

        init args {
            python3.venv.init

            python3.venv.withNotBinOrRefresh reuse REUSE {
                python3.venv.install.pip reuse
                python3.venv.install.requirements requirements.txt
            }
        }
        run args {
            python3.venv.run reuse {*}$args
        }

        download {licenses args} {
            foreach l $licenses {
                files.require LICENSES/${l}.txt {
                    python3.venv.run reuse download ${l}
                }
            }
            
            kissb.args.contains -github {
                log.info "Setting up LICENSE file for [lindex $licenses 0]"
                files.delete LICENSE
                reuse.run download -o LICENSE [lindex $licenses 0] 
            }
            
        }

        annotate args {
            python3.venv.run reuse annotate {*}$args
        }

        annotate.globs {globs args} {

            set files [files.globFiles {*}$globs ]
            reuse.annotate {*}$args {*}$files
        }

        lint args {
            python3.venv.run reuse lint
        }

    }

}