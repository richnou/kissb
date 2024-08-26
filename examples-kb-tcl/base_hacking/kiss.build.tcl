


## Test function
###########

fun test_function args {
    log.info "in test function with args: $args"
}


test_function

## Interception
kissb.intercept test_function {

    log.success "Intercepted test_function (args=$args)"

    intercept.next
}

kissb.intercept test_function {
    log.success "Intercepted test_function 2"

    intercept.next
}

test_function --d

## Pre/Post
fun test_function2 args {
    log.info "in test function 2  with args: $args"
}
kissb.intercept.pre test_function2 {
    log.info "Before test function 2"
}
kissb.intercept.post test_function2 {
    log.info "After test function 2"
}
kissb.intercept.pre test_function2 {
    log.info "Before test function 2 twice"
}

test_function2