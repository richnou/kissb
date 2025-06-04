
# Distribution
#####
package require kissb.files
package require kissb.builder.rclone

rclone.init

vars.define version 250502
vars.define track  dev

vars.define sign.defaultKey "E24253BA23A2452F"



@ reuse {

    package require kissb.reuse

    reuse.init

    reuse.download Apache-2.0 -github


    kissb.args.contains -headers {
        reuse.annotate.globs {kb-tcl/**/*.tcl kb-tcl/**/**/*.tcl kb-tcl/**/*.kb kb-tcl/**/**/*.kb} --style python -c "KISSB" --merge-copyrights -l Apache-2.0
    }

}


@ certs {

    # Use CA Cert from CURL
    set url https://curl.se/ca/cacert.pem

    files.delete kb-tcl/kiss/certs
    files.mkdir  kb-tcl/kiss/certs
    files.download $url kb-tcl/kiss/certs/cacert.pem

}

@ browse-s3 {

    rclone.run rcd --rc-web-gui --rc-web-gui-force-update

}

@ dist-zip {




    ## Create dist by copying all files to the build directory
    ## Overwrite the info.tcl file in the package folder to overwrite version
    set base [pwd]

    files.inDirectory .kb/build/dist/kissb-${::version} {

        puts "Base dir: $base - cwd: [pwd]"
        #file delete -force *
        file delete -force bin
        file copy -force $base/kb-tcl/bin .

        # coursier gradle java-ivy  kotlin
        foreach package {kiss  flows builder containers java liquibase mkdocs netlify nodejs tclkit python3 eda git licensing native tclkit pkgIndex.tcl globals.tcl} {
            file delete -force $package
            #file copy -force $base/kb-tcl/$package .
            exec.run rsync -a --exclude=*/_builder  $base/kb-tcl/$package .
        }

        ## Overwrite info
        files.writeText info.tcl "vars.set kissb.version ${::version} ; vars.set kissb.track ${::track}"

    }

    # Create Files
    log.info "Building zip"
    files.inDirectory .kb/build/dist/ {
        file delete -force $base/dist-${::version}.zip
        files.compressDir kissb-$::version $base/dist-${::version}.zip
    }

    log.info "Done building zip"

    ## Push to S3 - push the install script alone
    ########
    kissb.args.contains --release {

        ## Sign
        set checksumFile [files.sha256 dist-${::version}.zip]
        log.info "Checksum file: $checksumFile"
        files.delete ${checksumFile}.asc
        exec.run gpg --batch --local-user 0x${::sign.defaultKey} --output ${checksumFile}.asc --detach-sig $checksumFile
        exec.run gpg --verify ${checksumFile}.asc $checksumFile

        ## Push file
        json.write .kb/build/dist/${::track}.json {version ${::version}}
        files.writeText .kb/build/dist/${::track}.txt "version ${::version}"

        rclone.run copy -P --s3-acl=public-read .kb/build/dist/${::track}.json   ovhs3:kissb/kissb/${::track}/
        rclone.run copy -P --s3-acl=public-read .kb/build/dist/${::track}.txt ovhs3:kissb/kissb/${::track}/


        rclone.run copy -P --s3-acl=public-read $base/dist-${::version}.zip             ovhs3:kissb/kissb/${::track}/${::version}
        rclone.run copy -P --s3-acl=public-read $base/dist-${::version}.zip.sha256.asc  ovhs3:kissb/kissb/${::track}/${::version}

        log.success "Uploaded to S3: https://s3.de.io.cloud.ovh.net/kissb/${::track}/${::version}/dist-${::version}.zip"
    }


    return $base/dist-${::version}.zip

}

@ dist-docker {

    set zipFile [> dist-zip]

    puts "Test: $zipFile, args=$args"

    env IMAGE_NAME rleys/kissb
    env IMAGE_TAG ${::track}-${::version}

    kiss::files::inDirectory .kb/build/dist-docker/ {
        file copy -force ../../../dist/docker/Dockerfile .
        file copy -force $zipFile dist.zip
        exec.run podman build . -t ${::IMAGE_NAME}:${::IMAGE_TAG}
    }

    kissb.args.contains --release {
        exec.run podman push ${::IMAGE_NAME}:${::IMAGE_TAG}
    }


}

