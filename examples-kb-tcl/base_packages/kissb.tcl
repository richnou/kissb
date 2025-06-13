
## This package is preloaded from the local .pkg.tcl file
print.line "Loading Local package"
package require example.pkg
package require hello

puts "here"
hello_from_package

## This package can be checkedout from git
#package require kissb.git
#git.init
package require git:https://github.com/opendesignflow/odfi-dev-tcl
