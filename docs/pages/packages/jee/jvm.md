# Java/JVM

The Java/Jvm package provides some utilities to work with JVM projects:

- Manage the JVM version used in the KISSB script or in the terminal using scala coursier
- Package simple java applications as JAR, Jlinked runtimes or Docker image (this is incomplete and experimental)

The main usage of this package at this moment is the management of required Java version, since most tools are tied to Maven or Gradle usage, appart from Scala which can be used fully in KISSB thanks to the Bloop standard tooling configuration file.


~~~tcl
package require kissb.java

~~~

## JVM Installation and Selection

To select a JVM in a build file, or globally, just set the `jvm.default.version` variable. 

JVM selection and installation is done via the Scala coursier tool, which offers packages for most vendors. You can list them with the following command:

~~~bash
$ ./kissbw .coursier.listJvm
~~~

To select the Java version in a Build File:

~~~tcl title="kissb.tcl"
# For openjdk 25
vars.set jvm.default.version 25 
# For IBM OpenJ9 
vars.set jvm.default.version semeru-25
~~~

To test a version selection, you can also override the variable via environment, for example for IBM OpenJ9 25 or Temurin 25:

~~~bash
$ JVM_DEFAULT_VERSION=ibm-semeru:25 ./kissbw .jvm.java --version
$ JVM_DEFAULT_VERSION=25 ./kissbw .jvm.java --version
~~~


### Terminal JVM Selector

You can also use KISSB as a JVM selector in the terminal, to do so, you can use the utility that selects the JVM version and exports the environment variables for the terminal, PATH and JAVA_HOME.

This method works best if you have installed Kissb globally in your user space.

To inspect the produced environment for Bash:

~~~bash
$ JVM_DEFAULT_VERSION=ibm-semeru:25 ./kissbw -q .jvm.bashEnv
export JAVA_HOME="/home/xxx/.cache/coursier/arc/https/github.com/ibmruntimes/semeru25-binaries/releases/download/jdk-25.0.1%252B8_openj9-0.56.0/ibm-semeru-open-jdk_x64_linux_25.0.1_8_openj9-0.56.0.tar.gz/jdk-25.0.1+8"
export PATH="/home/xxx/.cache/coursier/arc/https/github.com/ibmruntimes/semeru25-binaries/releases/download/jdk-25.0.1%252B8_openj9-0.56.0/ibm-semeru-open-jdk_x64_linux_25.0.1_8_openj9-0.56.0.tar.gz/jdk-25.0.1+8/bin:$PATH"
~~~

To select the JVM in the terminal, the best is to create a function to which you can pass the version:


~~~bash  title=".bashrc"
kissb_select_jvm () { eval $(kissb -q .jvm.bashEnv $*); }
~~~

~~~bash
$ kissb_select_jvm --version 21 
$ java --version
~~~





## Java Package Variables

Before or after Loading a flow, you can set configuration variables:

~~~tcl
package require kissb.java

vars.set CONFIGURATION VALUE
~~~

{%
    include-markdown "./_java.vars.inc.md"
%}

## Java Commands Reference

{%
    include-markdown "./java.methods.md"
    dedent=true
    heading-offset=1
%}