
namespace eval ::xxhash {


    proc rol {x n} {
        set x [expr {$x & 0xffffffff}]
        return [expr {(($x << $n) | ($x >> (32 - $n))) & 0xffffffff}]
    }

    proc xxhash32 {data seed} {


        set prime1 0x9e3779b1
        set prime2 0x85ebca77
        set prime3 0xc2b2ae3d
        set prime4 0x27d4eb2f
        set prime5 0x165667b1

        set ptr 0
        set len [string length $data]
        if {$len >= 16} {
            lassign [xxhash::scan-loop $data $seed] ptr hash
        } else {
            set hash [expr {$seed + $prime5}]
        }

        incr hash $len

        set limit [expr {$len - 4}]
        while {$ptr <= $limit} {
            binary scan $data "@$ptr iu" x
            set hash [expr {$hash + $x * $prime3}]
            set hash [expr {[rol $hash 17] * $prime4}]
            incr ptr 4
        }

        while {$ptr < $len} {
            binary scan $data "@$ptr cu" x
            set hash [expr {$hash + $x * $prime5}]
            set hash [expr {[rol $hash 11] * $prime1}]
            incr ptr 1
        }

        set hash [expr {$hash & 0xffffffff}]
        set hash [expr {(($hash ^ ($hash >> 15)) * $prime2) & 0xffffffff}]
        set hash [expr {(($hash ^ ($hash >> 13)) * $prime3) & 0xffffffff}]
        set hash [expr {($hash ^ ($hash >> 16)) & 0xffffffff}]

        return $hash
    }


}
