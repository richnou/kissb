package require kissb.kotlin
package require kissb.kotlin.maven

## Select toolchains
kotlin.init

## Load dependencies
kotlin.module main {
    kotlin.compiler.jvm.source 21
}

sources.add main src/main/kotlin

@ assemble {
    #kotlin::compile main
    #kotlin::assemble main hello.jar
}

@ run  {
    kotlin::compile main
}

@ docs {

    dokka.generate main
}

@ maven {

    kotlin.maven.generate .
}
