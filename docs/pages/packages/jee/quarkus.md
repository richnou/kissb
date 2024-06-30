# Quarkus 

The Quarkus package provides support to run quarkus via the Quarkus CLI and Maven Build:

    package require kissb.quarkus

Initialiasing Quarkus will load the classpath of the Quarkus CLI runner via Coursier:

~~~tcl
quarkus.init
~~~

The project setup is done in the same way as the Kotlin or Java support, for example create a main module with sources:

~~~tcl
package require kissb.kotlin

kotlin.init
quarkus.init

# Set main module
kotlin.module       main
kotlin.sources.add  main src/main/kotlin
~~~

To add quarkus extensions, list them with the **quarkus.extension.add** - you don't need to add the **quarkus-** prefix, the helper will add it automatically

~~~tcl
quarkus.extension.add main kotlin rest-jackson
~~~

Note that adding the Kotlin extension will let the package generate a properly configured Maven Pom file so that the build runs out of the box.

## Running Quarkus in Dev mode 

To run  quarkus in development mode dev, you can use the **quarkus.dev** command, which runs the Quarkus CLI - a supported build system like gradle or maven must be configured in the project folder. 

The quarkus package supports generating a maven toolchain locally by writting out a pom.xml file and installating a maven wrapper: 

~~~tcl
# Generate Maven
quarkus.maven.generate .

# Run quarkus
quarkus.dev
~~~