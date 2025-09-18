# SPDX-FileCopyrightText: 2024 KISSB
#
# SPDX-License-Identifier: Apache-2.0

package provide kissb.json 1.0


namespace eval ::kiss::json {

    set indent 0

    proc incrIndent args {
        incr ::kiss::json::indent
    }
    proc decrIndent args {
        incr ::kiss::json::indent  -1
    }
    proc getIndent args {
        return [string repeat " " [expr 4*${::kiss::json::indent}]]
    }
    proc write {outFile spec} {

        set o [open $outFile w+]
        puts $o "\{"

        puts $o [objToString $spec]
        #foreach {k v} $spec {
        #    puts $o "\"$k\":[vToString $v]"
        #}
         puts $o "\}"
        close $o
    }

    proc objToString obj {

        incrIndent
        set obj [subst [string trim $obj]]
        set mapped [lmap {k v} $obj {
            log.debug "mapping $k"
            if {[string match *:: $k]} {
                string cat "[getIndent]\"[string trimright $k ::]\" : \[\r\n[getIndent] [vToString $v true] \r\n[getIndent]\]"
            } else {
                string cat "[getIndent]\"$k\":[vToString $v false]"
            }

        }]
        log.debug "Done map: $mapped"
        decrIndent
        return [join $mapped ",\r\n"]
    }

    proc vToString {v {isArray false}} {
        log.debug "V to string for '$v' (array=$isArray)"
        set v [subst [string trim $v]]
        if {[string length $v]==0 && $isArray==false} {
            return "{}"
        } elseif {[string is entier $v] || [string is double $v]} {
            return $v
        } elseif {[string is false $v]} {
            return "false"
        } elseif {[string is true $v]} {
            return "true"
        } elseif {([llength $v] == 0 || [string length $v]==0) && $isArray==false} {
            return "{}"
        } elseif {[llength $v] > 1 && $isArray==false} {
           return " {\r\n[objToString $v]\r\n[getIndent]}"
        } elseif {[llength $v] >= 1 && $isArray==true} {
            incrIndent
            set r "   [join [lmap x $v { string cat [vToString $x] }] ",\r\n[getIndent]"]"
            decrIndent
            return $r

        } else {
            return "\"$v\""
        }
    }

    kissb.extension json {

        toString spec {
            return "\{\n[::kiss::json::objToString $spec]\n\}"
        }
        write {outFile spec} {

            set o [open $outFile w+]
            puts $o "\{"
            puts $o [::kiss::json::objToString $spec]
            puts $o "\}"
            close $o
        }

        # Reads a json text, then add spaces around : and , to normalize, and parse as list
        readAsList inFile {

            # Read full kson
            set json [files.read $inFile]

            # Normalize
            set jsonNormalized [string map {: " " , " "} $json]
            #puts "NORM Json: $jsonNormalized"
            #puts "index 0: [lindex $jsonNormalized 0]"
            #foreach {k v} [lindex $jsonNormalized 0] {
            #    puts "$k -> $v"
            #}
            #return [split $jsonNormalized]
            return [lindex $jsonNormalized 0]
        }


    }
}
