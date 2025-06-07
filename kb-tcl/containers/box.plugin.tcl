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


        create {name args} {

            ## Arguments
            ## If first arg doesn't start with -, it is the image
            kissb.args.getFirstNotSwitch "" -> image

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

            log.info "Creating Box $containerName ($exists),force=[kissb.args.contains -f]"



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
                        if {[dict exists $boxConfig -sudo]} {
                            lappend args --sudo
                        }
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





                ## Create #-v $::env(XDG_RUNTIME_DIR):$::env(XDG_RUNTIME_DIR):rw,rslave
                #############

                # --env-host --hostuser=$::env(USER)
                set containerCmd [list ${::builder.container.runtime} create -it --replace --name $containerName \
                        --privileged --userns keep-id  \
                        --ipc host --network host --pid host --ulimit host \
                        --security-opt label=disable \
                        -v $::env(HOME):$::env(HOME):rw \
                        -v /run/user:/run/user:rw,rshared \
                        -l kbox=$containerName \
                        -w $::env(HOME) \
                        {*}$extraArgs \
                        $image ]

                log.info "Creating Box, command: $containerCmd"

                exec.run {*}$containerCmd

                log.success "Box $containerName created"

                exec.run ${::builder.container.runtime} start $containerName

                log.success "Box $containerName started"


                ## Setup SUDO
                kissb.args.contains --sudo {
                    log.success "Sudo Setup"
                    # -g [exec.call id -g]
                    #exec.run ${::builder.container.runtime} exec -u 0:0 $containerName useradd -M -s /bin/bash -U -u [exec.call id -u]  -G wheel $::env(USER)
                    #exec.run ${::builder.container.runtime} exec -u 0:0 $containerName gpasswd -a $::env(USER) wheel
                    exec.run ${::builder.container.runtime} exec -u 0:0 $containerName /bin/bash -c "echo '$::env(USER) ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers.d/10-box-user && chmod 0440 /etc/sudoers.d/10-box-user"
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

            kissb.args.contains -r {
                catch {box.rm $name}

            }
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
            set cmdBase {/bin/bash}
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

            # Extra args for exec
            set execArgs {}
            kissb.args.contains --root {
                lappend execArgs -u root:root
            } else {
                lappend execArgs -u [exec.call id -u]:[exec.call id -g]
            }

            ## Environment to forwared to command
            set envToForward {DISPLAY
                        DBUS_SESSION_BUS_ADDRESS
                        XDG_SESSION_ID
                        XAUTHLOCALHOSTNAME
                        HOSTNAME
                        WAYLAND_DISPLAY
                        XAUTHORITY
                        XDG_SESSION_TYPE
                        XDG_SEAT
                        XDG_RUNTIME_DIR
                        SSH_AUTH_SOCK
                        ICEAUTHORITY
                        XDG_CONFIG_DIRS
                        SESSION_MANAGER
            }
            set env {}
            foreach envName $envToForward {
                lappend env -e $envName=$::env($envName)
            }

            ## Running
            log.success "Entering $containerName with $cmdBase - you are now in the box!"

            catch {exec.run ${::builder.container.runtime} exec -it  \
                    -w $::env(PWD) \
                    {*}$execArgs \
                    -e BOXNAME=$containerName \
                    {*}$env \
                    -e PS1=[join ${::box.ps1}] \
                    $containerName \
                    {*}$cmdBase
            }

        }

    }

}
