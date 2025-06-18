# Scala

## Running REPL or CLI Code runner

To get started with scala quicly, you can just run a script or use the scala REPL, using the default versions used in KISSB:

* Run the REPL:
    ./kissbw .scala.runner
* Run a script:
    ./kissbw .scala.runner myscript.sc

Scala scripts can define embedded dependencies which are resolved automatically, scala even provides a default toolkit dependency to easily
provide API to manipule files, make http requests or even serve simple http apps.

For more details look at the [Scala Toolkit documentation](https://docs.scala-lang.org/toolkit/introduction.html).

## Overriding Scala and JVM version

Scala and Java are defined using two default variables:

* jvm.default.version, overridable using JVM_DEFAULT_VERSION on the command line
* scala.default.version, overridable using SCALA_DEFAULT_VERSION on the command line

## Using a build script

KISSB provides a package to configure a scala build, and can generate a BLOOP configuration for compatibility with both IntelliJ and Scala Metals IDE

```tcl
package require kissb.scala
```

To setup a new source module:

```tcl
scala.module main
```

This call will setup a default source module named main, with src/main/scala and src/test/scala source folders, and the default scala version set in the package.

To compile your module:

```tcl
scala.compile main
```

To add dependencies:

```tcl
scala.dependencies.add main ARTIFACT...
```

with ARTIFACT being a list of GROUPID:ARTIFACTID:VERSION format


## Scalatest

To use scala test, configure it on top of an existing source module:

```tcl
scalatest.init main
```

This will create a main/test module with src/test/scala source folder

## Bloop support

A bloop package is available which will generate a bloop json configuration,
which can be loaded by bloop supporting IDE plugins like [Scala Metals](https://scalameta.org/metals/)
