# SPDX-FileCopyrightText: 2024 KISSB
#
# SPDX-License-Identifier: Apache-2.0

package provide kissb.internal.tls 1.0

## Setup TLS
package require http


namespace eval kissb::tls {

    vars.set kissb.tls.home [files.getScriptDirectory]

    vars.set kissb.tls.available false
    if {![catch {package require tls}]} {
        vars.set kissb.tls.available true


        ## If we are in ZIPFS, write the CACert to a temp file for the library to be able to use it
        set cacert ${::kissb.tls.home}/certs/cacert.pem
        if {${::kissb.distribution}=="kit"} {
            set caCertFd [file tempfile cacert kissb-cacert.pem]
            puts $caCertFd [files.read ${::kissb.tls.home}/certs/cacert.pem]
            close $caCertFd
        }

        log.debug "TLS Version:[package require tls], CA Certs: $cacert"

        # /etc/ssl/ca-bundle.pem
        http::register https 443 [list ::tls::socket -autoservername true -require true -cafile $cacert  -command ::kissb::tls::cb]
    } else {
        log.warn "Requested TLS Support but TCL TLS module could not be loaded"
    }


    proc cb args {

        #puts "TLS CB: $args"
    }

    proc httpProgress {token total current} {

        #log.info "Download Progress $total/$current"
        if {$total != 0 && $current != 0} {
            set progress [expr int((${current}.0/${total}.0)*100) ]

            #log.flush
            #log.resetLine

            #::term::ansi::send::esol
            #::term::ansi::send::sda_bggreen
            ::term::ansi::send::el
            puts -nonewline "\r"
            puts -nonewline "Download Progress: [log.boldString ${progress}%]"
            flush stdout
            if {$progress == 100} {
                puts ""
            }

        }

        return
    }

    proc downloadTo {url output} {

        # Out Channel
        set outputChan [open $output w+]


        set token [::http::geturl $url -channel $outputChan -progress ::kissb::tls::httpProgress]
        set info [::http::responseInfo $token]
        if {[dict get $info redirection]!=""} {
            set redirect [dict get $info redirection]
            log.debug "Redirecting to: $redirect"
            close $outputChan
            downloadTo $redirect $output
        }
        #log.info "Download result: [::http::responseCode $token]"

        #set token [exec.call wget -O - $versionInfo > /dev/null]
        #puts "Out: [lindex [array get $token body] 1]"
        #set versionTxt  [split [lindex [array get $token body] 1]]
    }



}

#set localCertDir [string map {/ \\} [file normalize ${::kissb.home}/ca-certificates]]
#set localCertDir [file normalize ${::kissb.home}/ca-certificates]



#log.info "TLS Cert dir: [file dirname [info script]]/certs"
#files.mkdir $localCertDir
#files.require $localCertDir/20240203 {
#    log.info "Installing TLS Certs from dir: [file dirname [info script]]/certs"
#    foreach cert [glob [file dirname [info script]]/certs/*] {
#        files.cp $cert $localCertDir
#    }
#    files.writeText $localCertDir/20240203 DONE
#}



#http::register https 443 [list ::tls::socket -autoservername true -require true -cadir [file dirname [info script]]/certs]
