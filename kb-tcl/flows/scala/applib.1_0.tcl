# SPDX-FileCopyrightText: 2024 KISSB
#
# SPDX-License-Identifier: Apache-2.0
package provide flow.scala.applib 1.0

package require kissb.scala
package require kissb.maven
package require kissb.ivy

vars.define flow.scala.version ${::scala.default.version}
vars.define flow.jvm.version   ${::jvm.default.version}
vars.define flow.mainClass     false





## Set values for building project
######

# Target JVM
#vars.set        main.jvm.target       21
#vars.set        main.jvm.target       21

## Setup Scalatest
###########

#scalatest.init main


## Targets
################

proc flow.addBuilds args {


    set allbuildNames {}
    vars.set flow.allBuilds $args

    foreach buildFolderAndArgs $args {

        set buildFolder [file normalize [lindex $buildFolderAndArgs 0]]
        set buildName   [file tail $buildFolder]
        set targetSuffix ".[file tail $buildFolder]"



        lappend allbuildNames $buildName
        vars.append flow.allBuilds $buildName


        log.info "Adding build in $buildFolder"

        assert.isFolder  $buildFolder "Build folder doesn't exist"

        #if {[pwd]!=$buildFolder} {
        #
        #}

        ## Configure properties for flow
        #########
        vars.set ${buildName}.properties {}

        ## Configure targets
        ##########
        @ ${buildName}.setup  {

            set buildName   {{set buildName}}
            set buildFolder {{set buildFolder}}

            set module $buildName/main

            ## Setup any dependend modules
            foreach depModule [vars.get ${module}.moduleDependencies] {
                >> [lindex [split $depModule /] 0].setup
            }

            ## Init scala with defaults
            log.info "Setup module $buildName in $buildFolder"

            ## Add Source folders by listed names under src/main
            set srcDirs {}
            foreach folder [files.globFolders $buildFolder/src/main/*] {
                lappend srcDirs $folder
            }

            #set extraSources {}
            #if {[files.isFolder $buildFolder/src/main/java]} {
            #    lappend extraSources $buildFolder/src/main/java
            #}
            scala.init $buildName/main -scala [vars.get flow.scala.version]  -baseDir $buildFolder -srcDirs $srcDirs

            log.info "Select JVM"
            scala.jvm    $buildName/main [vars.get flow.jvm.version]

            log.info "Setup done"

            # Set standard resources folder
            if {[files.isFolder $buildFolder/src/main/resources] && ![files.isEmpty $buildFolder/src/main/resources]} {
                sources.add $buildName/main/resources $buildFolder/src/main/resources
            }


        }

        @ ${buildName}.bloop.config  {

            set buildName   {{set buildName}}

            >> ${buildName}.setup

            ## Config any dependend modules
            #foreach depModule [vars.get ${module}.moduleDependencies] {
            #    >> [lindex [split $depModule /] 0].bloop.config
            #}

            bloop.config $buildName/main


            #bloop.config main/test

            if {[llength ${::flow.allBuilds}]<=1}  {
                log.info "Listing projects from Bloop"
                bloop.projects
            }

        }

        @ ${buildName}.bloop.compile  {


            set buildName   {{set buildName}}

            >> ${buildName}.setup

            bloop.compile $buildName/main


        }

        @ ${buildName}.build   {

            set buildName   {{set buildName}}
            set module      $buildName/main

            >> ${buildName}.setup

            ## Build any dependend modules
            foreach depModule [vars.get ${module}.moduleDependencies] {
                >> [lindex [split $depModule /] 0].build
            }

            kissb.args.containsNot --skip-build {
                scala.compile $buildName/main
            }
            #scala.compile $buildName/test

        }

        @ ${buildName}.test  {

            #scala.compile main/test
            #scalatest.run main
            log.warning "Test target not implemented yet"
        }


        @ ${buildName}.jar   {

            set buildName   {{set buildName}}

            >> ${buildName}.build

            set buildProps [vars.get ${buildName}.properties]

            assert.dictHasKey  $buildProps artifactId   "Build $buildName has no property artifactId set"
            assert.dictHasKey  $buildProps groupId      "Build $buildName has no property groupId set"
            assert.dictHasKey  $buildProps version      "Build $buildName has no property version set"

            set jarOut [java.jar $buildName/main $buildName-[dict get $buildProps version].jar]

            ivy.installIvyLocal [dict get $buildProps artifactId] [dict get $buildProps groupId] [dict get $buildProps version] $jarOut {}

        }


        #if {${::flow.mainClass}!=false} {
#
#            @ jar${targetSuffix} : build${targetSuffix} {##

                #set buildName   {{set buildName}}

         #       java.jar $buildName/main example.jar -mainClass [vars.resolve java.main]

         #   }

         #   @ run${targetSuffix} : build${targetSuffix} {

          #      set buildName   {{set buildName}}

          #      scala.compile $buildName/main
          #      scala.run $buildName/main [vars.resolve $buildName/main.mainClass]
          #  }

          #  @ docker${targetSuffix} : build${targetSuffix} {

          #      set buildName   {{set buildName}}

           #     java.docker main [vars.resolve $buildName/main.image.name]:[vars.resolve $buildName/main.image.tag]  -mainClass [vars.resolve $buildName/main.mainClass]

           # }

           # } else {
#

# }

        @> ${buildName}.setup

    } ; ## EOF Foreach

    ## Add Targets to build all builds at once
    #if {[llength $allbuildNames]>1} {

      #  @ setup : {*}[lmap b $allbuildNames { string cat setup. $b }] {

#
 #       }

  #      @ bloop.config : {*}[lmap b $allbuildNames { string cat bloop.config. $b }] {

   #         if {[llength ${::flow.allBuilds}]>1}  {
     #           log.info "Listing projects from Bloop"
    #            bloop.projects
    #     }
      #  }

       # @ jar : {*}[lmap b $allbuildNames { string cat jar. $b }] {


        #}
    #} else {
#
 #       @ setup : {*}[lmap b $allbuildNames { string cat setup. $b }] {
#
#
 #       }
 # }

}


proc flow.addDependencies {module args} {

    set args  [uplevel [list subst $args]]

    #log.info "Adding dependencies: $module -> [split {*}$args]"

    scala.addDependencies ${module}/main {*}$args
}


proc flow.build.properties {build pDict} {

    ## Append build class
    vars.set    ${build}.properties [dict merge  [vars.get ${build}.properties] [uplevel [list subst $pDict]]]
    #vars.append ${build}.properties {*}[uplevel [list subst $pDict]]

    ## Add run target if a mainClass is defined
    #log.info "Current build properties for $build: [vars.get ${build}.properties]"

    vars.dict.withKeyValue ::${build}.properties java mainClass {


        log.info "Main class $mainClass detected for build $build"

        targets.ensure ${build}.run {

            # First build
            >> {{set build}}.build

            # Run using jvm
            scala.run {{set build}}/main {{set mainClass}}
        }

    }

}
