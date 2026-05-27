# Gradle 


The gradle package provides following basic functionality:

- Check for Gradlew presence and version - update gradlew wrapper file for correct version
- Add .gradlew top level command that runs gradlew using the Build File JVM

## Calling Gradlew 

~~~tcl title="kissb.tcl"
package require kissb.gradle 

vars.set jvm.default.version 21
vars.set gradle.version      8.5

# This will validate and update the gradlew wrapper
gradlew.init 


# A simple build target

@ build {

    gradlew build 

}
~~~

Or from the terminal call gradlew directly:

~~~bash 
$ ./kissbw .gradlew build
~~~
