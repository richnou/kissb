# SPDX-FileCopyrightText: 2024 KISSB
#
# SPDX-License-Identifier: Apache-2.0

package provide kissb.signal 1.0


namespace eval kissb::signal {

    #package require Tclx
    if {[catch  {package require Tclx}]} {
        log.warn "Could not load TCLX"
        set loaded false 
    } else {
        set loaded true
    }

    set sigINTHandlers {}

    proc onSIGINT args {
        # Run handlers
        foreach handler ${::kissb::signal::sigINTHandlers} {
            eval $handler
        }
        
        # exit
        log.warn "Interrupting KISSB after CTRL-C"
        exit -1
    }
    

    kissb.extension kissb.signal {

        
        onSIGINT script {

            if {$kissb::signal::loaded} {
                signal trap SIGINT kissb::signal::onSIGINT
                lappend kissb::signal::sigINTHandlers $script
            }
        }
        

    }
}