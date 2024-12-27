# SPDX-FileCopyrightText: 2024 KISSB
#
# SPDX-License-Identifier: Apache-2.0

package require kissb.quarkus

## Parameters
###################
vars.set java.main kissb.quarkus.KissbQuarkusMain
#vars.set java.main io.quarkus.runner.ApplicationImpl

## Flow
###############

# Load app C1 convention flow
flow.load scala/single_app_c1

## Config
###########

## Load BOM
coursier.bom.enforce io.quarkus.platform:quarkus-bom:3.12.0
 
## Add dependencies
dependencies.add main coursier quarkus-rest quarkus-smallrye-health quarkus-core quarkus-scala

## Add Source folder with kissb main
kiss::sources::addSourceFolder main [file normalize [file dirname [info script]]]/microprofile_scala_c1/src/scala

## Targets
#################

@ pom {

    quarkus.maven.generate .
}
@ quarkus : pom  {
    scala.compile main
    puts "PWD: [pwd]"
    scala.run main [vars.resolve java.main]
}