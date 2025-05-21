# SPDX-FileCopyrightText: 2024 KISSB
#
# SPDX-License-Identifier: Apache-2.0

package provide kissb.builder.container 1.0

namespace eval builder::container {

    set runtimeCommand "podman"
    set builderImagePrefix "rleys/builder:"

    vars.define builder.container.docker.detected false
    vars.define builder.container.podman.detected false
    vars.define builder.container.runtime false

    kissb.extension builder.container {

        init args {
            ## Check Podman/Docker
            try {
                vars.set builder.container.docker.detected [exec.call docker version]
            } on error args {
                vars.set builder.container.docker.detected false
            }
            try {
                vars.set builder.container.podman.detected [exec.call podman -v]
            } on error args {
                vars.set builder.container.podman.detected false
            }



            ## Select
            if { ${::builder.container.podman.detected} != false } {
                package require kissb.podman
                vars.set builder.container.runtime podman
            } elseif {${::builder.container.docker.detected} != false } {
                package require kissb.docker
                vars.set builder.container.runtime docker
            }

            log.info "Image builder, selected runtime=${::builder.container.runtime}"
        }

        isDocker args {
            return [expr {${::builder.container.runtime}==docker} ? true : false]
        }

        isPodman args {
            return [expr {${::builder.container.runtime}==docker} ? true : false]
        }

    }

    kissb.extension builder.container.image {

        selectDockerRuntime args {
            set ::builder::podman::runtimeCommand docker
            set a test
        }

        build {dockerFile tag} {
            switch ${::builder.container.runtime} {
                docker {
                    docker.build -f $dockerFile -t $tag .
                }

                podman {
                    podman.build -f $dockerFile -t $tag .
                }
            }
        }

        push {image {destination ""}} {
            switch ${::builder.container.runtime} {
                docker {
                    docker.push $image $destination
                }

                podman {
                    podman.push $image $destination
                }
            }
        }

        run {tag script} {
            set terminalScript [uplevel [list subst $script]]
            try {
                files.writeText .dockerRun $terminalScript
                set extraArgs [env KB_DOCKER_ARGS {}]
                exec.run echo "$terminalScript" | ${builder::podman::runtimeCommand} run --rm --name kiss-running -u [exec id -u] -i -v.:/build {*}$extraArgs $tag /bin/bash
            } on error e {
                catch {exec run ${builder::podman::runtimeCommand} stop kiss-running}
                catch {exec run ${builder::podman::runtimeCommand} rm kiss-running}
                log.error "Cannot run image $tag : $e"
            }

        }
    }

    kissb.extension builder.podman {

        run {os script} {

            uplevel [list set os $os]
            set terminalScript [uplevel [list subst $script]]
            # -u [exec id -u]
            exec.run echo "$terminalScript" | ${builder::podman::runtimeCommand} run  -u [exec id -u] -i -v.:/build ${builder::podman::builderImagePrefix}$os /bin/bash

        }


    }

}
