package require kissb.git
package require kissb.builder.container
package require kissb.builder.rclone

rclone.init ../../../../rclone.conf

vars.define ghdl.version 5.1.1

builder.container.image.build ./Dockerfile.builder ghdl-rhel9-builder:latest

set buildImage ghdl-rhel9-builder:latest

proc ghdlBuild {version args} {

    files.mkdir build


    files.inDirectory .kb/ghdl-$version {


        files.require ghdl-${version} {
            files.downloadOrRefresh https://github.com/ghdl/ghdl/archive/refs/tags/v${version}.tar.gz GHDL
            files.extract v${version}.tar.gz
        }


        # Build in docker image
        files.requireOrRefresh install/bin/ghdl ghdl {
            builder.container.image.run $::buildImage {

                cd /build/ghdl-$version/
                ls -al
                mkdir -p out
                cd out
                ../configure  --prefix=/build/install --with-llvm-config
                #make clean
                make -j 8
                make install
                cp /usr/lib64/libgnat-11.so /build/install/bin
                cp /usr/lib64/libLLVM.so.19.1 /build/install/bin
            }

            ## Done, copy from git copy
            #files.cp install ../build/verilator-[string map {detach: ""} $branch]

        }

        ## Copy libs
        builder.container.image.run $::buildImage {
            cp /usr/lib64/libgnat-11.so /build/install/bin
            cp /usr/lib64/libLLVM.so.19.1 /build/install/bin
        }

        ## ZIP
        files.delete out
        files.mkdir out
        files.cp install out/ghdl-${version}
        files.compressDir out/ghdl-${version} out/ghdl-${version}-llvm-rhel9.zip
    }

}


@ build {
    ghdlBuild ${::ghdl.version}

    kissb.args.contains --publish {
        rclone.run copy -P --s3-acl=public-read  .kb/ghdl-${::ghdl.version}/out/ghdl-${::ghdl.version}-llvm-rhel9.zip   ovhs3:kissb/hdl/ghdl/
    }
}
