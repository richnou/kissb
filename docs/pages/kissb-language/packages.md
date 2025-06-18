# Packages

Packages allow users to create common sets of build commands that can be reused between projects. A package can provide support for a new toolchain, or a custom workflow, like a source folder convention.

There are multiple types of packages for Kissb:

- Simple Scripts that are loaded by the user
- Simple Scripts loaded via well-known locations
- Packages that are loaded on-demand, either located in well-known locations or downloaded

## Source a simple local library

The easiest way to create a build command library is to define some commands in a script and load it from the build file.

In your build project, create a file called "mylib.tcl"

~~~~ tcl title="mylib.tcl"
proc hello args {
    print.line "Hello!"
}
~~~~

In your kissb.tcl file, you can just source this file, as in a standard bash script:

~~~~tcl title="kissb.tcl"

source mylib.tcl

# Now the hello command is available
hello
~~~~

## Well-Known Local Libraries

Simple script libraries located in well-known location and named after a convention are automatically loaded by kissb:

- Local files named *.lib.tcl
- Local files in the folder .kissb/*.lib.tcl
- Local files in the folder ~/.kissb/lib/*.lib.tcl
- Files named *.lib.tcl located in folders listed in the KISSB_LIBPATH env variable (paths separated by spaces)

The previous example could be written now as following:

~~~~ tcl title="mylib.lib.tcl"
proc hello args {
    print.line "Hello!"
}
~~~~

~~~~tcl title="kissb.tcl"
# The hello command is available right away
hello
~~~~

## Packages

The TCL language comes with a mechanism to load packages using a "package" command.

When requesting a package, the interpreter will load it if a package index file could be found with instructions on how to load it.
TCL searches for package index files in Folders from the **TCLLIBPATH** environment variable, in a similar fashion to Python Path for example.

Additionally, KISSB can detect packages provided by some source files if they follow a certain convention:

- Local files named *.pkg.tcl
- Local files in the folder .kissb/ named *.pkg.tcl
- Local files in the folder ~/.kissb/lib/ named *.pkg.tcl

## Local Package file

For example, create a localfile called **hello.pkg.tcl**:

~~~~ tcl title="hello.pkg.tcl"
# This line declares that this file is providing a package, it is mandatory
package provide hello 1.0

proc hello_from_package args {
    print.line "Hello!"
}
~~~~

~~~~tcl title="kissb.tcl"
package require hello

# The hello_from_package command is now available
hello_from_package
~~~~

## Package Library

When creating multiple packages, it can be useful to group them in a library, and let the user request packages at will.

This can be done by creating a folder and adding a file called "pkgIndex.tcl" which contains the list of packages, with instructions on how to load them.

The folder can then be added to the **TCLLIBPATH** or **KISSB_PACKAGEPATH** environment variable (paths separated by spaces), or to one of the following Well-known location:

- Local .kissb/pkgs folder
- Folder ~/.kissb/pkgs in user's home
- The .kissb/pkgs folder in the GIT_ROOT of your project

For example, create a folder for your library in your local project:

    $ mkdir -p .kissb/pkgs/mylib

Now create a simple package, for example in the file .kissb/pkgs/mylib/mypackage.tcl:

~~~~ tcl title=".kissb/pkgs/mylib/mypackage.tcl"
# This line declares that this file is providing a package, it is mandatory
package provide hello 1.0

proc hello_from_package args {
    print.line "Hello!"
}
~~~~

Now create an index file:

~~~~ tcl title=".kissb/pkgs/mylib/pkgIndex.tcl"

package ifneeded hello 1.0 [source $dir/mypackage.tcl]

~~~~

In your kissb.tcl, you can now directly request this package, since it is located in a well-known location:

~~~~tcl title="kissb.tcl"
package require hello

# The hello_from_package command is now available
hello_from_package
~~~~

## Package from GIT

Another way to simply load packages is to request a GIT package. KISSB can intercept a **package require** line that refers to a GIT url, and clone the repository.

For example:

~~~tcl
package require git:https://github.com/opendesignflow/odfi-dev-tcl
~~~

The package loader automatically searches for a pkgIndex.tcl file to load from the following default locations in the repository:

- pkgIndex.tcl
- tcl/pkgIndex.tcl
- lib/pkgIndex.tcl
- src/pkgIndex.tcl
