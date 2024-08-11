# SPDX-FileCopyrightText: 2024 KISSB 2024
#
# SPDX-License-Identifier: GPL-3.0-or-later

package provide kissb.internal.tls 1.0

set localCertDir [string map {/ \\} [file normalize ${::kissb.home}/ca-certificates]]
set localCertDir [file normalize ${::kissb.home}/ca-certificates]

## Setup TLS
package require http 
package require tls

#log.info "TLS Cert dir: [file dirname [info script]]/certs"
files.mkdir $localCertDir
files.require $localCertDir/20240203 {
    log.info "Installing TLS Certs from dir: [file dirname [info script]]/certs"
    foreach cert [glob [file dirname [info script]]/certs/*] {
        files.cp $cert $localCertDir
    }
    files.writeText $localCertDir/20240203 DONE
}



#http::register https 443 [list ::tls::socket -autoservername true -require true -cadir [file dirname [info script]]/certs]
log.info "CA Certs: $localCertDir "
http::register https 443 [list ::tls::socket -autoservername true -require true -cadir $localCertDir]