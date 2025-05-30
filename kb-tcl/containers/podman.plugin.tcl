# SPDX-FileCopyrightText: 2024 KISSB
#
# SPDX-License-Identifier: Apache-2.0

package provide kissb.podman 1.0


namespace eval podman {

    kissb.extension podman {

        run args {
            exec.run podman run {*}$args
        }

        build args {
            exec.run podman build {*}$args
        }

        push args {
            exec.run podman push {*}$args
        }

        buildold {outputFile on os with script} {

            uplevel [list set os $os]
            set terminalScript [uplevel [list subst $script]]
            files.requireOrForce $outputFile {
                log.info "Building $outputFile"
                builder.podman.run $os $terminalScript
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
