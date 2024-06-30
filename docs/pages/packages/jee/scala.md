# Scala

KISSB provides a package to configure a scala build, and can generate a BLOOP configuration for compatibility with both IntelliJ and Scala Metals IDE

    package require kissb.scala

To setup a new source module:

    scala.module main

This call will setup a default source module named main, with src/main/scala and src/test/scala source folders, and the default scala version set in the package.

To compile your module: 

    scala.compile main

To add dependencies:

    scala.dependencies.add main ARTIFACT 

with ARTIFACT being a GROUPID:ARTIFACTID:VERSION format


## Scalatest 

To use scala test, configure it on top of an existing source module: 

    scalatest.init main 

This will create a main/test module

