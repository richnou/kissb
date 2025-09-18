# SPDX-FileCopyrightText: 2024 KISSB
#
# SPDX-License-Identifier: Apache-2.0

package provide kissb.java 1.0
package require zipfile::mkzip
package require kissb.coursier

namespace eval java {

    vars.define jvm.default.version       21

    vars.define javac.env.args {}

    set packageFolder [file dirname [file normalize [info script]]]

    proc getModuleBuildName module {

        return [vars.resolve ${module}.build.name [string map {/ -} $module]]
    }

    kissb.extension java {

        defaultRunEnv args {

            # Runs coursier to get default jvm versions set in this module
            # Returns an environment dict that can be used by the exec module to run java command line or javac or other tools via java.run
            return [exec.cmdGetBashEnv coursier.setup \
                    --env --jvm [vars.resolve jvm.default.version]]
        }

        run args {
            # Runs java cmd line tool using jvm.default.version variable
            #
            exec.withEnv [java.defaultRunEnv] {
                puts "Run java"

                exec.run java {*}$args
            }
        }
        docker {module imageSpec args} {

            package require kissb.docker

            coursier::resolveModule $module

            files.inBuildDirectory java/docker {

                # create jar
                set jarPath [java.jar $module ${module}.jar]

                # Create app folder and copy main to it
                files.delete app
                files.inDirectory app {
                    # copy jar
                    files.cp $jarPath .


                    # Resolve library paths and copy them to libs folder
                    set libs {}
                    files.inDirectory libs {
                        foreach l [dependencies.resolve $module lib] {
                            files.cp $l .
                            lappend libs [file tail $l]
                        }
                    }

                    # Write out env for runner
                    files.withWriter .env {
                        files.writer.printLine "JAVA_ARGS="
                        if {[llength $libs]>0} {
                            files.writer.printLine "JAVA_ARGS=\"\$JAVA_ARGS -cp [join [concat [file tail $jarPath] [lmap lib $libs { string trim "./libs/[file tail $lib]"}]] :]\""
                        } else  {
                            files.writer.printLine "JAVA_ARGS=\"\$JAVA_ARGS -cp [file tail $jarPath]\""
                        }

                        kissb.args.withValue -mainClass main {
                            files.writer.printLine "JAVA_ARGS=\"\$JAVA_ARGS $main\""
                        }
                    }

                    # Copy runner
                    files.cp ${java::packageFolder}/dockerfiles/app_runner .

                    # Build
                    docker.build -f ${java::packageFolder}/dockerfiles/Dockerfile.jrun.base  -t $imageSpec  .
                }


            }
        }


        jar {module jarPath args} {

            set jarSource   [vars.resolve ${module}.build.classes]
            set buildDir     [vars.resolve ${module}.build.directory]



            files.inBuildDirectory java/jar/$module {

                # pack compiled output
                set jarName [file tail $jarPath]
                set outputAppPath app
                files.delete $outputAppPath
                files.mkdir $outputAppPath

                set tempJarPath [file normalize $jarName]

                # Copy output
                files.cp $jarSource/* $outputAppPath

                log.info "Copying compiled classes to [file normalize $outputAppPath]"


                # pack manifest
                files.inDirectory $outputAppPath/META-INF {
                    files.withWriter MANIFEST.MF {
                        files.writer.printLine "Manifest-Version: 1.0"
                        files.writer.printLine "Created-By: KISSB ${::kissb.version}"

                        kissb.args.withValue -mainClass main {
                            files.writer.printLine "Main-Class: $main"
                        }
                    }
                }

                # Make jar
                files.inDirectory $outputAppPath {
                    ::zipfile::mkzip::mkzip $tempJarPath -comment "JAR Created by KISSB" -directory .
                }

                log.info "Build jar from $jarSource to $tempJarPath"

                return $tempJarPath
            }
        }




    }
}
