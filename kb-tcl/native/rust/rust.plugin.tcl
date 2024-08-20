package provide kissb.rust 1.0


namespace eval rust {


    kiss::toolchain::register rustup {

        files.require [file normalize ~/.cargo/bin/rustup] {

            log.info "Installing for linux..."
            files.inDirectory $toolchainFolder {
                
                try {
                    files.download https://static.rust-lang.org/rustup/dist/x86_64-unknown-linux-gnu/rustup-init rustup-init
                    files.makeExecutable ./rustup-init
                    exec.run ./rustup-init --no-modify-path -y
                } finally {
                    catch {files.delete rustup-init}
                }
            }

            refresh.with RUST {
                exec.withEnv [rust.getEnv] {
                    exec.run rustup update
                }
            }
        }

    }
    kissb.extension rust {

        getEnv args {
            return [list PATH [list value [file normalize ~/.cargo/bin] merge 1]]
        }
        init args {
            kiss::toolchain::init rustup
        }

        rustc args {
            puts "RUST env: [rust.getEnv]"
            exec.withEnv [rust.getEnv] {
                exec.run rustc {*}$args
            }
        }
    }
}