# SPDX-FileCopyrightText: 2024 KISSB
#
# SPDX-License-Identifier: Apache-2.0

package provide kissb.internal.update 1.0
package require kissb.internal.tls

namespace eval kissb::internal::update {

    proc isUpdateAvailable args {

        try {
            set versionInfo https://kissb.s3.de.io.cloud.ovh.net/kissb/${::kissb.track}/${::kissb.track}.txt
            log.info "Checking for new version from $versionInfo"

            # Get latest version
            set token [::http::geturl $versionInfo]
            #set token [exec.call wget -O - $versionInfo > /dev/null]
            #puts "Out: [lindex [array get $token body] 1]"
            set versionTxt  [split [lindex [array get $token body] 1]]
            puts "Version: $versionTxt"
            set version     [lindex [split $versionTxt " "] 1]

            if {$version > ${::kissb.version}} {
                log.success "A new version is available: $version"
                return $version
            } else {
                log.success "No update available"
                return false
            }
        } on error {msg options} {
            set stack [dict get $options -errorinfo]
            puts $stack
        }

        #if {[::kiss::utils::isWindows]} {
        #    set versionJson [split [exec.call wget -q -O - $versionInfo] ]
        #} else {
        #    set versionJson [split [exec.call wget -q -O - $versionInfo 2> /dev/null] ]
        #}

    }
    proc run args {

        # Parameters
        env KISSB_WRAPPER 0

        log.info "KISSB distribution type: ${::kissb.distribution}"

        # Detect installation type
        #########
        switch ${::kissb.distribution} {

            portable {

                if {[isUpdateAvailable] != false} {
                    log.warn "You are running a portable installation at ${::kissb.binFolder}, please update manually by updating the installation folder"
                }


            }

            kit {
                set newVersion [isUpdateAvailable]
                if {$newVersion != false} {
                    if {${::KISSB_WRAPPER}==1} {
                        log.warn "You are running KISSB via Wrapper, please update the version number in the wrapper script"
                    } else {

                        set exeToUpdate [info nameofexecutable]
                        log.warn "Updating KISSB Single File Runtime at: $exeToUpdate"
                        puts -nonewline [log.warnColored "Do you want to proceed? (y/n,default=n)"]
                        flush stdout
                        gets stdin response
                        if {$response=="y"} {

                            # Backup original
                            set backupFile [file dirname $exeToUpdate]/[file tail $exeToUpdate].${::kissb.version}-backup
                            log.success "Backing up $exeToUpdate"
                            files.cp $exeToUpdate backupFile


                            set targetExe $exeToUpdate
                            set targetExe [file dirname $exeToUpdate]/kissb-$newVersion

                            ::kissb::tls::downloadTo https://kissb.s3.de.io.cloud.ovh.net/kissb/${::kissb.track}/$newVersion/kissb-$newVersion $targetExe

                            # Rename (will replace the actual file after process exists)
                            if {[os.isLinux]} {
                                file attributes $targetExe -permissions u+x
                            }
                            file rename -force $targetExe $exeToUpdate

                            # Success
                            log.warn "Update complete, please restart KISSB now"
                            #::kissb::tls::downloadTo https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.7%2B6/OpenJDK21U-jdk_x64_linux_hotspot_21.0.7_6.tar.gz [file dirname $exeToUpdate]/kissb-$newVersion




                        }
                    }
                }
            }

            package {
                if {[isUpdateAvailable] != false} {
                    log.warn "You are running KISSB via a system package, please update using your distribution packaging"

                }
            }
            default {
                log.error "Unknown KISSB Distribution type ${::kissb.distribution}  cannot update"
            }
        }
        #set exe [info nameofexecutable]
        #log.info "Exe: $exe"
        #log.info "Running from kissb wrapper"


        return

        set versionInfo https://kissb.s3.de.io.cloud.ovh.net/kissb/${::kissb.track}/${::kissb.track}.txt
        log.info "Checking for new version from $versionInfo..."



        ##package require http
        ##package require tls

        ##http::register https 443 [list ::tls::socket -autoservername true -require true -cadir /etc/ssl/certs]


        # Get latest version
        #set token [::http::geturl $versionInfo]
        #set token [exec.call wget -O - $versionInfo > /dev/null]
        #puts "Out: [lindex [array get $token body] 1]"
        #set versionJson [split [lindex [array get $token body] 1]]

        if {[::kiss::utils::isWindows]} {
            set versionJson [split [exec.call wget -q -O - $versionInfo] ]
        } else {
            set versionJson [split [exec.call wget -q -O - $versionInfo 2> /dev/null] ]
        }

        #puts "Out: $versionJson"
        set version [lindex $versionJson 1]
        log.info "Latest version: $version"
        log.info "Running from wrapper: ${::KISSB_WRAPPER}"
        catch  {
            if {[expr $version > ${::kissb.version}]} {
                log.success "A new version is available: $version"
                log.info "Running from wrapper: ${::KISSB_WRAPPER}"
                if {${::KISSB_WRAPPER}==1} {
                    log.warn "You are running KISSB via Wrapper, please update the version number in the wrapper script"
                }
            } else {
                log.success "No new version available"
            }
        }
    }

}
