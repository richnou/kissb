# SPDX-FileCopyrightText: 2024 KISSB
#
# SPDX-License-Identifier: Apache-2.0

package provide kissb.java 1.0
package provide kissb.jvm 1.0
package require zipfile::mkzip
package require kissb.coursier

namespace eval java {

    vars.define jvm.default.version 21 -doc "Java Version installed and provided by this package"

    vars.define javac.env.args {}
    
    vars.define _jvm.default.cache.folder [vars.get kissb.home]/.cache/java

    set packageFolder [file dirname [file normalize [info script]]]

    proc getModuleBuildName module {

        return [vars.resolve ${module}.build.name [string map {/ -} $module]]
    }

    kissb.extension java {

        defaultRunEnv args {
            
            ## Get Runtime Env from coursier and cache to a file
            files.inDirectory [vars.get _jvm.default.cache.folder] {
                set jvmVersion [kissb.args.get --version [vars.resolve jvm.default.version]]
                set cachedEnvFile jvm-path-coursier-$jvmVersion
                files.requireOrRefresh $cachedEnvFile jvm {
                    
                    log.info "Creating Java Env cache file using coursier for version $jvmVersion" 
                    #files.writeText  $cachedEnvFile [exec.cmdGetBashEnv coursier.setup  --env --jvm [vars.resolve jvm.default.version]]
                    files.writeText  $cachedEnvFile [coursier.setup  --env --jvm $jvmVersion]
                } --kissb-silent
                
                
                return [exec.fileGetbashEnv $cachedEnvFile]
            }
            

            # Runs coursier to get default jvm versions set in this module
            # Returns an environment dict that can be used by the exec module to run java command line or javac or other tools via java.run
            
            #return [exec.cmdGetBashEnv coursier.setup \
            #        --env --jvm [vars.resolve jvm.default.version]]
        }

        run args {
            # Runs java cmd line tool using jvm.default.version variable
            #
            exec.withEnv [java.defaultRunEnv] {
                #puts "Run java"

                exec.run java {*}$args
            }
        }
        
        selected.env args {
            # Returns env update required for the selected java 
            return [java.defaultRunEnv {*}$args]
        }
        
        selected.bashEnv args {
            # Prints the env in bash format for the selected java
            #  args - add --version VERSION to select a specific version.
            set env [java.selected.env {*}$args]
            puts [exec.envDictToBashEnv $env]
        }
        
        selected.run {args} {
            # Runs the provided arguments as command using the default java environment 
            # For example java.selected.run java --version would print the selected version
            exec.withEnv [java.defaultRunEnv] {
                #puts "Run java"

                exec.run {*}$args
            }
        }
        
        selected.withEnv script {
            uplevel [list exec.withEnv [java.defaultRunEnv] [list eval $script ]]
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


namespace eval jvm {
    
    foreach jvmTool {java javac} {
        
        #puts "Creating JVM tool function jvm.$jvmTool"
        proc ::jvm.$jvmTool args "java.selected.run $jvmTool {*}\$args"
        #kissb.extension jvm [list $jvmTool args [list java.selected.run $jvmTool {*}$args]]   
            
    }
    
    proc ::jvm.bashEnv args {
        java.selected.bashEnv {*}$args
    }
    
    
    proc ::jvm.alternatives.provide args {
        
        # This utility sets a binary alternative to the alternative package
        package require kissb.alternatives
        
        kissb.args.get --version ${::jvm.default.version} -> jvmVersion
        
        
        set env [java.selected.env --version $jvmVersion]
        set jdkHome [dict get $env JAVA_HOME value]
        
        log.info "Setting up alternative for Java at $jdkHome"
        set bins {}
        files.withGlobFiles $jdkHome/bin/* {
            if {[files.isExecutable $file]} {
                lappend bins [file tail $file] $file
            } else {
                log.info "File $file is not executablen not adding to alternative"
            }
        }
        
        alternatives.setup jvm $jvmVersion [list bin $bins links [list jdk $jdkHome] env [list JAVA_HOME [list value links/jdk merge 0]] ] {}
        log.success "Java version: [exec.call java --version]"
        
    }
}