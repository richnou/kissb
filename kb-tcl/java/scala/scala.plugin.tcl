# SPDX-FileCopyrightText: 2024 KISSB
#
# SPDX-License-Identifier: Apache-2.0

package provide kissb.scala 1.0
package require kissb.coursier
package require kissb.java

# https://github.com/Konloch/bytecode-viewer/releases/download/v2.12/Bytecode-Viewer-2.12.jar
namespace eval scala {

    set buildBaseFolder ".kb/scala"
    set defaultVersion 3.7.1

    vars.define scala.default.version   3.7.1

    proc getScalaEnv module {

        return [exec.cmdGetBashEnv coursier.setup -q --env \
                        --jvm [vars.resolve ${module}.jvm.name] \
                        --apps scala:[vars.resolve ${module}.scala.version],scalac:[vars.resolve ${module}.scala.version]]
    }

    ## Scala Extensions to build projects
    kissb.extension scala {

        module {m version} {
            scala.init $m $version
        }


        init {module args} {
            # Init project module  with versions version

            kiss::toolchain::init coursier

            ## Set Version
            kissb.each $args {
                log.info "Selecting Scala $it"
                coursier.install -q scala:$it scalac:$it
            }

            vars.set ${module}.name             $module
            vars.set ${module}.scala.major      [lindex [split $args .] 0]
            vars.set ${module}.scala.version    $args



            vars.set ${module}.build.directory  [file normalize ${::scala::buildBaseFolder}/$args/$module]
            vars.set ${module}.scalac.args      {-deprecation -unchecked -incr}
            vars.set ${module}.jvm.target       11

            vars.set ${module}.jvm.runtime      21
            vars.set ${module}.jvm.name         21

            ## Add Folders
            #kiss::sources::addSourceFolder $module src/main/scala
            sources.add $module src/main/scala

            ## Add Stdlib
            #kiss::dependencies::addDepSpec $module org.scala-lang:scala3-library_[vars.get ${module}.scala.major]:[vars.get ${module}.scala.version] coursier
            dependencies.add $module coursier org.scala-lang:scala3-library_[vars.get ${module}.scala.major]:[vars.get ${module}.scala.version]
        }

        defaultRunEnv args {
            # Runs coursier to get default scala and jvm versions set in this module
            # Returns an environment dict that can be used by the exec module to run scala command line or scalac
            return [exec.cmdGetBashEnv coursier.setup \
                    -q \
                    --env --jvm [vars.resolve jvm.default.version] \
                    --apps scala:[vars.resolve scala.default.version],scalac:[vars.resolve scala.default.version]]
        }

        jvm {module version {descriptor ""}} {
            # Select the JVM version for the application module


            vars.set ${module}.jvm.runtime $version
            if {$descriptor==""} {
                vars.set ${module}.jvm.name $version
            } else {
                vars.set ${module}.jvm.name $descriptor
            }
            coursier.setup --env -q --jvm [vars.get ${module}.jvm.name]
        }

        compile {module args} {
            # Compile module


            ##
            log.fine "Module $module scala version: [vars.resolve ${module}.scala.version]"

            ## Load scala with PATH
            set compileEnv [exec.cmdGetBashEnv coursier.setup -q --env --jvm [vars.resolve ${module}.jvm.name] --apps scala:[vars.resolve ${module}.scala.version],scalac:[vars.resolve ${module}.scala.version]]
            log.fine "Scala compile Env: $compileEnv"
            exec.withEnv $compileEnv exec.run scala --version
            #exec.run scala --version
            #exec.run PATH=/home/rleys/.local/share/coursier/bin:$::env(PATH) scala --version

            # Resolve deps
            coursier::resolveModule $module
            set deps [files.joinWithPathSeparator [kiss::dependencies::resolveDeps $module lib]]
            log.debug "Deps: $deps"

            # Sources
            set sources [kiss::sources::getSources $module]
            log.info "Sources to compile: $sources"
            if {[llength $sources]==0} {
                log.warn "No sources to compile in module $module ([kiss::sources::getSourceFolders $module])"
                return
            }

            # Classes output -> directory or jar
            set classesOut [vars.resolve ${module}.build.directory]/classes


            # Resources
            set resources [kiss::sources::getSourcesDict ${module}/resources]
            if {[llength $resources]>0} {

                foreach {srcDir srcDirResources} $resources {
                    log.info "Copying resource: $srcDir contains $srcDirResources "

                    foreach relativeResourcePath $srcDirResources {

                        log.info "Copying resource: $srcDir/$relativeResourcePath to $classesOut/[file dirname $relativeResourcePath]"

                        files.mkdir $classesOut/[file dirname $relativeResourcePath]
                        files.cp    $srcDir/$relativeResourcePath $classesOut/[file dirname $relativeResourcePath]
                    }
                }

                #files.cp $resources $classesOut
            }


            # Compile
            files.mkdir $classesOut
            try {
                exec.withEnv $compileEnv {
                    exec.run scalac  -usejavacp -classpath $deps -d $classesOut -java-output-version [vars.resolve ${module}.jvm.target] {*}$sources
                }
            } on error args {
                log.error "Compilation failed"
                throw SCALA.COMPILE.FAIL "compilation failed"
            }



        }

        run {module mainClass args} {
            # Run module's provided main class

            ## Load scala with PATH
            set compileEnv [exec.cmdGetBashEnv coursier.setup -q --env --jvm [vars.get ${module}.jvm.name] --apps scala:[vars.get ${module}.scala.version],scalac:[vars.get ${module}.scala.version]]
            log.fine "Scala compile Env: $compileEnv"

            ## deps = deps + build folder
            set deps [files.joinWithPathSeparator [concat [kiss::dependencies::resolveDeps $module lib] [vars.get ${module}.build.directory]/classes ]]

            exec.withEnv $compileEnv {
                exec.run java -version
                exec.run java -classpath $deps $mainClass
            }

        }


    }

