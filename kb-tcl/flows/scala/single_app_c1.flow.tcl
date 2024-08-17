# SPDX-FileCopyrightText: 2024 KISSB
#
# SPDX-License-Identifier: Apache-2.0

package require kissb.scala


## Init scala with defaults
scala.module main [vars.get flow.scala.version 3.4.2]
scala.jvm    main [vars.get flow.jvm.version   21]

# Set standard resources folder
kiss::sources::addSourceFolder main/resources src/main/resources

## Set values for building project
######

# Target JVM
vars.set        main.jvm.target       21
vars.set        main.jvm.target       21

## Setup Scalatest
###########

scalatest.init main


## Targets
################

@ bloop {

    log.info "Deps: [kiss::dependencies::getDeps main] kiss::dependencies::getDeps(main)"
    scala.bloop main

    log.info "Listing projects from Bloop"

    coursier.withApp bloop {
        exec.run bloop projects
    }
}

@ build {

    scala.compile main
    scala.compile main/test
    
}

@ test {

    scala.compile main/test
    scalatest.run main
}

@ run {
    scala.compile main
    scala.run main [vars.resolve java.main]
}

@ jar {
    java.jar main example.jar -mainClass [vars.resolve java.main]
}

@ docker {
    java.docker main [vars.resolve image.name]:[vars.resolve image.tag]  -mainClass [vars.resolve java.main]
}



