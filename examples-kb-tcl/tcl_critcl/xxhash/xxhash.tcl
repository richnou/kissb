# An xxHash32 implementation in pure Tcl with optional Critcl acceleration.
# Copyright (c) 2017 dbohdan
# License: MIT
namespace eval ::xxhash {
    variable version 0.2.1
    variable useCritcl 0
    # The following variable will be true in Jim Tcl and false in Tcl 8.x.
    variable jim [expr {![catch {info version}]}]
    if {![catch {
        package require critcl 3
    }]} {
        set useCritcl [::critcl::compiling]
    }
}

proc ::xxhash::rol {x n} {
    set x [expr {$x & 0xffffffff}]
    return [expr {(($x << $n) | ($x >> (32 - $n))) & 0xffffffff}]
}

if {$::xxhash::useCritcl} {
    critcl::ccommand xxhash::scan-loop {cdata interp objc objv} {#define \
        XXHASH32_ROL(x,n) ((x << n) | (x >> (32 - n)))
        char *buf;
        long int rc, pos = 0, len, i;
        unsigned int v[4], x, seed, hash;
        Tcl_Obj* result;
        const unsigned int prime1 = 0x9e3779b1, prime2 = 0x85ebca77;

        if (objc != 3) {
            Tcl_WrongNumArgs(interp, 1, objv, "data seed");
            return TCL_ERROR;
        }
        rc = Tcl_GetIntFromObj(interp, objv[2], &seed);
        if (rc != TCL_OK) {
            Tcl_SetObjResult(interp,
                             Tcl_NewStringObj("seed must be integer", -1));
            return TCL_ERROR;
        }

        buf = Tcl_GetByteArrayFromObj(objv[1], &len);
        v[0] = seed + prime1 + prime2;
        v[1] = seed + prime2;
        v[2] = seed;
        v[3] = seed - prime1;
        do {
            for (i = 0; i < 4; i++) {
                x = *(unsigned int*)buf;
                buf += 4;
                pos += 4;
                v[i] += x * prime2;
                v[i] = XXHASH32_ROL(v[i], 13) * prime1;
            }
        } while (pos <= len - 16);

        hash = (XXHASH32_ROL(v[0], 1)  +
                XXHASH32_ROL(v[1], 7)  +
                XXHASH32_ROL(v[2], 12) +
                XXHASH32_ROL(v[3], 18)) & 0xffffffff;

        result = Tcl_NewListObj(0, NULL);
        rc = Tcl_ListObjAppendElement(interp, result, Tcl_NewWideIntObj(pos));
        if (rc != TCL_OK) {
            Tcl_SetObjResult(interp, Tcl_ObjPrintf("can't create result list"));
            return TCL_ERROR;
        }
        rc = Tcl_ListObjAppendElement(interp, result, Tcl_NewWideIntObj(hash));
        if (rc != TCL_OK) {
            Tcl_SetObjResult(interp, Tcl_ObjPrintf("can't create result list"));
            return TCL_ERROR;
        }

        Tcl_SetObjResult(interp, result);
        return TCL_OK;
    }
    xxhash::scan-loop {} 0
}

proc ::xxhash::xxhash32 {data seed} {
    variable jim

    set prime1 0x9e3779b1
    set prime2 0x85ebca77
    set prime3 0xc2b2ae3d
    set prime4 0x27d4eb2f
    set prime5 0x165667b1

    set ptr 0
    set len [string [expr {$jim ? {bytelength} : {length}}] $data]
    if {$len >= 16} {
        if {$::xxhash::useCritcl} {
            lassign [xxhash::scan-loop $data $seed] ptr hash
        } else {
            set limit [expr {$len - 16}]
            set v1 [expr {$seed + $prime1 + $prime2}]
            set v2 [expr {$seed + $prime2}]
            set v3 $seed
            set v4 [expr {$seed - $prime1}]

            while 1 {
                binary scan $data "@$ptr iu iu iu iu" x1 x2 x3 x4
                incr ptr 16

                incr v1 [expr {$x1 * $prime2}]
                set v1 [expr {[rol $v1 13] * $prime1}]

                incr v2 [expr {$x2 * $prime2}]
                set v2 [expr {[rol $v2 13] * $prime1}]

                incr v3 [expr {$x3 * $prime2}]
                set v3 [expr {[rol $v3 13] * $prime1}]

                incr v4 [expr {$x4 * $prime2}]
                set v4 [expr {[rol $v4 13] * $prime1}]

                if {$ptr > $limit} break
            }

            set hash [expr {
                ([rol $v1 1] + [rol $v2 7] + [rol $v3 12] + [rol $v4 18])
                & 0xffffffff
            }]
        }
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

proc ::xxhash::assert-equal-int {actual expected} {
    if {$actual != $expected} {
        error "expected 0x[format %08x $expected],\
               but got 0x[format %08x $actual]"
    }
}

proc ::xxhash::test {} {
    assert-equal-int [rol 0 0] 0
    assert-equal-int [rol 0xffffffff 5]  0xffffffff
    assert-equal-int [rol 0xcd0000ab 8]  0x0000abcd
    assert-equal-int [rol 0xcd0000ab 16] 0x00abcd00
    assert-equal-int [rol 0xcd0000ab 24] 0xabcd0000
    assert-equal-int [rol 0xcd0000ab 32] 0xcd0000ab
    assert-equal-int [xxhash32 abc 0] 0x32d153ff
    assert-equal-int [xxhash32 abc 0x12345678] 0x11364062
    assert-equal-int [xxhash32 {Hello, World! This is a test.} 0] 0x9ea357ea
    variable useCritcl
    if {$useCritcl} {
        set seq {}
        for {set i 0} {$i < 4} {incr i} {
            append seq [string repeat $i 64]
            set useCritcl 1
            set critcl [xxhash32 $seq 0]
            set useCritcl 0
            set pureTcl [xxhash32 $seq 0]
            assert-equal-int $critcl $pureTcl
        }
    } else {
        puts stderr {skipping tests that require Critcl}
    }
}

return
if {[info exists argv0] && ([file tail [info script]] eq [file tail $argv0])} {
    ::xxhash::test
}
