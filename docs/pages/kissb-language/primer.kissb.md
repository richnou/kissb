
## KISSB API

### Quick introduction

!!! note
    Examples on this page uses the [KISSB Wrapper](../installation.md#wrapper) "./kissbw" executable

KISSB build scripts aim to provide a semantic and convention-based programming interface.
This approach is designed to make your build definitions straightforward to understand and easy to adapt to your project's
specific needs. While KISSB offers solid facilities for common build tasks like compiling, packaging, and releasing,
its API is also crafted to help users implement custom workflows effectively.

For example, if a file needs to be written with some text, like a version number for example, the files core module provides a helper:

```tcl
files.writeText src/generated/version.txt "1.0.0"
```

Typically, a build script will have a variable setting the version number, which in some cases could be overriden via environment, for example to build preview versions from branches:

```tcl
# defines version as a global variable with default value 1.0.0, if an environment VERSION is present, it will override the default value
vars.define version 1.0.0

# Use the version variable, preferably using the "::" prefix to access it as a global variable
files.writeText src/generated/version.txt "${::version}"

# You can also request the version variable through the API:
files.writeText src/generated/version.txt "[vars.get version]"
```

Now you can run the build script in this way:

```console
$ ./kissbw # Default version will be used
$ VERSION=1.0.0-rc1 ./kissbw # VERSION will be used
```

###  Build requirements and refresh

Most build system organise builds around targets, with dependencies only being build if necessary.

In KISSB, build targets can be defined in a similar fashion to Makefiles, however, the API and runtime offer options to programmatically
express a dependency and rebuild need.

The previous example could be rewritten so that the version.txt file is not regenerated everytime:

```tcl
vars.define version 1.0.0

files.requireOrRefresh src/generated/version.txt VERSION {
    files.writeText ${__f} "${::version}"
}
```
In that case, if the version.txt file is not present, the passed script will be executed to generate it, with the **${__f}** variable
containing the path to the file passed implicitely.
The **VERSION** argument is a refresh key, which will force re-execution of the script if a refresh
is requested on the command line:

```console
$ ./kissbw # Generates version.txt if not present
$ VERSION=1.0.0-rc1 ./kissbw --refresh-version # VERSION will be used as version, and version.txt will be rewritten.
```
This approach can be useful to ensure a previous build didn't leave a version file with a wrong version.

For more details on the refresh mechanism, see the [Core Refresh module](./kissb.refresh.md)

###  Build Targets

As mentionned in the previous section, build targets can be defined to be called as user needs: for example compilation, packaging, running tests etc...

Build targets are defined by calling the "@" command followed by a target name and a documentation if needed:

```tcl
@ foo {
    log.info "In Foo"
}

# The bar target will run after the foo target
@ {bar "An example target"} : foo {
    log.info "In Bar"
}
```
Running kissb without requesting a build target will show the available ones:

```console
$ ./kissbw
INFO.top KISSB=dev@250501,TCL=9.0.1
WARN.top ⚠ No build target or command provided
- bar - An example target
- foo -
```
Calling the **bar** target will first trigger **foo**:

```console
$ ./kissbw bar
INFO.top KISSB=dev@250501,TCL=9.0.1
INFO.top.foo In Foo
INFO.top.bar In Bar
```
For more details on how to run build targets in KISSB, see the [Build Targets](targets.md) section
