package require kissb.git
package require kissb.builder.container
package require kissb.builder.rclone


rclone.init ../../../../rclone.conf

builder.container.image.build ./Dockerfile.builder verilator-rhel8-builder:latest

if {![file exists verilator]} {
    git.clone https://github.com/verilator/verilator
}
set buildImage verilator/verilator-buildenv
set buildImage verilator-rhel8-builder:latest


set versions { 5.040 5.038 5.036 5.034 5.032 }

foreach v  $versions {

    @ $v {
        log.info "Building {{set v}}"

        verilatorBuild detach:v{{set v}}

        kissb.args.contains --publish {
            rclone.run copy -P --s3-acl=public-read  build/verilator-v{{set v}}.zip   ovhs3:kissb/hdl/verilator/
        }

    }
}

proc verilatorBuild {branch args} {

    files.mkdir build


    files.inDirectory verilator {

        files.mkdir install
        git.fetch
        git.switch $branch
        switch [git.isDetached] {
            true {
                ## NOthing to do
            }
            false {
                ## Pull
                git.pull
            }
        }

        set outputDirectoryName verilator-[string map {detach: ""} $branch]
        set outputDirectory ../build/$outputDirectoryName

        # Build in docker image
        files.require $outputDirectory/bin/verilator {
            builder.container.image.run $::buildImage {
                cd /build
                autoconf
                ./configure --prefix=/build/install
                make clean
                CCACHE_DIR=/build/.ccache make -j 8
                make install
            }

            ## Done, copy from git copy
            files.cp install ../build/verilator-[string map {detach: ""} $branch]



        }

        ## Print info
        builder.container.image.run $::buildImage {
            g++ --version
        }

        ## ZIP
        files.inDirectory ../build/ {
            files.compressDir $outputDirectoryName ${outputDirectoryName}.zip



        }




        # Push if needed
        #kissb.args.ifContains -s3 {
        #
        #}

        #exec.run autoconf
        #exec.run ./configure --prefix=[pwd]/build
    }


}


@ all {

    #set buildBranches {master stable detach:v5.024 detach:v5.022 detach:v5.020 detach:v4.228}
    set buildBranches {master stable detach:v5.040 detach:v5.038 detach:v5.036 detach:v5.034 detach:v5.032 }

    #
    files.mkdir build

    foreach branch $buildBranches {
        files.inDirectory verilator {

            files.mkdir install
            git.switch $branch
            switch [git.isDetached] {
                true {
                    ## NOthing to do
                }
                false {
                    ## Pull
                    git.pull
                }
            }

            set outputDirectoryName verilator-[string map {detach: ""} $branch]
            set outputDirectory ../build/$outputDirectoryName

            # Build in docker image
            files.require $outputDirectory/bin/verilator {
                builder.container.image.run $::buildImage {
                    cd /build
                    autoconf
                    ./configure --prefix=/build/install
                    make clean
                    CCACHE_DIR=/build/.ccache make -j 8
                    make install
                }

                ## Done, copy from git copy
                files.cp install ../build/verilator-[string map {detach: ""} $branch]


            }

            ## ZIP
            files.inDirectory ../build/ {
                files.compressDir $outputDirectoryName ${outputDirectoryName}.zip
            }

            # Push if needed
            #kissb.args.ifContains -s3 {
            #
            #}

            #exec.run autoconf
            #exec.run ./configure --prefix=[pwd]/build
        }
    }

}


@ test-mingw {

    files.inDirectory verilator {
        git.switch stable

        # CCACHE_DIR=/build/.ccache
        #CC      x86_64-w64-mingw32-gcc
        #    CCX     x86_64-w64-mingw32-cpp
        #    AR      x86_64-w64-mingw32-ar
        #    RANLIB  x86_64-w64-mingw32-ranlib
        #    STRIP   x86_64-w64-mingw32-strip
        #    NM      x86_64-w64-mingw32-nm
        files.delete install
        files.mkdir install
        docker.run.script $::buildImage -env {
            CCACHE_DIR /build/.ccache_win
        } {
            cd /build
            autoconf -f
            ./configure -C config.mingw.cache --prefix=/build/install --host=x86_64-w64-mingw32
            make clean
            make -j 8
            make install
        }

    }
}






return
files.inDirectory verilator {

    files.mkdir install
    git.switch stable
    docker.run.script $buildImage {
        cd /build
        autoconf
        ./configure --prefix=/build/install
        make clean
        CCACHE_DIR=/build/.ccache make -j 8
        make install
    }
    #exec.run autoconf
    #exec.run ./configure --prefix=[pwd]/build
}
