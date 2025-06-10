# Core: Args


## Usage


This package provides utilities to process generic arguments passed to a method using the `args` parameter:

```tcl
proc foo args {
    kissb.args.contains -test {
        puts "-test passed as argument"
    }
}
foo -test
foo
```



## Commands Reference

{%
    include-markdown "./kissb.args.methods.md"
    dedent=true
    heading-offset=1
%}
