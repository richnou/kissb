# -*- tcl -*-
# Critcl support, absolutely necessary.
package require critcl
# Bail out early if the compile environment is not suitable.
if {![critcl::compiling]} {
    error "Unable to build project, no proper compiler found."
}
# Information for the teapot.txt meta data file put into a generated package.
# Free form strings.
critcl::license {Andreas Kupries} {Under a BSD license}
critcl::summary {The first CriTcl-based package}
critcl::description {
    This package is the first example of a CriTcl-based package. It contains all the
    necessary and conventionally useful pieces.
}
critcl::subject example {critcl package}
critcl::subject {basic critcl}
# Minimal Tcl version the package should load into.
critcl::tcl 9.0
# Use to activate Tcl memory debugging
#critcl::debug memory
# Use to activate building and linking with symbols (for gdb, etc.)
#critcl::debug symbols
# ## #### ######### ################ #########################
## A hello world, directly printed to stdout. Bypasses Tcl's channel system.
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

::critcl::tsources xxhash_tcl.tcl

# ## #### ######### ################ #########################
# Forcing compilation, link, and loading now.
critcl::msg -nonewline { Building ...}
if {![critcl::load]} {
    error "Building and loading the project failed."
}

# Name and version the package. Just like for every kind of Tcl package.
package provide xxhash 1.0

log.info "Finished"
