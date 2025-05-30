# SPDX-FileCopyrightText: 2024 KISSB
#
# SPDX-License-Identifier: Apache-2.0

package provide kissb.tclkit 1.0
package require kissb.builder.container
package require kissb.docker 

namespace eval tclkit {

    set workFolder .kb/tclkit
    set packageFolder [file dirname [file normalize [info script]]]

    proc buildTCLKit {kitName tclVersion {kitPackages "tk tcllib tls zlib tclvfs mk4tcl"} {userLibs {}} {prefix ""} args} {
        
        # Prepare Docker
        ########
        #builder.selectDockerRuntime
        builder.container.image.build ${::tclkit::packageFolder}/Dockerfile.builder kissb-tclkitbuilder:latest

        ## TCL version can be VERSION-SUFFIX
        ## Suffix is used to distinguis builds, like Crosscompile Build
        #########
        set splitVersion [split $tclVersion "-"]
        set tclVersionClean [lindex $splitVersion 0]

        log.info "Building TCL Kit $tclVersion, actual tcl version=$tclVersionClean"
         
        ## Prepare work folder $kitName
        ################
        files.inDirectory ${::tclkit::workFolder}/${tclVersion} {
            #files.require kitcreator-trunk-tip/tclkit-${tclVersion} {

                # Get TCLKIT source
                files.require kitcreator-trunk-tip/kitcreator {
                    files.download http://kitcreator.rkeene.org/fossil/tarball/kitcreator-trunk-tip.tar.gz?uuid=trunk kitcreator-trunk-tip.tar.gz
                    files.extract kitcreator-trunk-tip.tar.gz
                }

                # Run
                files.inDirectory kitcreator-trunk-tip {

                    # User lib
                    foreach l $userLibs {
                        set libName [file tail $l]
                        make [pwd]/$libName/build.sh : $l/build.sh {
                            files.delete $libName
                            log.info "Copying [file normalize $l] to [pwd]"
                            files.cp [file normalize $l] [pwd]/$libName
                        }
                        
                    }

                    # Patch kitsh
                    log.info "Patching kitsh with ${::tclkit::packageFolder}/patches/kitsh.build.patch..."
                    files.inDirectory kitsh {
                        catch {exec.run patch -sf build.sh -i ${::tclkit::packageFolder}/patches/kitsh.build.patch}
                    }

                    # Update TCLX Version
                    log.info "Patching tclx version..."
                    files.inDirectory tclx {
                        files.cp ${::tclkit::packageFolder}/patches/tclx.build.sh build.sh
                        exec.run chmod +x build.sh
                    }

                    # Patch TCL TLS aclocal for proper TCL compilation setup
                    files.inDirectory tls/patches/ {
                        files.cp ${::tclkit::packageFolder}/patches/tls-aclocal-fix.patch tls-aclocal-fix.diff
                        #catch {exec.run patch -sf build.sh -i ${tclkit::packageFolder}/patches/tls-aclocal-fix.patch}
                    }

                    # Clean folders that are not includes in required packages
                    set packageAlwaysPresent [concat $kitPackages {tcl kitsh} ]
                    foreach libFolder [glob -type d *] {
                        # Success present but not requested, remove success marker
                        # Success backup present and requested, restore success marker
                        if {[file exists $libFolder/.success] && [lsearch $packageAlwaysPresent [file tail $libFolder]]==-1} {
                            log.warn "Removing non-requested module: $libFolder"
                            files.mv $libFolder/.success $libFolder/.success_kissb
                        } elseif {[file exists $libFolder/.success_kissb] && [lsearch $packageAlwaysPresent [file tail $libFolder]]!=-1 && [file exists $libFolder/out]} {
                            log.warn "Restoring non-requested module: $libFolder"
                            files.mv $libFolder/.success_kissb $libFolder/.success
                        }
                    }

                    # If there is a CC prefix, add arguments to kit creator --enable-kit-storage=zip
                    set kitshLDArgs {}
                    set kitCreatorArgs {--enable-kit-storage=mk4}
                    set ccPrefix ""
                    if {$prefix!=""} {
                        lappend kitCreatorArgs  --host=$prefix
                        set ccPrefix ${prefix}-
                        lappend kitshLDArgs -Wl,-Bstatic -lstdc++ -lpthread
                    }

                    # If rebuild required, clean first
                    if {[lsearch $args -clean]!=-1} {
                        # docker run -it -u $(id -u) -v .:/build kissb-tclkitbuilder:latest /bin/bash
                        builder.container.image.run kissb-tclkitbuilder:latest {
                            ./kitcreator clean
                        }
                    }

                    puts "KIT args=$kitCreatorArgs ; ccPrefix=$ccPrefix"
                    # Build Tclkit with Kissb
                    # export KC_KITSH_CFLAGS="-DKIT_STORAGE_ZIP=1 -UKIT_INCLUDES_MK4TCL"
                    set tclKitOutput tclkit-$tclVersion
                    builder.container.image.run kissb-tclkitbuilder:latest {
                        export KITCREATOR_PKGS="$kitPackages"
                        export CC=${ccPrefix}gcc
                        export CCX=${ccPrefix}cpp
                        export AR=${ccPrefix}ar
                        export RANLIB=${ccPrefix}ranlib
                        export STRIP=${ccPrefix}strip
                        export NM=${ccPrefix}nm
                        export KC_KITSH_LDFLAGS_ADD="$kitshLDArgs"
                        export TCLKIT="[env TCLKIT tclkit]"
                        ./kitcreator retry $tclVersionClean --enable-64bit $kitCreatorArgs
                    }

                    
                }
            #}

            # Kit is ready
            return [file normalize kitcreator-trunk-tip/tclkit-${tclVersionClean}]
            
        }
    }

