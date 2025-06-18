# SPDX-FileCopyrightText: 2024 KISSB
#
# SPDX-License-Identifier: Apache-2.0

package provide kissb.mkdocs 1.0
package require kissb.python3
package require zipfile::mkzip

namespace eval mkdocs {

    set pluginFolder [file dirname [file normalize [info script]]]
    set buildDir [file normalize ".kb/build/mkdocs"]

    proc buildFolder args {
        return $::mkdocs::buildDir/${::build.name}
    }

    ## Init Venv
    ## Install mkdocs
    kissb.extension mkdocs {
        init args {

            log.info "Initializing mkdocs..."

            ## Ensure venv
            set venvWasInit [python3.venv.init]

            ## Ensure mkdocs
            if {$venvWasInit || [refresh.is MKDOCS]} {
                lappend reqFiles $::mkdocs::pluginFolder/mkdocs.base.requirements
                if {[lsearch $args -material]!=-1} {
                    lappend reqFiles $::mkdocs::pluginFolder/mkdocs.material.requirements
                }
                if {[lsearch $args -kissv1]!=-1} {
                    lappend reqFiles $::mkdocs::pluginFolder/mkdocs.kissv1.requirements
                }
                if {[lsearch $args -kissv2]!=-1} {
                    lappend reqFiles $::mkdocs::pluginFolder/mkdocs.kissv2.requirements
                }
                if {[file exists [pwd]/requirements.txt]} {
                    lappend reqFiles [file normalize [pwd]/requirements.txt]
                }
                log.info "Mkdocs installing requirements: $reqFiles"
                python3.venv.install.requirements {*}$reqFiles
            }


            ## Ensure build directory
            file mkdir $::mkdocs::buildDir

        }

        build args {
            set htmlOutputFolder $::mkdocs::buildDir/${::build.name}

            python3.venv.run mkdocs --color build -c -d $htmlOutputFolder
            kissb.args.contains -zip {
                files.inDirectory $htmlOutputFolder {
                    cd ..
                    set htmlFolder [file tail $htmlOutputFolder]
                    log.success "Zipping $htmlFolder"
                    files.compress $htmlFolder ${::build.name}.zip

                }
            }
        }

        serve args {
            python3.venv.run mkdocs --color serve
        }

    }





}
