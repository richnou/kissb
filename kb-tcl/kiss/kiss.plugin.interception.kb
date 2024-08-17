# SPDX-FileCopyrightText: 2024 KISSB
#
# SPDX-License-Identifier: Apache-2.0

package provide kiss.interception 1.0


namespace eval kissb::interception {

    # intercepted methods
    # key=name , value=list of scripts
    set interceptions [dict create]

    proc ::intercept.next args {
        uplevel {
            #puts "next level: ${__intercept_next_level} for ${__intercept_current_command}"
            [lindex [dict get ${kissb::interception::interceptions} ${__intercept_current_command}] end-${__intercept_next_level}]
        }
    }

    ## Interception
    kissb.extension kissb {
        
        intercept.pre {name script} {
            uplevel [list kissb.intercept $name [subst {
                $script
                intercept.next
            }]]
        }
        intercept.post {name script} {
            uplevel [list kissb.intercept $name [subst {
                
                intercept.next
                $script
            }]]
        }

        intercept {name script} {

            # get interceptions
            if {![dict exists ${kissb::interception::interceptions} $name]} {
                set actualInterceptions {}
            } else {
                set actualInterceptions [dict get ${kissb::interception::interceptions} $name]
            }
            

            # create command
            set __interceptCommandName __intercept_${name}_[llength $actualInterceptions]
            log.debug "created interception command as ${__interceptCommandName}"
            ::fun ${__interceptCommandName} args [subst {
                upvar __intercept_current_command __intercept_current_command
                upvar  __intercept_next_level __intercept_next_level
                incr __intercept_next_level
                $script
            }]


            # if it is the first interception, replace original command with interception support
            if {[llength ${actualInterceptions}] == 0} {
                log.debug "Creating interception command for $name"

                # rename to a known name
                rename $name __${name}

                # Initial call chain is then first the interceptor, then the original
                dict lappend kissb::interception::interceptions ${name} __${name} ${__interceptCommandName}

                # new script
                proc $name args [subst -nocommands {
                    
                    # call first interceptor (last in list), which then will call up the chain
                    set __intercept_next_level 0
                    set __intercept_current_command $name
                    \[lindex \[dict get \${kissb::interception::interceptions} $name\] end\]                    
                }]
            } else {
                
                # interception is setup, just add the interceptor to the end of chain
                dict lappend kissb::interception::interceptions ${name} ${__interceptCommandName}
            }

        }
    }


    ## Hook
    kissb.extension kissb.hook {

        pre {name script} {

        }

    }
}