    proc buildCCTCLKit {kitName tclVersion baseKit {kitPackages {}} {userLibs {}} args} {

        # First build TCL Kit
        #set ccKitName ${kitName}-cc

        #set tclCCKitPath [buildTCLKit ${kitName} $tclVersion {tk tcllib tls zlib tclvfs mk4tcl} $userLibs ]

        set baseKit [file normalize $baseKit]
        log.info "Original TCL Kit: $baseKit"

        #env TCLKIT $baseKit
        env.set TCLKIT /tclkit
        #env.set KB_DOCKER_ARGS {-v /home/rleys/git/promd/kissbuild-tcl/tclkit2/tclkit-8.6.14_notk:/tclkit}
        # {tcllib zlib tclvfs} 
        set tclKitPath [buildTCLKit ${kitName} ${tclVersion}-mingw $kitPackages $userLibs x86_64-w64-mingw32 {*}$args]

        log.info "Resulting CC kit: $tclKitPath"
        
        

        return $tclKitPath

    }

    proc buildStarkitWithLibsAndMainFromKit {tclkit runtimeKit name main libs} {

        # Normalize paths to be absolute before entering work folder
        set tclkit          [file normalize $tclkit]
        set runtimeKit      [file normalize $runtimeKit]
        set mainFile        [file normalize $main]
        set normalizedLibs  [lmap lib $libs { file normalize $lib}]
       
        log.info "TCL Kit for Startkit building: $tclkit"
        files.inDirectory ${tclkit::workFolder}/starkit {

            files.require sdx.kit {
                exec.run wget --no-check-certificate https://chiselapp.com/user/aspect/repository/sdx/uv/sdx-20110317.kit -O sdx.kit
            }

            files.inDirectory $name {

                log.info "Building Starkit using $mainFile"

                # Kit is ready
                # Create starkit
                # Build Starkit for Kissb entrypoints
                set sdxOutputName [lindex [split [file tail $mainFile] .] 0]
                log.info "SDX base name is $sdxOutputName"

                # Wrap main to create the kit containing the main file
                # Then unwrap to create a .vfs folder into which we can copy the libs
                files.delete ${sdxOutputName}.vfs
                files.delete ${sdxOutputName}.kit
                files.cp $runtimeKit ./tclkit-starkit
                exec.run $tclkit ../sdx.kit qwrap $mainFile
                exec.run $tclkit ../sdx.kit unwrap ${sdxOutputName}.kit

                # Copy libraries into the vfs folder
                foreach lib $normalizedLibs {
                    files.cp $lib ${sdxOutputName}.vfs/lib/
                }

                # Wrap vfs back into a starkit with runtime
                exec.run $tclkit ../sdx.kit wrap ${sdxOutputName}.kit -runtime tclkit-starkit
                
                files.delete ./tclkit-starkit
                catch {exec.run mv ${sdxOutputName}.kit ${name}.kit}

                return [file normalize ${name}.kit]
            }
        }

   
    }

