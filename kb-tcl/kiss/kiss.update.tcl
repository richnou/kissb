# SPDX-FileCopyrightText: 2024 KISSB
#
# SPDX-License-Identifier: Apache-2.0

package provide kissb.internal.update 1.0
package require kissb.internal.tls

namespace eval kissb::internal::update {

    proc run args {
        
        # Parameters
        env KISSB_WRAPPER 0


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