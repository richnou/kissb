package provide kissb.box 1.0
package require kissb.builder.container

namespace eval kissb::box  {


    #F0 9F A7 B0
    vars.define box.ps1 {🐳\\[\\033\[01;32m\\]\\u@${BOXNAME}\\[\\033\[01;34m\\] \\w\\[\\033\[00m\\]📦}


    ## Configuration dict for boxes
    vars.define box.configurations {}

    ## @return true if the named box is in configuration
    proc boxDefined name {
        return [dict exists ${::box.configurations} $name]
    }

    proc boxContainers args {
        return [exec.call ${::builder.container.runtime} ps -a -f label=kbox --format="{{.Names}},{{.State}}"]
    }
    proc containerExists name {
        return [expr {[exec.call ${::builder.container.runtime} ps -aq -f name=/^$name\$/] eq ""? 0 : 1}]
    }
    proc containerRunning name {
        return [expr {[exec.call ${::builder.container.runtime} ps -q -f name=/^$name\$/] eq ""? 0 : 1}]
    }

    proc ::box {subcmd args} {
        box.${subcmd} {*}$args
    }

    kissb.extension box {

        register {name args} {

            ## Check Args
            set argsDict [dict create {*}$args]
            assert [dict exists $argsDict -image] "Register arguments must provide -image IMAGE"

            set image [dict get $argsDict -image]
            if {[file exists $image]} {
                dict set argsDict -image [file normalize $image]
            }
            dict set ::box.configurations $name $argsDict

        }


        create {name {image ""} args} {

            ## Arguments

            ## extra for container creation
            set extraArgs [kissb.args.popAfter -- ""]
            log.info "- extra args=$extraArgs"



            set containerName $name

            set exists [::kissb::box::containerExists $containerName]
            if {[refresh.is BOX] || [kissb.args.contains -f]} {
                set exists 0
                log.warn "Will recreate box..."
                box.rm $containerName
                #catch {exec.call ${::builder.container.runtime} kill -f $containerName }
                #catch {exec.call ${::builder.container.runtime} rm -f $containerName }
            }

            log.info "Creating Box $containerName ($exists)"



            if {!$exists} {

                log.info "Box $containerName does not exists, creating..."

                ## Find Image
                if {$image==""} {

                    if {![dict exists ${::box.configurations} $containerName]} {
                        log.error "Cannot create $containerName, no image provided and no box definition in configuration"
                        return
                    } else {
                        log.success "Creating $containerName using box configuration"
                        set boxConfig [dict get ${::box.configurations} $containerName]
                        set image [dict get $boxConfig -image]
                        lappend extraArgs {*}[dict get $boxConfig -args]
                    }

                }

                ## If Image is a Dockerfile, build image first
                #########
                if {[file exists $image]} {
                    set dockerFile $image
                    set image ${name}-image:latest

                    log.info "- Building image $image using provided $dockerFile"

                    exec.run ${::builder.container.runtime} build -q -f $dockerFile -t $image .

                }

                ## Maps Command args to container manager
                #########

                ## Volumes
                set vols [split [kissb.args.get --volumes ""] ,]



                ## Create #-v $::env(XDG_RUNTIME_DIR):$::env(XDG_RUNTIME_DIR):rw,rslave
                #############
                set envToForward {DISPLAY
                            DBUS_SESSION_BUS_ADDRESS
                            XDG_SESSION_ID
                            XAUTHLOCALHOSTNAME
                            HOSTNAME
                            WAYLAND_DISPLAY
                            XAUTHORITY
                            XDG_SESSION_TYPE
                            XDG_SEAT
                            SSH_AUTH_SOCK
                            ICEAUTHORITY
                            XDG_CONFIG_DIRS
                            SESSION_MANAGER
                }
                set env {}
                foreach envName $envToForward {
                    lappend env -e $envName=$::env($envName)
                }
                # --env-host
                set containerCmd [list ${::builder.container.runtime} run --replace --name $containerName -d -it --privileged --userns keep-id --network host \
                        -v $::env(HOME):$::env(HOME):rw \
                        -v /run/user:/run/user:rw,rslave \
                        {*}$env \
                        --hostuser=$::env(USER) \
                        --security-opt label=disable \
                        -l kbox=$containerName \
                        -w $::env(HOME) \
                        {*}$extraArgs \
                        $image ]

                log.info "Creating Box, command: $containerCmd"

                exec.run {*}$containerCmd

                log.success "Box $containerCmd created"

                ## Setup SUDO
                kissb.args.contains --sudo {
                    log.success "Sudo Setup"
                    exec.run ${::builder.container.runtime} exec -u 0:0 $containerName gpasswd -a $::env(USER) wheel
                    exec.run ${::builder.container.runtime} exec -u 0:0 $containerName /bin/bash -c "echo '%wheel ALL=(ALL:ALL) NOPASSWD: ALL' >> /etc/sudoers"
                }



            }

        }

        ls args {

            log.info "Boxes created:"
            foreach container [::kissb::box::boxContainers] {
                set state [split $container ,]
                set name [lindex $state 0]
                if {[lindex $state 1]=="running"} {
                    puts "- Box $name is [log.successColored running]"
                } else {
                    puts "- Box $name is [log.errorColored stopped]"
                }
            }
            log.info "Boxes available in configuration for creation:"
            foreach {name opts} ${::box.configurations} {
                set doc [dict getdef $opts -desc ""]
                puts "- Box [log.successColored $name]"
                if {$doc!=""} {
                    puts "  $doc"
                }
                puts "  Image=[dict get $opts -image]"
                puts "  Container arguments=[dict getdef $opts -args {}]"
            }
        }


        rm {containerName args} {
            set exists [::kissb::box::containerExists $containerName]
            if {$exists} {
                log.warn "Removing container for box $containerName"
                #catch {exec.call ${::builder.container.runtime} kill --time 2 --signal TERM $containerName }
                box.stop $containerName
                catch {exec.call ${::builder.container.runtime} rm -f $containerName }
            } else {
                log.warn "Box $containerName doesn't exist"
            }
        }

        stop {name args} {

            if {[::kissb::box::containerExists $name]} {
                log.warn "Stopping Box $name"
                catch {exec.call ${::builder.container.runtime} stop --time 2 $name }
            }

        }

        enter {name args} {

            #set containerName [string map {: -} box-${image}]
            set containerName $name

            ## Check if it is running or exists
            set running [::kissb::box::containerRunning $containerName]
            set exists  [::kissb::box::containerExists $containerName]

            ## If running, we can enter
            ## If doesn't exist, we can create if an image is provided

            if {!$running && !$exists} {
                if {[::kissb::box::boxDefined $containerName]} {
                    box.create $containerName
                } else {
                    log.error "Box $containerName doesn't exist, please use box.create first"
                    return
                }

            } elseif {!$running && $exists} {
                log.warn "Box Container $containerName is stopped, running now"
                exec.run ${::builder.container.runtime} start  $containerName
            }



            # Enter Box PS1="'[subst -nocommands -nobackslashes ${::box.ps1}]'"
            #
            #
            ## Command to run in box
            set cmdBase {/bin/bash }
            set userCmd [kissb.args.after -- ""]

            ## If there is a .boxrc file in the current directory, first source it before running the command
            if {[file exists $::env(PWD)/.boxrc]} {
                lappend cmdBase --rcfile $::env(PWD)/.boxrc
            } else {
                lappend cmdBase --norc
            }
            if {$userCmd != ""} {

                lappend cmdBase -c "$userCmd"
            }

            ## Running
            log.success "Entering $containerName with $cmdBase - you are now in the box!"

            catch {exec.run ${::builder.container.runtime} exec -it  -w $::env(PWD) -e BOXNAME=$containerName -e PS1=[join ${::box.ps1}] $containerName {*}$cmdBase}

        }

    }

}