    proc buildStarkitWithLibsAndMain {libs name main} {
        
        builder.selectDockerRuntime

        ## Prepare Builder image
        # Prepare builder image
        docker.image.build ${tclkit::packageFolder}/Dockerfile.builder kissb-tclkitbuilder:latest

        files.inDirectory ${tclkit::workFolder} {
            files.require kitcreator-trunk-tip/kitcreator {
                files.download http://kitcreator.rkeene.org/fossil/tarball/kitcreator-trunk-tip.tar.gz?uuid=trunk kitcreator-trunk-tip.tar.gz
                files.extract kitcreator-trunk-tip.tar.gz
            }
            files.require sdx.kit {
                exec.run wget --no-check-certificate https://chiselapp.com/user/aspect/repository/sdx/uv/sdx-20110317.kit -O sdx.kit

            }

            env KIT_NAME tclkit
            env KIT_TCL_VERSION 8.6.14
            env KIT_KITCREATOR_PKGS "tk tcllib tls zlib tclvfs mk4tcl"
            env KIT_KITCREATOR_USR_PKGS $libs

             
            files.inDirectory kitcreator-trunk-tip {

                
                foreach l $libs {
                    #exec rm -Rf $l
                    files.delete $l
                    #exec.run ln -s ../../../$l $l
                    log.info "Copying [file normalize ../../../$l] to [pwd]"
                    files.cp [file normalize ../../../$l] [pwd]/$l
                    #exec.run cp -Rf ../../../$l .
                }

                # Patch kitsh
                log.info "Patching kitsh with ${tclkit::packageFolder}/kitsh.build.patch..."
                files.inDirectory kitsh {
                    catch {exec.run patch -sf build.sh -i ${tclkit::packageFolder}/kitsh.build.patch}
                }
                
                # Build Tclkit with Kissb
                set tclKitOutput tclkit-$::KIT_TCL_VERSION
                builder.image.run kissb-tclkitbuilder:latest {
                    export KITCREATOR_PKGS="[concat $::KIT_KITCREATOR_PKGS $::KIT_KITCREATOR_USR_PKGS]"

                    ./kitcreator retry $::KIT_TCL_VERSION --enable-64bit
                }

                # Kit is ready
                # Create starkit
                # Build Starkit for Kissb entrypoints
                set sdxOutputName [lindex [split [file tail $main] .] 0]
                log.info "SDX base name is $sdxOutputName"

                files.delete ${sdxOutputName}.vfs
                files.delete ${sdxOutputName}.kit
                files.cp ./$tclKitOutput ./tclkit-starkit
                exec.run ./$tclKitOutput ../sdx.kit qwrap $main
                exec.run ./$tclKitOutput ../sdx.kit unwrap ${sdxOutputName}.kit
                exec.run ./$tclKitOutput ../sdx.kit wrap ${sdxOutputName}.kit -runtime tclkit-starkit
                
                files.delete ./tclkit-starkit
                catch {exec.run mv ${sdxOutputName}.kit ${name}.kit}
                
                return [file normalize ${name}.kit]

                # Combine Tclkit with kissb
                #files.delete ${name}.vfs
                #exec.run ./$tclKitOutput ../sdx.kit unwrap ${name}.kit
                #files.cp ./$tclKitOutput ./tclkit-starkit
                #exec.run ./$tclKitOutput ../sdx.kit wrap ${name}.kit -runtime tclkit-starkit
                #files.delete ./tclkit-starkit

                #return ${name}.kit
            }

            
        }
        
    }

}
