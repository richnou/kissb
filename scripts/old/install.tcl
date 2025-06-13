package require http 
package require tls

http::register https 443 [list ::tls::socket -autoservername true -require true -cadir /etc/ssl/certs]

######################################################
## Utilities
###########################################

#####################################################
## Main 
######################################################

## Variables
set kissb.version   1.0.0-beta1
set kissb.track     dev
set kissb.home      $::env(HOME)/.kissb/install/${kissb.track}

puts "Installation of KISSB from track ${kissb.track} into ${kissb.home}"
file mkdir ${kissb.home}
if {[file exists ${kissb.home}]} {
    # List existing installation in case one exists
    set existingInstall [lindex [lsort [glob -type d -nocomplain ${kissb.home}/kissb-*]] 0]
    if {$existingInstall != ""} {
        puts "An installation already exists: $existingInstall"
    } else {
        puts "No installation detected"

        # Get latest version
        set token [::http::geturl https://kissb.s3.de.io.cloud.ovh.net/kissb/${kissb.track}/${kissb.track}.json]
        set versionJson [lindex [array get $token body] 1]
        puts "Got res: $versionJson"

        regexp {"version"\s*:\s*([0-9]+)} $versionJson -> currentVersion
        puts "Latest version: $currentVersion"

        # Install
        ########
        cd ${kissb.home}
        set fileName dist-${currentVersion}.zip
        set outputFile [open $fileName w+]
        try {
            set urlFileName https://kissb.s3.de.io.cloud.ovh.net/kissb/${kissb.track}/${currentVersion}/$fileName
            puts "Downloading: $urlFileName"
            ::http::geturl https://kissb.s3.de.io.cloud.ovh.net/kissb/${kissb.track}/${currentVersion}/$fileName -channel $outputFile
        } finally {
            close $outputFile
        }

        # unzip/link/clean
        try {
            exec unzip $fileName
            file delete current
            file link current kissb-$currentVersion
        } finally {
            foreach toDelete [glob *.zip] { file delete $toDelete}
        }
        
        # Add to PATH
        puts "Add the folder [pwd]/current/bin to your path"
        puts "export PATH=\"[pwd]/current/bin:\$PATH\""
        #puts "Do you want to add to your .bashrc script? \[y/N\] default=N"
        #set answer [read stdin 1]
        #if {$answer=="y"} {
        #    exec echo "export PATH=\"[pwd]/current/bin:\$PATH\"" >> ~/.bashrc
        #    puts "-> Added"
        #}
         
    }
}