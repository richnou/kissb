# KISSB Build System

Welcome to KISSB, a pragmatic Script Oriented Build system based on the TCL script language.

KISSB provides users with a scripting language that is close to a classic terminal-based script, while being easy and quick to augment via packages and custom scripts. The goal is not to rewrite build systems for any existing programming language, but to provide a flexible scripted build system environment to run any existing toolchain.

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


<div markdown>[:material-arrow-right-box: Getting started](./gettingstarted.md)</div>


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

</div>


</div>