    kissb.extension scalatest {

        init module {
            # Load Scala test for the given module

            set testModule ${module}/test
            vars.set ${testModule}.name             ${module}-test
            vars.set ${testModule}.build.directory  [file dirname [vars.get ${module}.build.directory]]/${module}-test

            ## Add source folder
            kiss::sources::addSourceFolder ${testModule} src/test/scala

            ## Add deps
            kiss::dependencies::addDepSpec ${testModule} org.scalatest:scalatest-app_3:${scalatest::version} coursier
            kiss::dependencies::addDepSpec ${testModule} org.scala-lang.modules:scala-xml_3:2.3.0 coursier
            kiss::dependencies::addDepSpec ${testModule} com.vladsch.flexmark:flexmark-all:0.64.8 coursier



        }

        run module {
            # Run tests for given module

            ## Get Build Dir
            set testModule ${module}/test
            set buildBir [vars.get ${testModule}.build.directory]

            ## Try to detect all classes

            ## Run scalatest app
            coursier::resolveModule $module
            coursier::resolveModule $testModule
            set runEnv [exec.cmdGetBashEnv coursier.setup -q --env --jvm [vars.get ${module}.jvm.name]]
            set deps [files.joinWithPathSeparator [concat [kiss::dependencies::resolveDeps $module lib] [kiss::dependencies::resolveDeps $testModule lib] [vars.get ${testModule}.build.directory]/classes ]]

            log.info "CP: $deps"

            try {
                # https://www.scalatest.org/user_guide/using_the_runner
                exec.withEnv $runEnv {
                    exec.run java -version
                    exec.run java -classpath $deps org.scalatest.tools.Runner -R $buildBir/classes -o -h $buildBir/report -u $buildBir/report
                }
            } on error {output options} {
                log.error "Error running tests"
            } finally {

            }

        }
    }

