package require flow.scala.applib 1.0

set version 1.0.0-SNAPSHOT

# Default configure local folder as build
flow.addBuilds .


flow.addDependencies . {

    "org.scala-lang::toolkit:0.7.0"

}
