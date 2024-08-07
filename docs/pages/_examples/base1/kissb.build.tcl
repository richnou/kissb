print.line "Hello World"

@ bar {
    log.info "In Bar target"
}

@ foo : bar {
    log.info "In Foo target"
}