# SPDX-FileCopyrightText: 2024 KISSB
#
# SPDX-License-Identifier: Apache-2.0


lappend auto_path [file dirname [info script]]/../


## Load KISSB
package require kissb
log.info "TCL version: $tcl_version"

## Load Package folders
set possiblePackageFolders [list ${kissb.home}/pkgs/*/pkgIndex.tcl .kissb/pkgs/*/pkgIndex.tcl]

package require kissb.git
set gitRoot [git.root]
if {[file exists $gitRoot]} {
    lappend possiblePackageFolders $gitRoot/.kissb/pkgs/*/pkgIndex.tcl
}
foreach libFile [files.globFiles {*}${possiblePackageFolders} ] {

    log.fine "Found Package folder [file dirname $libFile]"
    set dir [file dirname $libFile]
    source $libFile
    #lappend auto_path [file dirname $libFile]
}





#log.info "Script: [info script]"

log.info "KISSB Version=${kissb.track}@${kissb.version}"
if {[file exists $gitRoot]} {
    log.info "Current GIT_ROOT=[git.root]"
}


set ::BASE [pwd]
set ::PWD [pwd]

## Process Arguments
##############

## Targets are arguments without "-" as starter
set targets {}
set args {}
set checkVersion false
set stopArgs false
foreach arg $argv {

    if {$stopArgs} {
        lappend args $arg
    } elseif {$arg == "--refresh"} {
        env KB_REFRESH 1
        env KB_REFRESH_ALL 1
    } elseif {[string match "--refresh-*" $arg]} {
        env KB_REFRESH_[string toupper [string map {--refresh- ""} $arg]] 1
    } elseif {$arg == "--force"} {
        env KB_FORCE 1
    } elseif {$arg == "--debug" || $arg == "-d"} {
        log.set.level DEBUG
    } elseif {$arg == "--update"} {
        set checkVersion true
    } elseif {$arg == "--"} {
        # -- means stopping argument processing, all remaining args are added to the args variable to be passed to the targets
        set stopArgs true
    } elseif {[string match -* $arg] || ([file exists $arg] && [llength $targets]>0)} {
        lappend args $arg
    } else {
        lappend targets $arg

        # If target starts with ".", command mode, catch all arguments as command Arguments
        if {[string range $arg 0 0]=="."} {
            set stopArgs true
        }
    }
}

## Run update check
if {$checkVersion} {
    package require kissb.internal.update
    kissb::internal::update::run

}



try {

## Load Lib and packages from well-known folders
foreach libFile [files.globFiles ${kissb.home}/lib/*.lib.tcl .kissb/*.lib.tcl *.lib.tcl ] {
    log.info "Loading lib file: $libFile"
    source $libFile
}

foreach packageFile [files.globFiles ${kissb.home}/lib/*.pkg.tcl .kissb/*.pkg.tcl *.pkg.tcl ] {
    log.info "Loading package file: $packageFile"
    ::kiss::packages::loadLocalPackageFile $packageFile
    #source $libFile
}

## Load local Kiss build
set foundLocalBuildFile false
foreach buildFile [files.globFiles build.tcl kissb.tcl kissb.*.tcl] {
    if {[file exists $buildFile]} {
        set foundLocalBuildFile true
        source $buildFile
        break
    }
}

set targetStack tcl
#if {!$foundLocalBuildFile} {
#    log.debug "No Local build file, trying to load stack"
#    if {[llength [glob -type f -nocomplain *.py ]]>0} {
#        log.success "Loading Python Stack"
#        package require kissb.python3
#        set targetStack python
#   }
#}
#source kiss.kb



## Run target
if {[llength $targets] == 0 && [llength $args] == 0 } {
    log.warn "No build target or command provided"
    foreach target [lsort [kiss::targets::listTargets]] {
        puts "- $target - [kiss::targets::getDoc $target]"
    }
} elseif {[llength $targets]>0} {

    ## Loop on target using index to allow some modes to edit the target list in case they should be interpreted as command
    #
    set ti 0
    while {$ti<[llength $targets]} {

        set target [lindex $targets $ti]
        incr ti


        log.debug "Running target $target"

        ## Run Target or command
        ###########
        if {[string range $target 0 0]=="."} {

            set cmd  [split [string range $target 1 end] " "]
            set bin  [lindex $cmd 0]
            set cmdArgs {}
            if {[llength $cmd]>1} {
                lappend cmdArgs {*}[lrange $cmd 1 end]
            }
            lappend cmdArgs {*}[lrange $targets 1 end]
            set targets {}

            log.info "Running command $cmd: bin=$bin, args=$cmdArgs $args"

            # Check that command exists, otherwise try to load convention named package
            if {[llength [info procs $cmd]]==0} {
                set package kissb.[lindex [split $cmd .] 0]
                log.debug "Loading package $package by convention to find command"
                catch {package require $package}
            }

            $bin {*}$cmdArgs {*}$args

        } elseif {[file exists $target] && ![file isdirectory $target]} {

            log.debug "Target is a file"

            # Provided Target is a file
            set fileext [file extension $target]
            if {$fileext==".tcl"} {
                source $target
            } elseif {$fileext==".py"} {
                package require kissb.python3
                python3.venv.init
                if {[file exists ../python]} {
                    log.warn "Adding folder ../python to python path"
                    exec.withEnv {PYTHONPATH {merge 1 value ../python/}} {
                        python3.venv.run.script $target {*}$args
                    }

                } else {
                    python3.venv.run.script $target {*}$args
                }
            }

        } elseif {[string range $target 0 0]!="-"} {

            # Run Target
            ::kiss::targets::run $target {*}$args

        }

    }

}



} on error {msg options} {

    #set stack [dict get $options -errorinfo]
    #puts "Caught error: $msg -> $stack"
    #puts "Stack: [info errorstack]"
    ::kiss::errors::prettyv1 $msg $options
}
