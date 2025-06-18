package require kissb.scala
package require kissb.proguard

proguard.init


@ config {

    ## Select versions
    scala.module main   3.7.1
    scala.jvm    main   21
    #ibm-semeru-openj9-java21:21.0.3+9_openj9-0.44.0


}
## Compile
@ build : config {

    #scala.compile main/test
    scala.compile main
    #bloop.compile main/test

}

@ test : build {

    ## Scala test
    scalatest.init main

    scala.compile main/test
    scalatest.run main
}

@ run : build {
    #scala.run main Test
    bloop.run main Test {*}$args
}

@ bloop : config {

    bloop.config main
    bloop.config main/test
    bloop.projects projects

}

@ package.singlejar : build {

    proguard.jarWithDependencies main

}
