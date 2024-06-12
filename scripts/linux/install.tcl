
######################################################
## Utilities
###########################################

#####################################################
## Main 
######################################################

## Variables
set kissb.version   1.0.0-beta1
set kissb.home      $::env(HOME)/.kissb/${kissb.version}

puts "Installation of KISSB ${kissb.version} into ${kissb.home}"
if {[file exists ${kissb.home}]} {
    puts "-> Exists"
}