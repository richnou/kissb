---
tags:
  - Scala
  - Bloop
  - Coursier
---

# Scala: App/Lib v1.0

The Scala App/Lib Flow provides a package that helps properly set build targets to configure the scala and java plugins to build projects organised in single build, or multi-build  configurations.

This Flow aims at providing users a lightweight experience similar to that of using Sbt/Maven/Gradle, however some very advanced features might be missing or impossible to implement for very complex projects.

Features Summary for each configured build:

- Build Target to compile using `scalac` and `javac`
- Run Target to run a main class if the configured build provides one in the configuration
- Jar Building and Installation in local Ivy cache
- Bloop Configuration generation
- Dependency resolution via Coursier, Dependency between build projects possible

To load the flow in your project:

~~~tcl
package require flow.scala.applib 1.0
~~~


## Add build project(s)

To add your project to the build, use the `flow.addBuilds FOLDERS` command:

- If your project resides in the local folder, pass ".":

    ~~~tcl
    package require flow.scala.applib 1.0

    flow.addBuilds .
    ~~~

- For Multi-Build projects, pass a list of folders where the submodules reside:

    ~~~tcl
    package require flow.scala.applib 1.0

    # A library is located in folder lib
    # The main app is located in folder app
    flow.addBuilds lib app
    ~~~

By Default the flow will add following compilation targets and sources to the build:

- **FOLDER/main** as main compilation target
    - `src/main/*` : All folders under src/main are compiled in order, java files are compiled first via `javac`
    - `src/main/resources`: Resources folder content are copied to the classes output during build
- **FOLDER/test** as test compilation target
    - `src/test/*` : All folders under src/test are compiled in order, java files are compiled first via `javac` - The test target depends on the main target by default

## Tests: Scala test

In the current version of the flow, if a `BUILD/test` target is created, Scala test is added as depdency and the `test` kissb target will run scalatest in test discovery mode.

Configuring the test framework and passing custom arguments to the test runner will be available in a later release.

## Dependencies

The flow offers commands to add dependencies for both the `BUILD/main` and `BUILD/test` build targets, with either `compile` and `runtime` scopes:

- `compile` dependencies are added when building or running the project (i.e always)
- `runtime` dependencies are added only when running a main class or tests

To add dependencies, use the following commands:

- `flow.addDependencies`: Add Compile dependencies to `BUILD/main` build target
- `flow.addRuntimeDependencies`: Add Runtime dependencies to `BUILD/main` build target
- `flow.addTestDependencies`: Add Compile depdencies to `BUILD/test` build target
- `flow.addTestRuntimeDependencies`: Add Runtime dependencies to `BUILD/test` build target

`flow.addXXXDependencies BUILD DEPENDENCIES` command:

- BUILD is the name of the BUILD folder:

    ~~~tcl
    package require flow.scala.applib 1.0

    # For single build
    flow.addBuilds .
    flow.addDependencies . {}

    # For Multi builds
    flow.addBuilds lib app
    flow.addDependencies lib {}
    flow.addDependencies app {}
    ~~~

- The Dependencies list can contain variables which will be substituted:

    ~~~tcl
    ...

    # Note the "::" after org.scala-lang which makes coursier resolve toolkit for the correct scala version
    set toolkitVersion 0.7.0
    flow.addDependencies lib {
        "org.scala-lang::toolkit:$toolkitVersion"
    }
    flow.addDependencies app {}

    ...
    ~~~
- Dependencies named `@BUILD/TARGET` will be added as depdency to another build compilation:

    ~~~tcl
    ...

    # Note the "::" after org.scala-lang which makes coursier resolve toolkit for the correct scala version
    set toolkitVersion 0.7.0
    flow.addDependencies lib {
        "org.scala-lang::toolkit:$toolkitVersion"
    }
    # The app module depends on the lib build main compilation target
    flow.addDependencies app {
        @lib/main
    }
    ...
    ~~~


## Build Targets

The Flow creates following build targets to build,run or create bloop configs.

!!! note
    For single module builds in the local folder, the "BUILD." prefix is removed to make the targets more readable.

!!! note
    For multi module builds, two **build** and **bloop** targets are created which will build or generate bloop configuration for all build modules.

| Target | Description |
| ------ | -----------|
|BUILD.setup| Initialises the scala compilation targets - this target is called by the flow after build creation|
|BUILD.build|Compile the module's main target (without tests)|
|BUILD.run|if the build properties contains a `java { mainClass "CLASS" }` property, this target builds the main target and runs the main class via the `scala` command|
|BUILD.test| Compile the module's test target and run them|
|BUILD.jar| Create a jar for the module - if the build properties contains a `java { mainClass "CLASS" }` property, the jar is made executable. If `-publishLocal` is passed, copies the jar with an ivy file to the local ivy cache|
|BUILD.bloop|Generates the bloop configuration for the build. Argument `-list` lists bloop projects afterwards. Argument `-compile` compiles the build via bloop.  |

For example:

~~~tcl
package require flow.scala.applib 1.0

# For Multi builds
flow.addBuilds lib app
flow.addDependencies lib {}
flow.addDependencies app {}
~~~

Generates the build targets: bloop,build,lib.build,lib.bloop.lib.jar,app.build,app.bloop,app.run etc...



## Example: Single module Build

## Example: Multi module Build

## Known Limitations

### Java/Scala Mixed Projects

This flow compiles projects in Java then Scala mode by calling javac and scalac in order on Java and Scala sources. Since there is no source file analysis, users should ensure a proper compilation order if the project mixes java/scala usage (Java uses Scala classes).

To do so, a simple workaround is to organise folders by names, for example:

    - src/main/
        - 1-java
        - 2-scala
        - 3-java

In this case, the folder 1-java will be compiled first, then 2-scala and then 3-java. Java classes requiring Scala definitions should be placed in the 3-java folder.

The build flow lists the folders under src/main in order by default, so any configuration is possible.

## IDE Support

Using the `bloop` target generates bloop configurations, which enables loading the project
using compatible IDE extensions like [Scala Metals](https://scalameta.org/metals/) or [IntelliJ IDEA](https://www.jetbrains.com/idea/):

~~~tcl
package require flow.scala.applib 1.0

# For single build
flow.addBuilds .
flow.addDependencies . {}
~~~

Then:

~~~console
$ ./kissbw bloop
~~~

You should find the bloop configurations under the `.bloop folder`


## Flow Variables

Before or after Loading the flow, you can set configuration variables:

~~~tcl
package require flow.scala.applib 1.0

vars.set CONFIGURATION VALUE
~~~

{%
    include-markdown "./_vars/flow_scala_applib_1_0.inc.md"
%}


## Flow Commands Reference


{%
    include-markdown "./_methods/flow_scala_applib_1_0.inc.md"
    dedent=true
    heading-offset=1
%}
