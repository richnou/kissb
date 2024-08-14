# SPDX-FileCopyrightText: 2024 KISSB 2024
#
# SPDX-License-Identifier: GPL-3.0-or-later

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

        download {licenses args} {
            foreach l $licenses {
                files.require LICENSES/${l}.txt {
                    python3.venv.run reuse download ${l} {*}$args
                }
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