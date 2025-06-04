---
tags:
  - TCL
  - KISSB
---

# Getting Started

If you haven't installed KISSB yet, visit the [Installation](installation.md) page and select your preferred method.

We are recommending to use the Wrapper script which will use a single file runtime of Kissb, which is the easiest way to use KISSB.

To test a simple build, create a folder, then install KISSB:


```console
test-folder $ curl -o- https://kissb.dev/get/kissbw | /bin/bash
test-folder $ ./kissbw
```


## Build File

As with any build system, your build script is written in a text file, which is named after a convention. You can select between the following names:

- Recommended: kissb.tcl
- Alternatives:  build.tcl, kissb.xxxx.tcl (replace xxx with your custom name)

Create a file called kissb.tcl, and log a message:

~~~~tcl
log.info "Hello World"
~~~~

Now run kissb in your terminal:

~~~bash
test-folder $ ./kissbw
...
INFO.top Hello World
WARN.top No targets provided
~~~

You can see your script was run, and a warning was produced because no specific build target was passed


## Build Targets

The standard usage of Kissb is to pass a build target, which is similar in the spirit to make targets, or lifecycle targets in Gradle or Maven.

Build targets have no special lifecycle meaning in Kissb, users and/or package providers can define their own convention.

To add a target to your build file, use the "@" command:

~~~~tcl

@ foo {
    log.info "In Foo target"
}
~~~~

Now run kissb again, passing the **foo** target:

~~~bash
test-folder $ ./kissbw foo
...
INFO.top Registering target foo, size of args=1
INFO.top Running target: foo with args=
INFO.top.foo In Foo target
~~~

Targets are very similar to simple build functions, but they offer a more evolved syntax to allow usages similar to make scenarios.

Add a new target **bar** which should run before foo:

~~~~tcl

@ bar {
    log.info "In Bar target"
}

@ foo : bar {
    log.info "In Foo target"
}
~~~~

Now run kissb again, passing the **foo** target:

~~~bash
test-folder $ kissb foo
...
INFO.top Registering target bar, size of args=1
INFO.top Registering target foo, size of args=3
INFO.top - Required target: bar
INFO.top Running target: foo with args=
INFO.top Running target: bar with args=
INFO.top.bar In Bar target
INFO.top.foo In Foo target
~~~


## Build Packages

At this point your build doesn't do anything special, and the KISSB core API doesn't provide any specific build mechanism for any languages.

However, a certain number of packages are available, which provide build commands and extensions for specific languages.

The build commands or extensions are simply TCL packages that provide functions to be used in build files.


## Local Script Libraries

Adding Local scripts and packages is one good way to create your own set of build commands and share them between projects.

There are multiple ways to load utility scripts, described on the [Packages](kissb-language/packages.md) page
