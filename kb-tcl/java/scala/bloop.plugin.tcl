################################
## Bloop
################################
namespace eval bloop {

    vars.define bloop.version -doc "Bloop version used by toolchain installer" 2.0.10

    kissb.extension bloop {

        getBloopEnv module {

            return [exec.cmdGetBashEnv coursier.setup -q --env \
                            --jvm [vars.resolve ${module}.jvm.name] \
                            --apps bloop:[vars.resolve ${module}.bloop.version ${::bloop.version}]]
        }

        exec {module args} {
            exec.withEnv [bloop.getBloopEnv $module] {
                exec.run bloop {*}$args
            }
        }

        config {module} {
            # Configure module for bloop usage

            log.info "Bloop: configuring for module $module"
            set compileEnv [scala.getModuleEnv $module]

            # Module dependencies
            set moduleDependencies {}
            set moduleCPDependencies {}
            foreach depModule [vars.get ${module}.moduleDependencies] {
                lappend moduleDependencies [java::getModuleBuildName  $depModule]
                lappend moduleCPDependencies  [vars.get ${depModule}.build.classes]
                # Set module dependency as classpath output
                #lappend moduleDependencies [vars.get ${depModule}.build.classes]

            }

            # Resolve deps
            #coursier::resolveModule $module
            #set deps [kiss::dependencies::resolveDeps $module lib]


            set deps [scala.resolveDeps $module -scopes {compile runtime}]

            # Compiler Jars and options
            set compilerJars    [coursier.fetch.classpath.of org.scala-lang:scala3-compiler_3:[vars.resolve ${module}.scala.version]]
            set compilerOptions [vars.resolve ${module}.scalac.args]

            set bloopName [java::getModuleBuildName $module]

            log.info "Source folders for $module: [kiss::sources::getSourceFolders $module]"
            # [lmap src [kiss::sources::getSourceFolders $module] { file normalize $src }]

            #scala           [list [list version [vars.get ${module}.scala.version]]] -${module}
            #classpath::     [list [concat $moduleCPDependencies $deps]]
            files.mkdir .bloop/
            kiss::json::write .bloop/${bloopName}.json  [subst {
                version 1.4.0
                project {
                    name            ${bloopName}
                    directory       [vars.get ${module}.baseDir]
                    workspaceDir    [file normalize [pwd]]
                    sources::       [list [kiss::sources::getSourceFolders $module]]
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
                    test {
                        frameworks:: {
                            {
                                names:: { "org.scalacheck.ScalaCheckFramework" }

                            }
                            {
                                names:: {
                                    "org.specs2.runner.Specs2Framework"
                                    "org.specs2.runner.SpecsFramework"
                                }
                            }
                            {
                                names:: {
                                    "org.specs.runner.SpecsFramework"
                                }
                            }
                            {
                                names:: {
                                    "org.scalatest.tools.Framework"
                                    "org.scalatest.tools.ScalaTestFramework"
                                }
                            }
                            {
                                names:: {
                                    "com.novocode.junit.JUnitFramework"
                                }
                            }
                            {
                                names:: {
                                    "munit.Framework"
                                }
                            }
                            {
                                names:: {
                                    "zio.test.sbt.ZTestFramework"
                                }
                            }
                            {
                                names:: {
                                    "weaver.framework.CatsEffect"
                                }
                            }
                            {
                                names:: {
                                    "hedgehog.sbt.Framework"
                                }
                            }
                        }
                        options {
                            excludes:: {}
                            arguments:: {}
                        }
                    }
                }
            }]


        }

        compile {module} {
            # Compile via bloop


            exec.withEnv [bloop.getBloopEnv $module] {
                exec.run bloop compile [java::getModuleBuildName $module]
            }
        }

        projects {{module "main"}} {
            # Run bloop projects command

            exec.withEnv [bloop.getBloopEnv $module] {
                exec.run bloop projects
            }
        }

        run {module main args} {
            # Run module's main class via bloop

            exec.withEnv [bloop.getBloopEnv $module] {
                exec.run bloop run [java::getModuleBuildName $module] -m $main {*}$args
            }
        }

    }
}
