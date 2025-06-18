# SPDX-FileCopyrightText: 2024 KISSB
#
# SPDX-License-Identifier: Apache-2.0

package provide kissb.netlify 1.0
package require kissb.nodejs

namespace eval netlify {

    set netlifyCliPath ".kb/toolchain/netlify-cli/node_modules/.bin/netlify"

    # Toolchain and Login
    kiss::toolchain::register netlify-cli {

        log.info "Loading Netlify CLI in: $toolchainFolder"

        set ::netlify::netlifyCliPath $toolchainFolder/node_modules/.bin/netlify

        ## Install netlify
        files.requireOrRefresh $::netlify::netlifyCliPath NETLIFY {
            files.inDirectory $toolchainFolder {
                log.info "Installing Netlify CLI"
                files.delete node_modules package.json package-lock.json
                npm.exec i --save netlify-cli
            }
            #exec.run.in $toolchainFolder npm i --save netlify-cli
        }
        #refresh.with NETLIFY {
        #    log.info "Updating Netlify CLI"
        #    files.inDirectory $toolchainFolder {
        #        npm.exec update --save
        #    }
        #   # exec.run.in $toolchainFolder npm update --save
        #}

    }




    kissb.extension netlify {

        init args {
            node.init
            kiss::toolchain::init netlify-cli

        }

        run args {
           node.withEnv { exec.run $::netlify::netlifyCliPath {*}$args }
        }
    }

}
