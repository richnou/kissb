package require kissb.internal.tls


set versionInfo https://kissb.s3.de.io.cloud.ovh.net/kissb/${::kissb.track}/${::kissb.track}.txt
log.info "Checking for new version from $versionInfo..."

set token [::http::geturl $versionInfo]
puts "Out: [lindex [array get $token body] 1]"
 