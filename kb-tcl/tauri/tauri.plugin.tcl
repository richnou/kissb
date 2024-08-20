package provide kissb.tauri 1.0
package require kissb.rust
package require kissb.nodejs

namespace eval tauri {

    #vars.set tauri.version
    set tauriCliPath ""

    kiss::toolchain::register tauri-cli {


        #npm install --save-dev @tauri-apps/cli
        log.info "Loading Tauri CLI in: $toolchainFolder"
        set tauriVersion [vars.resolve tauri.version]

        set tauri::tauriCliPath $toolchainFolder/${tauriVersion}/node_modules/.bin/tauri

        ## Install venv
        files.require $tauri::tauriCliPath {
            exec.run.in $toolchainFolder/${tauriVersion} npm i --save @tauri-apps/cli
        }
        refresh.with TAURI {
            log.info "Updating Tauri CLI"
            exec.run.in $toolchainFolder/${tauriVersion} npm update --save
        }

        tauri.run --version
    }

    kissb.extension tauri {

        init args {
            kiss::toolchain::init tauri-cli
            rust.init 
            node.init

            ## Ensure tauri app and tauri cli are installed in the current project
            npm.package.present @tauri-apps/api ^1
        }

        run args {
            node.withEnv {
                exec.withEnv [rust.getEnv] {
                    exec.run $tauri::tauriCliPath {*}$args
                }
            }
            
        }

        create args {
            exec.withEnv [rust.getEnv] {
                node.withEnv {
                    exec.run npm create tauri-app@latest
                }   
            }
        }

        dev args {
            tauri.run dev
        }

        build args {
            tauri.run build
        }
    }
}