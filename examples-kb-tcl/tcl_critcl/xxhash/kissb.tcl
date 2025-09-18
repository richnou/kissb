
package require kissb.critcl

critcl.assertCompiling

@ compile {


    critcl.package xxhash_pkg.tcl

}

@ test {

    package require xxhash

    set testVar "Hello, xxHash32!"
    set seed    0x12345678
    log.info "Hash of $testVar -> [xxhash::xxhash32 $testVar $seed]"

    set testVar abcdefghijklmnopqrstuvw
    set seed    0
    log.info "Hash of $testVar -> [format %x [xxhash::xxhash32 $testVar $seed]]"

}
