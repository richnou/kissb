# SPDX-FileCopyrightText: 2024 KISSB
#
# SPDX-License-Identifier: Apache-2.0

package provide kissb.proguard 1.0


namespace eval proguard {

    set baseVersion    7.7
    set version        7.7.0
    set baseFolder     ""

    kiss::toolchain::register proguard {

        files.inDirectory $toolchainFolder {

            files.require proguard-${::proguard::version}/bin/proguard.sh {
                files.download https://github.com/Guardsquare/proguard/releases/download/v${::proguard::baseVersion}/proguard-${::proguard::version}.zip
                try {
                    files.extract proguard-${::proguard::version}.zip
                } finally {
                    files.delete proguard-${::proguard::version}.zip
                }
            }

            set ::proguard::baseFolder $toolchainFolder/proguard-${::proguard::version}


        }



    }

    kissb.extension proguard {

        init args {
            kiss::toolchain::init proguard
        }

        runWithConfig {script args} {
            files.inDirectory .kb/proguard/run {
                files.writeText proguard.txt [uplevel [list subst $script]]

                exec.run ${::proguard::baseFolder}/bin/proguard.sh -include proguard.txt {*}$args
            }


        }

        jarWithDependencies {module args} {


            set jvmVersion  [vars.get ${module}.jvm.name 11]
            set javaEnv     [exec.cmdGetBashEnv coursier.setup -q --env --jvm $jvmVersion]
            coursier::resolveModule $module
            set deps        [kiss::dependencies::resolveDeps $module lib]
            set inJars      [files.joinWithPathSeparator [concat $deps [vars.resolve ${module}.build.directory]/classes ]]

            log.info "Packing JAR with classes: [vars.resolve ${module}.build.directory]/classes, java version $javaEnv"

            # -dontshrink
            # -dontoptimize
            exec.withEnv $javaEnv {
                proguard.runWithConfig {

                    -injars  $inJars
                    -outjars ${module}.jar
                    -libraryjars  <java.home>/jmods/java.base.jmod(!**.jar;!module-info.class)
                    -dontwarn
                    -keep public final class Test {
                        public static void main(java.lang.String\[\]);
                    }
                }
            }

        }
    }

}
