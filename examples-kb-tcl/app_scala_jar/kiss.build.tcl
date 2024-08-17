
package require kissb.scala 


## Init scala with defaults
scala.module main 3.4.2
scala.jvm    main 21

@ build {

    scala.compile main

}

@ run {
    > build 

    scala.run main example.Main
}

@ jar {
    #scala.jar main -mainClass example.Main
    #scala.compile main -jar example.jar
    java.jar main example.jar -mainClass example.Main
}

@ docker {
    #scala.jar main -mainClass example.Main
    #scala.compile main -jar example.jar
    java.docker main example.jar -mainClass example.Main
}