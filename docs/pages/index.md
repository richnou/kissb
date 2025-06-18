---
hide:
  - toc
---

# KISSB Build System

Welcome to KISSB, a pragmatic, script-oriented build system powered by the Tcl scripting language.

KISSB is designed to make build system creation intuitive and straightforward. It uses clear, familiar commands that
align with common development practices, providing robust tools for everyday tasks like compiling, packaging, and
releasing. At the same time, its API remains simple enough to let you easily tailor workflows to your specific project
needs without unnecessary complexity.

Our primary goal isn't to rewrite build systems for every existing programming language. Instead, we aim to offer a
flexible, scripted build environment that can effectively orchestrate your existing toolchains or, where beneficial,
provide a viable alternative.




A quick example of a build to run a python script:

=== "kissb.tcl"
    ~~~tcl
    {%
        include-markdown "__index_code/hero/kissb.tcl"
        comments=false
    %}
    ~~~

=== "main.py"
    ~~~python
    {%
        include-markdown "__index_code/hero/main.py"
        comments=false
    %}
    ~~~

Then from the command line:

> ./kissbw



<div class="grid" markdown>

<div class="card" markdown>
## Language Agnostic Build System

KISSB is a flexible TCL scripting library aimed at building projects no matter which language, tool or output is desired.

It is distributed as a script library, standalone executable or docker image.


<div markdown>
[:material-arrow-right-box: Getting started](./gettingstarted.md)

[:material-arrow-right-box: Installation](./installation.md)
</div>


</div>


<div  markdown>
=== "kissb.tcl"

    ```tcl
    log.info "Loading script with commands"
    source mylib.tcl

    foo # Will print success message

    ```

=== "mylib.tcl"

    ```tcl
    def foo args {
        log.success "Done!"
    }
    ```

</div>

<div markdown>
=== "kissb.tcl"

    ```tcl
    ## mylib.lib.tcl is loaded automatically as well-know named file
    foolib # Will print success message

    ## mypackage.pkg.tcl can be loaded on-demand
    package require mypackage 1.0

    foopackage
    ```

=== "mylib.lib.tcl"

    ```tcl
    # This file is loaded automatically
    def foolib args {
        log.success "Done!"
    }
    ```

=== "mypackage.pkg.tcl"

    ```tcl
    package provide mypackage 1.0

    # This file is loaded automatically
    def foopackage args {
        log.success "Done!"
    }
    ```
</div>

<div class="card" markdown>
## Flexible Language

Based on the TCL language, KISSB offers a very flexible API to create build work flows.

You can use or create build commands, hackable workflows and share your script libraries in  your project, user space or directly through git.

KISSB comes with a set of well-known locations and file names for packages and libraries to quickly load scripts.

<div markdown>
[:material-arrow-right-box: KISSB Basics](./kissb-language/primer.md)
[:material-arrow-right-box: Packages](./kissb-language/packages.md)
</div>
</div>


</div>
