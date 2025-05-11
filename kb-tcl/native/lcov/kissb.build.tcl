package require kissb.docker 
package require kissb.git
package require kissb.builder.podman


docker.image.build ./Dockerfile.builder lcov-rhel9-builder:latest

set version 2.3.1

@ build {

    files.inDirectory ${::kissb.buildDir} {

        set outputDirectory ./install/lcov-${::version}
        files.mkdir $outputDirectory

        # Download
        files.require lcov-${::version}/Makefile {
            files.downloadOrRefresh https://github.com/linux-test-project/lcov/releases/download/v${::version}/lcov-${::version}.tar.gz lcov
            files.extract lcov-${::version}.tar.gz
        }

        files.require $outputDirectory/bin/lcov {
            docker.run.script lcov-rhel9-builder:latest {
                pushd /build/lcov-${::version}
                #wget https://github.com/linux-test-project/lcov/releases/download/v2.3.1/lcov-2.3.1.tar.gz
                #tar xvaf lcov-2.3.1.tar.gz
                #cd lcov-2.3.1
                make clean
                CCACHE_DIR=/build/.ccache  make PREFIX=/build/$outputDirectory install
            }
        }

        return 
        # Build in docker image
        files.require $outputDirectory/bin/verilator {
            docker.run.script lcov-rhel9-builder:latest {
                cd /build
                wget https://github.com/linux-test-project/lcov/releases/download/v2.3.1/lcov-2.3.1.tar.gz
                tar xvaf lcov-2.3.1.tar.gz
                cd lcov-2.3.1
                make clean
                CCACHE_DIR=/build/.ccache  make PREFIX=/build/install install
            }

            ## PERL PAckages:
            ## Use with cpanminu: curl -L http://cpanmin.us | perl - --sudo App::cpanminus
            ## TimeDate
            ## Capture::Tiny
            ## DateTime

            ## Use perlbrew to make a dedicated perl

            ## Done, copy from git copy
            #files.cp install ../build/verilator-[string map {detach: ""} $branch]

            
        }

    }

    
}