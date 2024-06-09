package require kiss 



## Load local Kiss build
foreach buildFile {kiss.b kiss.kb} {
    if {[file exists $buildFile]} {
        source $buildFile
        break
    }
}
#source kiss.kb

## Run target
if {[llength $argv] == 0 } {
    puts "No targets provided"
    foreach target [kiss::targets::listTargets] {
        puts "- $target"
    }
} else {
    set target [lindex $argv 0]
    puts "Running target: $target"

    kiss::targets::run $target $argv
}