lappend auto_path [file dirname [info script]]/../
package require kissb 

log.info "KISSB Version=${kissb.version}"

set ::BASE [pwd]

## Process Arguments
##############

## Targets are arguments without "-" as starter
set targets {}
set args {}
foreach arg $argv {
    if {$arg == "--refresh"} {
        env KB_REFRESH 1
        env KB_REFRESH_ALL 1
    } elseif {$arg == "--force"} {
        env KB_FORCE 1
    } elseif {$arg == "--debug"} {
        log.set.level DEBUG
    } elseif {[string match -* $arg] || [file exists $arg]} {
        lappend args $arg
    } else {
        lappend targets $arg
    }
}

## Standard Arguments
#kissb.args.contains --refresh {
#    env KB_REFRESH 1
#}
#kissb.args.contains --force {
#    env KB_FORCE 1
#}
#kissb.args.contains --debug {
#    log.set.level DEBUG
#}

## Load local Kiss build
foreach buildFile {kiss.b kiss.kb kiss.build} {
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

        } elseif {[string range $target 0 0]!="-"} {

            # Run Target
            kiss::targets::run $target {*}$args

        }
    
    }
 
}