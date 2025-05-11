# SPDX-FileCopyrightText: 2024 KISSB
#
# SPDX-License-Identifier: Apache-2.0

package provide kissb.builder.rclone 1.0


namespace eval rclone {


    set version 1.67.0
    set binPath ""
    set localConfigFile {}

    vars.set rclone.config false

    ::kiss::toolchain::register rclone {

        set url https://downloads.rclone.org/v${::rclone::version}/rclone-v${::rclone::version}-linux-amd64.zip
        files.inDirectory $toolchainFolder {

            files.require $toolchainFolder/rclone-v${::rclone::version}-linux-amd64/rclone {
                files.download $url rclone-v${::rclone::version}-linux-amd64.zip
                files.unzip rclone-v${::rclone::version}-linux-amd64.zip
            }
            set ::rclone::binPath [file normalize $toolchainFolder/rclone-v${::rclone::version}-linux-amd64/rclone]
        }
        
        if {![file exists ${::rclone.config}]} {
            if {[file exists rclone.conf]} {
                vars.set rclone.config [file normalize rclone.conf]
            } elseif {[file exists ../rclone.conf]} {
                vars.set rclone.config [file normalize ../rclone.conf]
            }
        }
        
    }
    
    
    kissb.extension rclone {
        init args {
            if {[file exists [lindex $args 0]]} {
                vars.set rclone.config [file normalize  [lindex $args 0]]
            }
            ::kiss::toolchain::init rclone
        }

        run args {
            exec.run ${::rclone::binPath} --config ${::rclone.config} {*}$args
        }
        call args {
            exec.call ${::rclone::binPath} --config ${::rclone.config} {*}$args
        }
    }

}