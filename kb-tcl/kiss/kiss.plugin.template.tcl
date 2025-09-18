package provide kissb.core.template 1.0


namespace eval kissb::core::template {


    kissb.extension template {


        replace str {


            set indices [regexp -indices -all -inline {\{\{[\w\s]+\}\}} $str]
            #puts "Indices: $indices"


            set offset 0
            foreach range $indices {

                set start [expr [lindex $range 0] + $offset]
                set end   [expr [lindex $range 1] + $offset]
                set evalCmd [string range $str $start+2 $end-2]
                #puts "eval: $evalCmd"
                set res [uplevel $evalCmd]


                # After replacing result in string, an offset is calculated because replacement changes length of string and next indices
                # if result is shorter than expression, offset is negative because next indices will be earlier in string
                incr offset [expr [string length $res] - ($end-$start) -1]

                #puts "replace with $res, offset now $offset"

                set str [string replace $str $start $end $res]
            }

            return $str
        }

    }

}
