# SPDX-FileCopyrightText: 2024 KISSB
#
# SPDX-License-Identifier: Apache-2.0
package provide flow.scala.applib 1.0

package require kissb.scala
package require kissb.maven
package require kissb.ivy

vars.define flow.scala.version ${::scala.default.version} -doc "Scala Version used for the builds"
vars.define flow.jvm.version   ${::jvm.default.version} -doc "Default JVM Version used for the builds. scalac/javac run via this jvm version, scalac outputs for this jvm version"



## Targets
################

proc flow.addBuilds args {
    # Add build folders as scala build module to the project
    # This Method creates Kissb top level target to build, run, test, generate bloop config etc..



    set allbuildNames {}
    vars.set flow.allBuilds $args

    foreach buildFolderAndArgs $args {

        set buildFolder [file normalize [lindex $buildFolderAndArgs 0]]
        set buildName   [file tail $buildFolder]

        set targetSuffix ".[file tail $buildFolder]"
        set targetBaseName "${buildName}."
        if {[llength $args]==1} {
            set targetBaseName ""
        }


        lappend allbuildNames $buildName
        vars.append flow.allBuilds $buildName


        log.info "Adding build in $buildFolder, base build name=$buildName"

        assert.isFolder  $buildFolder "Build folder doesn't exist"


        ## Configure properties for flow
        #########
        vars.set ${buildName}.properties {}

        ## Configure targets
        ##########
        @ ${targetBaseName}setup  {

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
                if {[file tail $folder] != "resources"} {
                    lappend srcDirs $folder
                }
                
            }

            #set extraSources {}
            #if {[files.isFolder $buildFolder/src/main/java]} {
            #    lappend extraSources $buildFolder/src/main/java
            #}
            scala.init $buildName/main \
                    -scala [vars.get flow.scala.version]  \
                    -baseDir $buildFolder \
                    -srcDirs $srcDirs

            log.info    "Select JVM"
            scala.jvm    $buildName/main [vars.get flow.jvm.version]

            log.info "Setup done"

            # Set standard resources folder
            if {[files.isFolder $buildFolder/src/main/resources] && ![files.isEmpty $buildFolder/src/main/resources]} {
                sources.add $buildName/main/resources $buildFolder/src/main/resources
            }


            ## Setup test target
            #########
            set testSrcFolders [files.globFolders $buildFolder/src/test/*]
            if {[llength $testSrcFolders]>=1} {

                log.info "Setting up scala test compilation target $buildName/test "

                scala.init $buildName/test \
                        -scala [vars.get flow.scala.version]  \
                        -baseDir $buildFolder \
                        -srcDirs $testSrcFolders

                ## Add scalatest
                scalatest.init $buildName/test
                scala.addDependencies $buildName/test compile @${buildName}/main

            }

        }

        @ ${targetBaseName}bloop  {

            set buildName   {{set buildName}}

            >> {{set targetBaseName}}setup

            ## Config any dependend modules
            #foreach depModule [vars.get ${module}.moduleDependencies] {
            #    >> [lindex [split $depModule /] 0].bloop.config
            #}

            ## Generate configuration
            #bloop.config $buildName/main
            foreach module [scala.listModules $buildName] {
                bloop.config $module
            }

            ## List projects if requested
            kissb.args.contains -list {
                log.info "Listing projects from Bloop"
                bloop.projects
            }

            ## Compile if requested
            kissb.args.contains -compile {

                bloop.compile $buildName/main
            }



        }

        @ ${targetBaseName}build   {

            set buildName   {{set buildName}}
            set module      $buildName/main

            >> {{set targetBaseName}}setup

            ## Build any dependend modules
            foreach depModule [vars.get ${module}.moduleDependencies] {
                >> [lindex [split $depModule /] 0].build
            }

            kissb.args.containsNot --skip-build {
                scala.compile $buildName/main
            }
            #scala.compile $buildName/test

        }




        @ ${targetBaseName}jar   {

            set buildName   {{set buildName}}

            >> {{set targetBaseName}}build

            set buildProps [vars.get ${buildName}.properties]

            assert.dictHasKey  $buildProps artifactId   "Build $buildName has no property artifactId set"
            assert.dictHasKey  $buildProps groupId      "Build $buildName has no property groupId set"
            assert.dictHasKey  $buildProps version      "Build $buildName has no property version set"

            set jarOut [java.jar $buildName/main $buildName-[dict get $buildProps version].jar]

            kissb.args.contains -publishLocal {
                ivy.installIvyLocal [dict get $buildProps artifactId] \
                                    [dict get $buildProps groupId] \
                                    [dict get $buildProps version] \
                                    $jarOut {}
            }

        }


        ## Test Targets
        #########

        @ ${targetBaseName}test  {

            set buildName   {{set buildName}}

            scala.compile ${buildName}/test
            scalatest.run ${buildName}/test
            #log.warn "Test target not implemented yet"
        }


        @> ${targetBaseName}setup

    } ; ## EOF Foreach


    ## Catch All targets
    #########
    if {[llength $allbuildNames]>1} {

        @ bloop {

            foreach build [vars.get flow.allBuilds] {
                >> ${build}.bloop
            }
        }

    }


}


proc flow._addDependencies {module scope deps} {



    set args  [uplevel [list subst $deps]]

    #log.info "Adding dependencies: $module -> [split {*}$args]"
    foreach d $args {
        scala.addDependencies ${module} compile {*}$d
    }

}


proc flow.addDependencies {module deps} {

    if {$module=="."} {
        set module [file tail [pwd]]
    }

    uplevel [list flow._addDependencies $module/main compile $deps]

}

proc flow.addRuntimeDependencies {module deps} {

    if {$module=="."} {
        set module [file tail [pwd]]
    }

    uplevel [list flow._addDependencies $module/main runtime $deps]

}


proc flow.addTestDependencies {module deps} {

    if {$module=="."} {
        set module [file tail [pwd]]
    }

    uplevel [list flow._addDependencies $module/test compile $deps]


}

proc flow.addTestRuntimeDependencies {module deps} {

    if {$module=="."} {
        set module [file tail [pwd]]
    }

    uplevel [list flow._addDependencies $module/test runtime $deps]


}



proc flow.build.properties {build pDict} {

    set targetBaseName "${build}."
    if {$build=="."} {
        set build [file tail [pwd]]
        set targetBaseName ""
    }

    ## Append build class
    vars.set    ${build}.properties [dict merge  [vars.get ${build}.properties] [uplevel [list subst $pDict]]]
    #vars.append ${build}.properties {*}[uplevel [list subst $pDict]]

    ## Add run target if a mainClass is defined
    #log.info "Current build properties for $build: [vars.get ${build}.properties]"

    vars.dict.withKeyValue ::${build}.properties java mainClass {


        log.info "Main class $mainClass detected for build $build"

        targets.ensure ${targetBaseName}run {

            # First build
            >> {{set build}}.build

            # Run using jvm
            scala.run {{set build}}/main {{set mainClass}}
        }

    }

}
