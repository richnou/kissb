# SPDX-FileCopyrightText: 2024 KISSB
#
# SPDX-License-Identifier: Apache-2.0

package provide kiss.packages 1.0


namespace eval ::kiss::packages {


    set modulepaths {}

    set extrahandlers [dict create]

    kissb.extension kissb.packages {

        handler {name script} {
            dict set ::kiss::packages::extrahandlers $name $script
        }
    }

    ## Common Package resolution if a package is not found
    ##############
    proc ::kissb_search {name version} {
        log.info "Searching for Package $name"

        ## Load extra module paths
        #foreach mp ${::kiss::packages::modulepaths} {
        #    log.info "Loading index at $mp"
        #    if {[file exists $mp/pkgIndex.tcl]} {
        #        set dir $mp
        #        source $mp/pkgIndex.tcl
        #       set reloaded [catch {package require $name $version}]
        #    }
        #}

        if {[string match flow::* $name]} {

            set flowFile $::kissDir/flows/[string map {flow:: "" + _} $name].flow.tcl
            log.info "Searching for Flow in $flowFile"
            if {[file exists $flowFile]} {
                log.success "Found, providing"
                package provide $name $version
                source $flowFile
            }
        } elseif {[string match "git:*" $name]} {

            # Split at , to get parameters
            set gitAndParameters [split [string map {git: "" } $name] ,]
            set gitAddress [lindex $gitAndParameters 0]
            set gitProjectName [string map {.git ""} [lindex [split $gitAddress /] end]]

            log.info "Getting package from git $gitAddress into $gitProjectName - version=$version"
            set gitFolder ${::kissb.projectFolder}/.kb/git-packages
            set projectGitGolder $gitFolder/$gitProjectName

            package require kissb.git
            git.init

            files.require $projectGitGolder/.git {
                files.inDirectory $gitFolder {
                    git.clone $gitAddress $projectGitGolder
                }

            }
            files.inDirectory $projectGitGolder {
                foreach tclIndex [files.globFiles pkgIndex.tcl tcl/pkgIndex.tcl lib/pkgIndex.tcl src/pkgIndex.tcl] {
                    set dir [file normalize [file dirname $tclIndex]]
                    log.info "Loading GIT tcl index: $tclIndex"
                    source $tclIndex
                }
                package provide $name $version
            }


        } elseif {[dict exists $::kiss::packages::extrahandlers $name]} {
            # If a handler for the package name is provided, call it
            package provide $name $version
            eval [dict get $::kiss::packages::extrahandlers $name]

        }
    }
    package unknown ::kissb_search

    ## Scan a local package file and create a package ifneeded call for the defined package in the file
    proc loadLocalPackageFile f {

        set chan [open $f]
        try {
            while {[gets $chan line] >= 0} {
                #puts "[incr lineNumber]: $line"
                if {[string match "package*provide*" $line]} {
                    ## If we replace provide by ifneeded in the line, we are getting the required command to register the package
                    set preLine [split [string map {provide ifneeded} $line]]
                    {*}$preLine [list source [file normalize $f]]
                }
            }
        } finally {
            close $chan
        }



    }
}
