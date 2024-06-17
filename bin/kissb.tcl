package require kiss 



## Load local Kiss build
set args $argv
foreach buildFile {kiss.b kiss.kb kiss.build} {
    if {[file exists $buildFile]} {
        source $buildFile
        break
    }
}
#source kiss.kb

## Run target
if {[llength $argv] == 0 } {
    log.warn "No targets provided"
    foreach target [kiss::targets::listTargets] {
        puts "- $target"
    }
} else {
    set target [lindex $argv 0]

    ## Run Target or command
    ###########
    if {[string range $target 0 0]=="."} {

        set cmd [string range $target 1 end]
        log.info "Running command: $cmd"
        [$cmd]

    } elseif {[string range $target 0 0]!="-"} {

        log.info "Running target: $target"

        # Remove target from args
        set argv [lrange $argv 1 end]

        # Run Target
        kiss::targets::run $target {*}$argv

    }
    
}