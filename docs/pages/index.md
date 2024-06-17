# KISSB Build System

Welcome to KISSB, a pragmatic Script Oriented Build system based on the TCL script language. 

KISSB provides users with a scripting language that is close to a classic terminal-based script, while being easy and quick to augment via packages and custom scripts. The goal is not to rewrite build systems for any existing programming language, but to provide a flexible scripted build system environment to run any existing toolchain. 

A quick example of a kiss.build file: 

~~~tcl 
{%
    include-markdown "../../examples-kb-tcl/python3/simple_pyside/kiss.build"
    comments=false
%}
~~~

Then from the command line:

> kissb 