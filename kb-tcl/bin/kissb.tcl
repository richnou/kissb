lappend auto_path [file dirname [info script]]/../
#lappend auto_path .kissb/pkgs/mylib

## Load KISSB
package require kissb

## Load Package folders
set possiblePackageFolders [list ${kissb.home}/pkgs/*/pkgIndex.tcl .kissb/pkgs/*/pkgIndex.tcl]

package require kissb.git
set gitRoot [git.root]
if {[file exists $gitRoot]} {
    lappend possiblePackageFolders $gitRoot/.kissb/pkgs/*/pkgIndex.tcl
}
foreach libFile [files.globFiles {*}${possiblePackageFolders} ] {
    
    log.info "Found Package folder [file dirname $libFile]"
    set dir [file dirname $libFile]
    source $libFile
    #lappend auto_path [file dirname $libFile]
}



log.info "Current GIT_ROOT=[git.root]"

#log.info "Script: [info script]"

log.info "KISSB Version=${kissb.track}@${kissb.version}"

set ::BASE [pwd]

## Process Arguments
##############

## Targets are arguments without "-" as starter
set targets {}
set args {}
set checkVersion false
foreach arg $argv {
    
    if {$arg == "--refresh"} {
        env KB_REFRESH 1
        env KB_REFRESH_ALL 1
    } elseif {$arg == "--force"} {
        env KB_FORCE 1
    } elseif {$arg == "--debug"} {
        log.set.level DEBUG
    } elseif {$arg == "--update"} {
        set checkVersion true
    } elseif {[string match -* $arg] || ([file exists $arg] && [llength $targets]>0)} {
        lappend args $arg
    } else {
        lappend targets $arg
    }
}

## Run update check
if {$checkVersion} {
    package require kissb.internal.update
    kissb::internal::update::run
    #source [file dirname [info script]]/update_check.tcl
}

#foreach {n v} [array get ::env] {
#    puts "-env $n -> $v"
#}

## Load Lib and packages from well-known folders
foreach libFile [files.globFiles ${kissb.home}/lib/*.lib.tcl .kissb/*.lib.tcl *.lib.tcl ] {
    log.info "Loading lib file: $libFile"
    source $libFile
}

foreach packageFile [files.globFiles ${kissb.home}/lib/*.pkg.tcl .kissb/*.pkg.tcl *.pkg.tcl ] {
    log.info "Loading package file: $packageFile"
    kiss::packages::loadLocalPackageFile $packageFile
    #source $libFile
}

## Load local Kiss build
foreach buildFile {kiss.build kissb.build.tcl build.tcl} {
    if {[file exists $buildFile]} {
        source $buildFile
        break
    }
}
#source kiss.kb



## Run target
if {[llength $targets] == 0 && [llength $args] == 0 } {
    log.warn "No targets provided"
    foreach target [kiss::targets::listTargets] {
        puts "- $target"
    }
} elseif {[llength $targets]>0} {
    
    foreach target $targets {
        
        ## Run Target or command
        ###########
        if {[string range $target 0 0]=="."} {

            set cmd  [split [string range $target 1 end] " "]
            set bin  [lindex $cmd 0]
            set cmdArgs {}
            if {[llength $cmd]>1} {
                set cmdArgs [lrange $cmd 1 end]
            }
            log.info "Running command $cmd: bin=$bin, args=$cmdArgs"
            $bin {*}$cmdArgs

        } elseif {[file exists $target]} {

            # Run Target
            source $target

        } elseif {[string range $target 0 0]!="-"} {

            # Run Target
            kiss::targets::run $target {*}$args

        }
    
    }
 
}