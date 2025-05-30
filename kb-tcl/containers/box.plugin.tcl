package provide kissb.box 1.0
package require kissb.builder.container

namespace eval kissb::box  {


    #F0 9F A7 B0
    vars.define box.ps1 {🐳\\[\\033\[01;32m\\]\\u@${BOXNAME}\\[\\033\[01;34m\\] \\w\\[\\033\[00m\\]📦}


    proc containerExists name {
        return [expr {[exec.call ${::builder.container.runtime} ps -aq -f name=/^$name\$/] eq ""? 0 : 1}]
    }
    proc containerRunning name {
        return [expr {[exec.call ${::builder.container.runtime} ps -q -f name=/^$name\$/] eq ""? 0 : 1}]
    }

    kissb.extension box {

        create {name image args} {

            set containerName $name

            set exists [::kissb::box::containerExists $containerName]
            if {[refresh.is BOX]} {
                set exists 0
                catch {exec.call ${::builder.container.runtime} kill -f $containerName }
                catch {exec.call ${::builder.container.runtime} rm -f $containerName }
            }

            log.info "Creating Box $containerName ($exists)"

            if {!$exists} {

                log.info "Box $containerName does not exists, creating..."

                ## Maps Command args to container manager
                #########

                ## Volumes
                set vols [split [kissb.args.get --volumes ""] ,]

                ## extra
                set extraArgs [kissb.args.after -- ""]
                log.info "- extra args=$extraArgs"

                ## Create
                #############
                set containerCmd [list ${::builder.container.runtime} run --replace --name $containerName -d -it --privileged --userns keep-id --network host \
                        -v $::env(HOME):$::env(HOME):rw \
                        -v $::env(XDG_RUNTIME_DIR):$::env(XDG_RUNTIME_DIR):rw \
                        --env-host \
                        --hostuser=$::env(USER) \
                        --security-opt label=disable \
                        -w $::env(HOME) \
                        {*}$extraArgs \
                        $image ]

                log.info "Creating Box, command: $containerCmd"

                exec.run {*}$containerCmd

                log.success "Box $containerCmd created"

                ## Setup SUDO
                exec.run ${::builder.container.runtime} exec -u 0:0 $containerName gpasswd -a $::env(USER) wheel
                exec.run ${::builder.container.runtime} exec -u 0:0 $containerName /bin/bash -c "echo '%wheel ALL=(ALL:ALL) NOPASSWD: ALL' >> /etc/sudoers"

                log.success "Sudo Setup"

            }

        }


        rm {containerName args} {
            set exists [::kissb::box::containerExists $containerName]
            if {$exists} {
                catch {exec.call ${::builder.container.runtime} kill --signal TERM $containerName }
                catch {exec.call ${::builder.container.runtime} rm -f $containerName }
            } else {
                log.warn "Box $containerName doesn't exist"
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
                log.error "Box $containerName doesn't exist, please use box.create first"
                return
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
