# Kotlin

KISSB Provides a plugin to load a kotlin toolchain, configure a project with dependencies, then build and run. 

It is still a work in progress, specially regarding IDE Support but already can demonstrate running a basic Kotlin Compose Multiplatform main.

To load the package:

    package require kissb.kotlin

Then to init the kotlin toolchain with the default package version

    kotlin.init

!!! note 
    This plugin relies on the coursier plugin to resolve classpath dependencies

## Configure sources and dependencies 

Project configuration for Kotlin is following the convention of modules to which sources and dependencies belong to. 
Typically in a Maven or Gradle project, you will have a main and a test module, for main source code and tests. 

Configuration in Kissb is explicit, which allows an easier understanding of build configuration, however it is up to the user to create or use some scripts that would setup the build with less explicit calls.

1. Setup a new Module: 

        kotlin.module main

This call will register a new module, and also add required dependencies, like the kotlin stdlib

2. Add a source folder, for example following classic convention: 

        kotlin.sources.add main src/main/kotlin

3. Add dependencies using maven/gradle format. The Kotlin Plugin uses coursier in the background to resolve dependencies:

        kotlin.dependencies.compile main {
            org.apache.commons:commons-lang3:3.14.0
        }




## Generate Dokka documentation

To generate a Dokka documentation, just use the dokka generator on a module:

    dokka.generate main


## IntelliJ Integration with Maven 

To integrate with IntelliJ IDEA, the easiest way for now is to generate a maven configuration file which can easily be reloaded upon build file change.

To do so, you can use the package: 

    package require kissb.kotlin.maven

Then create an "eclipse" target, for example: 

    @ eclipse {

        kotlin.eclipse.generate .
    }

Call `kissb eclipse` in the project folder to generate a pom.xml file 

## Maven Integration

Since the IntelliJ integration uses a Maven pom.xml file generation, you can easily run your build using maven. 

At the moment there is no maven toolchain setup for KissB, but if maven is installed on your machine, you can just run `mvn compile` after generating the maven config.
 
