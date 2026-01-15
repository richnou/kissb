# SPDX-FileCopyrightText: 2024 KISSB
#
# SPDX-License-Identifier: Apache-2.0

package provide kissb.alternatives 1.0 

namespace eval ::kissb::alternatives {
    
    vars.define kissb.alternatives.folder [vars.get kissb.home]/alternatives
    
    kissb.extension alternatives {
        
        
        bashEnv args {
            # Prints a Bash environment update to be evaluated for terminal usage
            # It sets PATH to alternatives bin folder, and adds environment variables requested by packages
            puts "export PATH=\"[file normalize ${::kissb.alternatives.folder}/bin]:\${PATH}\""
            
            files.inDirectory ${::kissb.alternatives.folder} {
                ## Retrieve current setup
                set setup [json.readStringAsList [files.readOrDefault setup.json {}]]
                
                foreach {group opts} $setup {
                    #puts "# Env for group $group"
                    foreach {env envOpts} [dict getdef $opts env {}] {
                        set merge [dict getdef $envOpts merge 0]
                        set v [dict get $envOpts value]
                        if {$merge == 0} {
                            puts "export ${env}=\"$v\""
                        } else {
                            puts "export ${env}=\"${v}:\${env}\""
                        }
                    }
                }
                
            }
            
        }
        
        configure {group {version ""}} {
            # Use this method as user to request an alternative configuration.
            # The method will search for a package that provides the group and variant using standard command name $group.alternatives.provide --version $version
            
            # Load package that could provide a mathod to configure the alternative 
            try {
                package require kissb.$group 
            } on error args {
                log.error "Could not load a package to provide an alternative for $group.$variant"
                return false
            }
            
            # Search for the method 
            if {[llength [info procs ::${group}.alternatives.provide]] == 0} {
                log.error "Package for $group doesn't provide a configuration method for the alternative"
                return  false
            }
            
            # Call
            log.success "Configuring alternative for $group.$version"
            ::${group}.alternatives.provide {*}[expr {$version == "" ? {} : [list --version $version]} ]
            
            return true
            
        }
        
        display args {
            # Show the current state of provided groups
            
            files.inDirectory ${::kissb.alternatives.folder} {
                
                    
                ## Retrieve current setup
                set setup [json.readStringAsList [files.readOrDefault setup.json {}]]
                
            }
        }
        
        setup {group version binDict info} {
            # Call by another package to register a set of binaries to be provided as a named group for a specific version
            # binDict parameter is a list with the name of the binary and its path
            # Opts are provided and saved by the package a info for the user
            log.info "Setting up alternative for $group,version=$version"
            
            files.inDirectory ${::kissb.alternatives.folder} {
                
                ## Retrieve or init current setup
                set setup [json.readStringAsList [files.readOrDefault setup.json {}]]
                
                
                ## Ensure bin directory  is present 
                files.mkdir bin
                files.mkdir links 
                
                
                dict set setup $group version           $version
                dict set setup $group updateTimestamp   [time.unixTimestamp]
                dict set setup $group info              $info
                
                ## Link Provided alternatives and register in setup
                foreach {bin binPath} [dict get $binDict bin] {
                    
                    ## If Link exists and is the same, don't do anything, otherwise create or change
                    set linkPath bin/$bin
                    if {![files.linkIsDestination $linkPath -> $binPath]} {
                        if {[files.isLink $linkPath]} {
                            ## Undo then relink
                            files.delete $linkPath
                        } elseif {[files.isFile]} {
                            log.fatal "Link $linkPath is not a link and exists, not touching, failing - there's a problem with this package internal setup"
                        }
                        
                        ## Link 
                        files.linkSymbolic $linkPath -> $binPath
                        log.success "Linked $bin to $binPath"
                        
                    } else {
                        ## Already correct link, don't to anything
                    } 
                    
                    ## Save to setup
                    dict set setup $group alternatives $bin [list path $binPath version $version]
                    
                }
                
                ## Setup links 
                foreach {link linkPath} [dict get $binDict links] {
                    
                    ## If Link exists and is the same, don't do anything, otherwise create or change
                    set localPath links/$link
                    if {![files.linkIsDestination $localPath -> $linkPath]} {
                        if {[files.isLink $localPath]} {
                            ## Undo then relink
                            files.delete $localPath
                        }
                        
                        ## Link 
                        files.linkSymbolic $localPath -> $linkPath
                        log.success "Linked $localPath to $linkPath"
                        
                    } else {
                        ## Already correct link, don't to anything
                    } 
                    
                    ## Save to setup
                    dict set setup $group links $link [list path $linkPath version $version]
                    
                }
                
                ## Save Environment 
                foreach {envVar opts} [dict get $binDict env] {
                    
                    set envVal [dict get $opts value]
                    if {[files.isFile $envVal] || [files.isFolder $envVal]} {
                        dict set setup $group env $envVar [list value [file normalize $envVal]  merge [dict getdef $opts merge 0]]
                    } else {
                        dict set setup $group env $envVar [list value $envVal                   merge [dict getdef $opts merge 0]]
                    }
                    
                }
                
                ## Save setup 
                json.write setup.json $setup
                
            }
            
        }
        
    }

}