@ dist-kit {

    package require kissb.tcl9.kit

    # Make Zip release
    set zipFile [> dist-zip]

    #
    files.inDirectory .kb/build/dist-tclkit/ {

        ## Extract Kissb
        files.delete dist/kissb-*
        make dist/kissb-${::version}/pkgIndex.tcl : $zipFile {
            files.inDirectory dist {
                file copy -force $zipFile dist.zip
                files.extract dist.zip
                files.delete dist.zip
                files.writeText kissb-${::version}/10-kit.conf.tcl "vars.set kissb.distribution kit"
            }

        }

        ## Linux
        set kitFile [files.downloadOrRefresh https://kissb.s3.de.io.cloud.ovh.net/tcl9/dist1/250501/tcl9-dist1kit-x86_64-redhat-linux-rhel8-9.0.1-250501 tclkit]

        exec.run chmod +x $kitFile
        exec.run ./$kitFile dist/kissb-${::version}/tclkit/packager_run.tcl --continue --kit --name kissb-${::version} --main dist/kissb-${::version}/bin/kissb

        ## Windows
        #############

        files.delete dist-win/
        make dist-win/kissb-${::version}/pkgIndex.tcl : $zipFile {
            files.inDirectory dist-win {
                file copy -force $zipFile dist.zip
                files.extract dist.zip
                files.delete dist.zip
                files.writeText kissb-${::version}/10-kit.conf.tcl "vars.set kissb.distribution kit"
            }

        }

        set winkitFile [files.downloadOrRefresh https://kissb.s3.de.io.cloud.ovh.net/tcl9/dist1/250501/tcl9-dist1kit-x86_64-w64-mingw32-win64-9.0.1-250501.exe tclkit]


        kissb.args.ifNotContains --nowin {
            exec.run chmod +x $winkitFile
            exec.run ./$winkitFile dist-win/kissb-${::version}/tclkit/packager_run.tcl --continue --kit --name kissb-${::version} --main dist-win/kissb-${::version}/bin/kissb
        }





        kissb.args.contains --release {

            ## Sign
            set checksumFile [files.sha256 kissb-${::version}]
            log.info "Checksum file: $checksumFile"

            files.delete ${checksumFile}.asc
            exec.run gpg --batch --local-user 0x${::sign.defaultKey} --output ${checksumFile}.asc --detach-sig $checksumFile
            exec.run gpg --verify ${checksumFile}.asc $checksumFile

            rclone.run copy -P --s3-acl=public-read kissb-${::version}              ovhs3:kissb/kissb/${::track}/${::version}
            rclone.run copy -P --s3-acl=public-read kissb-${::version}.sha256.asc   ovhs3:kissb/kissb/${::track}/${::version}

            kissb.args.ifNotContains --nowin {

                ## Sign
                set checksumFile [files.sha256 kissb-${::version}.exe]
                log.info "Checksum file (exe): $checksumFile"

                files.delete ${checksumFile}.asc
                exec.run gpg --batch --local-user 0x${::sign.defaultKey} --output ${checksumFile}.asc --detach-sig $checksumFile
                exec.run gpg --verify ${checksumFile}.asc $checksumFile

                rclone.run copy -P --s3-acl=public-read kissb-${::version}.exe              ovhs3:kissb/kissb/${::track}/${::version}
                rclone.run copy -P --s3-acl=public-read kissb-${::version}.exe.sha256.asc   ovhs3:kissb/kissb/${::track}/${::version}
            }

        }

        return

        ## Download base kits
        files.require tclkit-8.6.14_notk {
            files.download https://kissb.s3.de.io.cloud.ovh.net/tclkit/8.6.14/tclkit-8.6.14_notk tclkit-8.6.14_notk
        }
        files.require tclkit-8.6.14_notk.exe {
            files.download https://kissb.s3.de.io.cloud.ovh.net/tclkit/8.6.14/tclkit-8.6.14_notk.exe tclkit-8.6.14_notk.exe
        }

        exec.run chmod +x tclkit-8.6.14_notk

        ## Run Starkit build
        set startKitName kissb-${::version}
        set resultKit [tclkit::buildStarkitWithLibsAndMainFromKit tclkit-8.6.14_notk tclkit-8.6.14_notk.exe ${startKitName}.exe lib/kissb-${::version}/bin/kissb.tcl lib/kissb-${::version}]
        files.cp $resultKit ${startKitName}.exe

        set resultKit [tclkit::buildStarkitWithLibsAndMainFromKit tclkit-8.6.14_notk tclkit-8.6.14_notk ${startKitName} lib/kissb-${::version}/bin/kissb.tcl lib/kissb-${::version}]
        files.cp $resultKit ${startKitName}


        kissb.args.contains -push {
            rclone.run copy --s3-acl=public-read ${startKitName}.exe ovhs3:kissb/kissb/dev/
            rclone.run copy --s3-acl=public-read ${startKitName} ovhs3:kissb/kissb/dev/
        }

    }

}
