# SPDX-FileCopyrightText: 2024 KISSB
#
# SPDX-License-Identifier: Apache-2.0

package provide kissb.docker 1.0

namespace eval docker {

    kissb.signal.onSIGINT {
        log.debug "Killing Docker container on SIGINT"
        catch { exec.run docker kill kiss-running }
    }

    kissb.extension docker {

        run args {
            exec.run docker run {*}$args
        }

        build args {
            exec.run docker build {*}$args
        }

        push args {
            exec.run docker push {*}$args
        }

        run.script {image args} {
            set script [lindex $args end]
            set terminalScript [uplevel [list subst $script]]
            try {
                files.writeText .dockerRun $terminalScript
                set extraArgs [env KB_DOCKER_ARGS {}]

                ## Gather parameters
                kissb.args.get -workdir "." -> __workdir
                kissb.args.get -workdirPath /build -> __workdirPath
                kissb.args.get -args {} -> passedArgs
                kissb.args.get -cmdArgs {} -> cmdArgs

                foreach {name value} [kissb.args.get -env {}] {
                    lappend extraArgs -e ${name}=$value
                }
                puts "ENV: [kissb.args.get -env {}]"

                ## Run
                exec.run echo "$terminalScript" | docker run --rm --name kiss-running -u [exec id -u]:[exec id -g] -i -v${__workdir}:${__workdirPath} {*}$passedArgs  {*}$extraArgs --entrypoint /bin/bash {*}$cmdArgs $image

            } on error {err options} {
                catch {exec.call docker kill kiss-running}
                #puts "ERR: $options"
                #error $err $options

                #catch {exec.run docker rm kiss-running}
                return -options $options $err
            }
        }

        image.build {dockerFile tag} {
            docker.build -f $dockerFile -t $tag [pwd]
        }

        image.run {image args} {
            set script [lindex $args end]
            set terminalScript [uplevel [list subst $script]]
            try {
                files.writeText .dockerRun $terminalScript
                set extraArgs [env KB_DOCKER_ARGS {}]

                ## Gather parameters
                kissb.args.get -workdir "." -> __workdir
                kissb.args.get -workdirPath /build -> __workdirPath
                kissb.args.get -args {} -> passedArgs
                kissb.args.get -imgArgs {} -> imgArgs

                foreach {name value} [kissb.args.get -env {}] {
                    lappend extraArgs -e ${name}=$value
                }
                puts "ENV: [kissb.args.get -env {}]"

                ## Run
                docker.run --rm --name kiss-running -u [exec id -u]:[exec id -g] -i -v${__workdir}:${__workdirPath} {*}$passedArgs  {*}$extraArgs $image {*}$imgArgs

            } on error {err options} {
                catch {exec.call docker kill kiss-running}
                #puts "ERR: $options"
                #error $err $options

                #catch {exec.run docker rm kiss-running}
                return -options $options $err
            }
        }


        compose.withUP script {

            # Runs the script with docker compose UP
            try {
                docker.run compose up -d --wait
                uplevel [list eval $script]
            } finally {
                #docker.run compose down
            }

        }


        compose.withUPDown script {
            # Runs the script with docker compose UP then run compose down after the script ran
            try {
                docker.run compose up -d --wait
                uplevel [list eval $script]
            } finally {
                docker.run compose down
            }

        }

    }

}
