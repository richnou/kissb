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

    vars.define scalac.env.args {}

    proc getScalaEnv module {

        return [exec.cmdGetBashEnv coursier.setup -q --env \
                        --jvm [vars.resolve ${module}.jvm.name] \
                        --apps scala:[vars.resolve ${module}.scala.version],scalac:[vars.resolve ${module}.scala.version]]
    }

    ## Scala Extensions to build projects
    # #module {m version args} {
    #    scala.init $m -scala $version {*}$args
    #}
    kissb.extension scala {




        init {module args} {
            # Init project module  with versions version

            set scalaversion [kissb.args.get -scala ${::scala.default.version}]
            set baseDir      [file normalize [kissb.args.get -baseDir [pwd]]]
            set jvmVersion   [kissb.args.get -jvm-version ${::jvm.default.version}]
            set jvmName      [kissb.args.get -jvm-name ${::jvm.default.version}]
            set srcDirs      [kissb.args.get -srcDirs {src/main/java src/main/scala}]

            log.info "Init Scala module=$module,version=$scalaversion,directory=$baseDir"

            ## Set Version
            log.info "Selecting Scala $scalaversion"
            coursier.install -q scala:$scalaversion scalac:$scalaversion


            vars.set ${module}.name             $module
            vars.set ${module}.scala.major      [lindex [split $scalaversion .] 0]
            vars.set ${module}.scala.version    $scalaversion


            vars.set ${module}.baseDir          $baseDir
            vars.set ${module}.build.directory  [file normalize ${::scala::buildBaseFolder}/$scalaversion/$module]
            vars.set ${module}.build.classes    [file normalize [vars.get ${module}.build.directory]/classes]

            vars.set ${module}.scalac.args      [concat {-deprecation -unchecked} ${::scalac.env.args}]
            vars.set ${module}.javac.args       [concat { } ${::javac.env.args}]
            vars.set ${module}.jvm.target       [kissb.args.get -target $jvmVersion]

            vars.set ${module}.jvm.runtime      $jvmVersion
            vars.set ${module}.jvm.name         $jvmName

            vars.ensure ${module}.moduleDependencies {}

            ## Add Folders
            ## Default behaviour to add *java and * scala
            foreach srcDir $srcDirs {
                set folder [files.makeAbsoluteTo $srcDir $baseDir]
                if {[file exists $folder]} {
                    log.info "Adding source folder $folder"
                    sources.add $module $folder
                } else {
                    log.warning "Requested scala source dir $srcDir doesn't exist"
                }
            }
            #foreach folder [files.globFolders $baseDir/src/main/*] {
            #    log.info "Adding source folder $folder"
            #    sources.add $module $folder
            #}



            #kiss::sources::addSourceFolder $module src/main/scala
            #sources.add $module $baseDir/src/main/scala
            #foreach folder [kissb.args.get -src {}] {
            #    assert.isFolder $folder "Requested source folder $folder doesn't exist"
            #    sources.add $module $folder
            #}

            ## Add Stdlib
            #kiss::dependencies::addDepSpec $module org.scala-lang:scala3-library_[vars.get ${module}.scala.major]:[vars.get ${module}.scala.version] coursier
            dependencies.add $module coursier org.scala-lang:scala3-library_[vars.get ${module}.scala.major]:[vars.get ${module}.scala.version]
        }

        defaultRunEnv args {
            # Runs coursier to get default scala and jvm versions set in this plugin
            # Returns an environment dict that can be used by the exec module to run scala command line or scalac
            return [exec.cmdGetBashEnv coursier.setup \
                    -q \
                    --env --jvm [vars.resolve jvm.default.version] \
                    --apps scala:[vars.resolve scala.default.version],scalac:[vars.resolve scala.default.version]]
        }

        getModuleEnv module {
            # Runs couriser to get scala and jvm path environment for the provided module
            # Returns an environment dict that can be used by the exec module to run scala command line or scalac
            assert [vars.exists ${module}.name] "Scala module $module doesn't exist"
            return [exec.cmdGetBashEnv coursier.setup -q --env \
                            --jvm [vars.resolve ${module}.jvm.name] \
                            --apps scala:[vars.resolve ${module}.scala.version],scalac:[vars.resolve ${module}.scala.version]]
        }

        addDependencies {module args} {
            # Add dependencies to specified module
            # If a dependency is named @xxxx it will refer to another project module

            foreach dep {*}$args {

                if {[string match @* $dep]} {
                    log.info "Adding module dependency $dep to $module"
                    vars.append ${module}.moduleDependencies [string range $dep 1 end]
                } else {
                    log.debug "Adding dependency $dep to $module"
                    dependencies.add $module coursier $dep
                }
            }

        }

        jvm {module version {descriptor ""}} {
            # Select the JVM version for the application module


            vars.set ${module}.jvm.runtime $version
            if {$descriptor==""} {
                vars.set ${module}.jvm.name $version
            } else {
                vars.set ${module}.jvm.name $descriptor
            }
            coursier.env java --jvm [vars.get ${module}.jvm.name] -q
        }

        resolveDeps {module args} {
            # Returns list of dependencies, including module dependencies output build directory in classpath
            # If -classpath if passed, module's own classes output is added to the results to generate a full classpath
            #  -classpath - Pass  to add module's output class directory to list of dependencies

            # Resolve deps
            ########
            coursier::resolveModule $module
            set deps [kiss::dependencies::resolveDeps $module lib]



            # Add Module dependencies
            # - Add output classes of module, and resolved dependencies
            set moduleCPDependencies {}
            log.info "Module depends on other modules=[vars.get ${module}.moduleDependencies]"
            foreach depModule [vars.get ${module}.moduleDependencies] {

                coursier::resolveModule $depModule
                set depModuleDeps [kiss::dependencies::resolveDeps $depModule lib]

                log.debug "- $depModule classes=[vars.get ${depModule}.build.classes],libs=$depModuleDeps"
                lappend deps  [vars.get ${depModule}.build.classes]

                #set deps [concat $deps $depModuleDeps]
                lappend deps {*}$depModuleDeps
            }

            log.debug "Deps: $deps"


            # Classes output -> directory or jar
            ######
            kissb.args.contains -classpath {
                set classesOut [vars.resolve ${module}.build.classes]
                files.mkdir $classesOut
                lappend deps $classesOut
            }


            return $deps


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
            ########
            set deps     [scala.resolveDeps $module -classpath]
            log.debug "Deps: $deps"

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


            # Compile Sources in order
            ###########
            set depsJoined [files.joinWithPathSeparator $deps]


            set classesOut [vars.resolve ${module}.build.classes]


            foreach {baseFolder sourceFiles} [kiss::sources::getSourcesDict $module] {

                log.info "Compiling sources in $baseFolder"

                set scalaSources {}
                set javaSources {}
                foreach src $sourceFiles {
                    if {[string match *.java $src]} {
                        lappend javaSources [file normalize $baseFolder/$src]
                    } else {
                        lappend scalaSources [file normalize $baseFolder/$src]
                    }
                }

                log.debug "- Scala Sources to compile: $scalaSources"
                log.debug "- Java Sources to compile: $javaSources"

                try {
                    exec.withEnv $compileEnv {



                        if {[llength $javaSources]>0} {
                            exec.run javac -classpath $depsJoined -d $classesOut {*}[vars.get ${module}.javac.args] {*}$javaSources
                            log.success "Done compiling java in $baseFolder"

                        }

                        if {[llength $scalaSources]>0} {
                            exec.run scalac  -usejavacp -classpath $depsJoined -d $classesOut -java-output-version [vars.resolve ${module}.jvm.target] {*}[vars.get ${module}.scalac.args] {*}$scalaSources
                            log.success "Done compiling scala in $baseFolder"
                        }
                    }
                } on error {error stack} {
                    log.error "Compilation failed for $baseFolder ($error)"
                    #error "Compilation failed for $baseFolder"
                    throw SCALA.COMPILE.FAIL "Compilation failed for $baseFolder"
                    #throw SCALA.COMPILE.FAIL "compilation failed"
                }



            }


        }

        run {module mainClass args} {
            # Run module's provided main class - doesn't build

            ## Load scala with PATH
            set compileEnv [exec.cmdGetBashEnv coursier.setup -q --env --jvm [vars.get ${module}.jvm.name] --apps scala:[vars.get ${module}.scala.version],scalac:[vars.get ${module}.scala.version]]
            log.fine "Scala compile Env: $compileEnv"

            ## deps = deps + build folder
            set deps     [scala.resolveDeps $module -classpath]
            set depsPath [files.joinWithPathSeparator $deps]
            #set deps [files.joinWithPathSeparator [concat [kiss::dependencies::resolveDeps $module lib] [vars.get ${module}.build.directory]/classes ]]

            exec.withEnv $compileEnv {
                exec.run java -version
                exec.run java -classpath $depsPath $mainClass
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

    ## Bloop
    source [files.getScriptDirectory]/bloop.plugin.tcl

}

namespace eval scalatest {

    set version 3.2.19
}