    ###################
    ## Ammnonite scripts
    ####################
    kissb.extension scala {

        amm {scriptFile} {
            # Run provided script File using ammonite

            ## Load scala with PATH
            set jvmVersion   [vars.get scala.jvm.name 21]
            set scalaVersion [vars.get scala.version ${::scala::defaultVersion}]
            set ammVersion   [vars.get amm.version 3.0.0-M2]

            log.info "Ammonite scala version: $scalaVersion"

            set compileEnv [exec.cmdGetBashEnv coursier.setup -q --env --jvm $jvmVersion --apps ammonite:$ammVersion]

            set deps [coursier.classpath com.lihaoyi:::ammonite:$ammVersion "" "" -e $scalaVersion]

            #puts "Deps: $deps"
            exec.withEnv $compileEnv {
                   exec.run java -cp $deps ammonite.AmmoniteMain $scriptFile
            }

            return
            #,scala:$scalaVersion
            set compileEnv [exec.cmdGetBashEnv coursier.setup -q --env --jvm $jvmVersion -e $scalaVersion --apps ammonite:$ammVersion]

            log.info "Ammonite env: $compileEnv"

            exec.withEnv $compileEnv {
                exec.run scala --version
                exec.run amm $scriptFile

            }

        }


    }

    ###################
    ## SCala REPL and CLI
    ####################
    kissb.extension scala {

        repl args {
            scala.runner
        }
        runner args {
            log.info "Running Scala Runner, installing scala=${::scala.default.version},jvm=${::scala.default.jvm}"
            coursier.init
            exec.withEnv [scala.defaultRunEnv] {
                exec.run scala --version
                exec.run scala {*}$args
            }
        }

        script file {

        }

    }

    ################################
    ## Bloop
    ################################
    namespace eval bloop {

        vars.define bloop.version 2.0.10
        vars.define bloopVersion 2.0.10

        proc getBloopEnv module {

            return [exec.cmdGetBashEnv coursier.setup -q --env \
                            --jvm [vars.resolve ${module}.jvm.name] \
                            --apps bloop:[vars.resolve ${module}.bloop.version ${::bloop.version}]]
        }


        kissb.extension bloop {


            config {module} {
                # Configure module for bloop usage

                set compileEnv [::scala::getScalaEnv $module]

                # Dependend builds based on module hierarchy
                set splitModule [split $module /]
                set moduleDependencies {}
                if {[llength $splitModule]>1} {
                    lappend moduleDependencies [java::getModuleBuildName [lindex $splitModule end-1]]
                }

                # Resolve deps
                coursier::resolveModule $module
                set deps [kiss::dependencies::resolveDeps $module lib]

                # Compiler Jars and options
                set compilerJars    [coursier.fetch.classpath.of org.scala-lang:scala3-compiler_3:[vars.resolve ${module}.scala.version]]
                set compilerOptions [vars.resolve ${module}.scalac.args]

                set bloopName [java::getModuleBuildName $module]

                #scala           [list [list version [vars.get ${module}.scala.version]]] -${module}
                files.mkdir .bloop/
                kiss::json::write .bloop/${bloopName}.json  [subst {
                    version 1.4.0
                    project {
                        name            ${bloopName}
                        directory       [file normalize [pwd]]
                        workspaceDir    [file normalize [pwd]]
                        sources::       [lmap src [kiss::sources::getSourceFolders $module] { file normalize $src }]
                        resources::     {}
                        dependencies::  [list $moduleDependencies]
                        classpath::     [list $deps]
                        out             [file normalize [vars.get ${module}.build.directory]]
                        classesDir      [file normalize [vars.get ${module}.build.directory]/classes]
                        scala           [list [list version [vars.resolve ${module}.scala.version] organization org.scala-lang name scala-compiler options:: $compilerOptions jars:: $compilerJars ]]
                        platform        {
                            name "jvm"
                            config {
                                home     [dict get $compileEnv JAVA_HOME value]
                                options:: {}
                            }
                            mainClass:: {}
                        }
                    }
                }]


            }

            compile {module} {
                # Compile via bloop

                set bloopEnv [::scala::bloop::getBloopEnv $module]
                exec.withEnv $bloopEnv {
                    exec.run bloop compile [java::getModuleBuildName $module]
                }
            }

            projects args {
                # Run bloop projects command

                exec.withEnv [::scala::bloop::getBloopEnv main] {
                    exec.run bloop projects
                }
            }

            run {module main args} {
                # Run module's main class via bloop

                exec.withEnv [::scala::bloop::getBloopEnv main] {
                    exec.run bloop run [java::getModuleBuildName $module] -m $main {*}$args
                }
            }

        }
    }

}

namespace eval scalatest {

    set version 3.2.19
}
