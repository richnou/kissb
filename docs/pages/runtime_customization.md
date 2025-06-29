# Runtime Customisation

Since KISSB runs on TCL, it is possible to use TCL `zipfs` package to create a single file runtime of Kissb with additional scripts and packages.

Such runtimes are best build directly from an existing single file runtime,
for example called via the [KISSB Wrapper](./installation.md#wrapper).

To create a new runtime, users can use the `kissb.runtime` package from a build file or directly from the command line.

For example to create a new runtime file, without any changes:

~~~console
$ ./kissbw .runtime.create mykissb
~~~

This will create a new executable called "mykissb" which you can just run:

~~~console
$ ./mykissb
~~~

## Adding Extra Configuration

To add some extra config files which are loaded when KISSB starts, you can use the argument `--conf`:

=== "SFR creation"

    ~~~console
    $ ./kissbw .runtime.create mykissb --conf "20-mytest.conf.tcl 21-mytest.conf.tcl"
    ~~~

=== "Configurations"

    ~~~tcl title="20-mytest.conf.tcl"
    puts "Hello from test conf 1"
    ~~~

    ~~~tcl title="21-mytest.conf.tcl"
    puts "Hello from test conf 2"
    ~~~

Now when running the new runtime, you will see the `puts` from the configuration files loaded during kissb startup:

~~~console
$ ./mykissb
INFO.top xxxxx
Hello from test 1
Hello from test 2
~~~

## Adding Extra Packages

To add extra TCL package folders which will be available in the runtime, use the `--packages` argument:

=== "SFR creation"

    ~~~console
    $ ./kissbw .runtime.create mykissb --packages "testpackage"
    ~~~

=== "testpackage/"

    ~~~tcl title="pkgIndex.tcl"
    package ifneeded kissb.testpackage 1.0 [list source $dir/testpkg.tcl]
    ~~~

    ~~~tcl title="testpkg.tcl"
    package provide kissb.testpackage 1.0
    package require kissb

    puts "Loading testpackage..."

    namespace eval testpackage {

        kissb.extension testpackage {

            hi args {

                puts "Hello from pkg..."
            }
        }

    }
    ~~~

The new `mykissb` runtime can now load the package `kissb.testpackage`, for example to call the "hi" command from the command line:

~~~console
$ ./mykissb .testpackage.hi
INFO.top KISSB=dev@250627,TCL=9.0.1,GIT_ROOT=xxxxx
INFO.top Running command testpackage.hi: bin=testpackage.hi, args=
Loading testpackage...
Hello from pkg...
~~~

We can see the puts first from loading the package, then from calling the "hi" command itself.
