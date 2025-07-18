# SPDX-FileCopyrightText: 2024 KISSB
#
# SPDX-License-Identifier: Apache-2.0

namespace eval coursier::bom {


    kissb.extension coursier.bom {


        enforce spec {
            
            # Fetch POM
            set bomPom [coursier.fetch.classpath.of $spec "" "pom"]

            # Parse and return bom dictionary
            set bom [::coursier::bom::pom::parsePOM $bomPom]

            set cacheFileName coursier-bom-${spec}
            kissb.cached.fileOrElse ${cacheFileName}.txt -> bom {

                # Fetch POM
                set bomPom [coursier.fetch.classpath.of $spec "" "pom"]

                # Parse and return bom dictionary
                set bom [coursier::bom::pom::parsePOM $bomPom]

                kissb.cached.writeFile ${cacheFileName}.txt  $bom
            }
            
            # Save BOM 
            dependencies.bom $bom

            #log.info "BOM: $bom"
            

        }

    }


    #####################
    # POM 
    ######################
    namespace eval pom {
    

        set state(current) "NONE"
        set state(parents) {}
        set state(properties) [dict create]
        set state(bom) [dict create]

        proc parsePOM f {
            package require tdom

         
            log.withLogger coursier.bom {
                log.info "Loading BOM using POM $f"
            

                ## Reset parser state 
                set ::coursier::bom::pom::state(current) VOID
                set ::coursier::bom::pom::state(parents) {}
                set ::coursier::bom::pom::state(properties) [dict create]
                set ::coursier::bom::pom::state(bom) [dict create]

                ## Run Parser
                set parser [::xml::parser \
                        -elementendcommand      ::coursier::bom::pom::elementEnd \
                        -elementstartcommand    ::coursier::bom::pom::elementStart \
                        -characterdatacommand   ::coursier::bom::pom::elementData \
                        -commentcommand         ::coursier::bom::pom::xmlComment]

                $parser parse [files.read $f]
                $parser free

                # If there is a parent, parse it too
                set currentBom $::coursier::bom::pom::state(bom)
                if {[llength $::coursier::bom::pom::state(parents)]==1} {
                    set parentSpec [lindex $::coursier::bom::pom::state(parents) 0]
                    log.info "Parsing parent POM: $parentSpec"
                    set parentBom [::coursier::bom::pom::parsePOM [coursier.fetch.classpath.of $parentSpec "" "pom"]]
                    return [dict merge $currentBom $parentBom]
                } else {
                    return $currentBom
                }

                #puts "Parents: $coursier::bom::pom::state(parents)"
                #puts "Properties: $state(properties)"
                #puts "BOM: $coursier::bom::pom::state(bom)"

                #return $coursier::bom::pom::state(bom)

            }
            
        }
        
        proc elementStart {type attrs args} {
           
            if {$type=="parent"} {
                set ::coursier::bom::pom::state(current) PARENT
            }

            # Artifact coordinates
            switch $type {

                project {
                    set ::coursier::bom::pom::state(current) PROJECT
                    set ::coursier::bom::pom::state(parent)  $::coursier::bom::pom::state(current)
                }
                parent {
                    set ::coursier::bom::pom::state(current) PARENT
                    set ::coursier::bom::pom::state(parent)  $::coursier::bom::pom::state(current)
                }

                groupId {
                    set ::coursier::bom::pom::state(current) $::coursier::bom::pom::state(parent).groupId
                }
                artifactId {
                    set ::coursier::bom::pom::state(current) $::coursier::bom::pom::state(parent).artifactId
                }
                version {
                    set ::coursier::bom::pom::state(current) $::coursier::bom::pom::state(parent).version
                }
                properties {
                    set ::coursier::bom::pom::state(current) PROPERTIES
                }
                dependencyManagement {
                    set ::coursier::bom::pom::state(current) DEPENDENCY_MANAGEMENT
                    set ::coursier::bom::pom::state(parent)  $::coursier::bom::pom::state(current)
                }
                dependencies {
                }
                dependency {
                    if {$::coursier::bom::pom::state(parent)=="DEPENDENCY_MANAGEMENT"} {
                        set ::coursier::bom::pom::state(current) DEPENDENCY_MANAGEMENT.DEPENDENCY
                    } else {
                        set ::coursier::bom::pom::state(current) DEPENDENCY
                        set ::coursier::bom::pom::state(parent)  $::coursier::bom::pom::state(current)
                    }
                    
                }
                default {
                    # In default case and we are in PROPERTIES state, we are saving elementName -> Text as variable=version (<properties><VAR>value</VAR></properties>)
                    # We are in element handler so we save the property name, in the text handler, we are saving the value
                    if {$::coursier::bom::pom::state(current)=="PROPERTIES"} {
                        
                        set ::coursier::bom::pom::state(property.name) $type
                    } else {
                        set ::coursier::bom::pom::state(current) VOID
                    }
                    
                }
            }
        
        }

        proc resolveProperties v {
            try {
                #return [uplevel #0 [list subst $v]]
                return [namespace inscope ::coursier::bom::pom [list subst $v]]
            } on error args {
                log.warn "Could not resolve version $v for state $::coursier::bom::pom::state(current)"
                return $v
            }
        }
        proc elementEnd {type args} {
            global state

            switch $type {

                parent {
                    lappend ::coursier::bom::pom::state(parents) $::coursier::bom::pom::state(PARENT.groupId):$::coursier::bom::pom::state(PARENT.artifactId):$::coursier::bom::pom::state(PARENT.version)
                }

                dependency {
                    
                    #puts "EOF Dependency: $state(current)"
                    if {$::coursier::bom::pom::state(parent)=="DEPENDENCY_MANAGEMENT"} {
                        dict set ::coursier::bom::pom::state(bom) \
                                $::coursier::bom::pom::state(DEPENDENCY_MANAGEMENT.groupId):$::coursier::bom::pom::state(DEPENDENCY_MANAGEMENT.artifactId) [::coursier::bom::pom::resolveProperties [lindex $::coursier::bom::pom::state(DEPENDENCY_MANAGEMENT.version) 0]]
                    }
                }

                default {
                    if {$::coursier::bom::pom::state(current)=="PROPERTIES"} {
                        set properyName   $::coursier::bom::pom::state(property.name)
                        set propertyValue [::coursier::bom::pom::resolveProperties $::coursier::bom::pom::state(PROPERTIES)]

                        log.info "Detected property $properyName -> $propertyValue"

                        dict set ::coursier::bom::pom::state(properties) $properyName $propertyValue
                        
                        #puts "setting version var ::$state(property.name)"
                        namespace inscope ::coursier::bom::pom [list set $properyName $propertyValue]
                    }
                }
            }
            
        }

        proc elementData {data} {
            global state

            set data [string trim $data]
            if {$data!=""} {
                #puts "Data in $state(current)"
                set ::coursier::bom::pom::state($::coursier::bom::pom::state(current)) $data
            }
           
        }

        proc xmlComment {data} {

        }

        
       
    }

    namespace eval pomtxml {
    

        set state(current) "NONE"
        set state(parents) {}
        set state(properties) [dict create]
        set state(bom) [dict create]

        proc parsePOM f {
            package require xml

            log.info "Loading BOM using POM $f"
            log.withLogger coursier.bom {
                log.info "Loading BOM using POM $f"
            }

            ## Reset parser state 
            set coursier::bom::pom::state(current) VOID
            set coursier::bom::pom::state(parents) {}
            set coursier::bom::pom::state(properties) [dict create]
            set coursier::bom::pom::state(bom) [dict create]

            ## Run Parser
            set parser [::xml::parser \
                    -elementendcommand      coursier::bom::pom::elementEnd \
                    -elementstartcommand    coursier::bom::pom::elementStart \
                    -characterdatacommand   coursier::bom::pom::elementData \
                    -commentcommand         coursier::bom::pom::xmlComment \
                    -reportempty 1]

            $parser parse [files.read $f]
            $parser free

            # If there is a parent, parse it too
            set currentBom $coursier::bom::pom::state(bom)
            if {[llength $coursier::bom::pom::state(parents)]==1} {
                set parentBom [coursier::bom::pom::parsePOM [coursier.fetch.classpath.of [lindex $coursier::bom::pom::state(parents) 0] "" "pom"]]
                return [dict merge $currentBom $parentBom]
            } else {
                return $currentBom
            }

            #puts "Parents: $coursier::bom::pom::state(parents)"
            #puts "Properties: $state(properties)"
            #puts "BOM: $coursier::bom::pom::state(bom)"

            #return $coursier::bom::pom::state(bom)
            
        }
        
        proc elementStart {type attrs args} {
           
            if {$type=="parent"} {
                set coursier::bom::pom::state(current) PARENT
            }

            # Artifact coordinates
            switch $type {

                project {
                    set coursier::bom::pom::state(current) PROJECT
                    set coursier::bom::pom::state(parent)  $coursier::bom::pom::state(current)
                }
                parent {
                    set coursier::bom::pom::state(current) PARENT
                    set coursier::bom::pom::state(parent)  $coursier::bom::pom::state(current)
                }

                groupId {
                    set coursier::bom::pom::state(current) $coursier::bom::pom::state(parent).groupId
                }
                artifactId {
                    set coursier::bom::pom::state(current) $coursier::bom::pom::state(parent).artifactId
                }
                version {
                    set coursier::bom::pom::state(current) $coursier::bom::pom::state(parent).version
                }
                properties {
                    set coursier::bom::pom::state(current) PROPERTIES
                }
                dependencyManagement {
                    set coursier::bom::pom::state(current) DEPENDENCY_MANAGEMENT
                    set coursier::bom::pom::state(parent)  $coursier::bom::pom::state(current)
                }
                dependencies {
                }
                dependency {
                    if {$coursier::bom::pom::state(parent)=="DEPENDENCY_MANAGEMENT"} {
                        set coursier::bom::pom::state(current) DEPENDENCY_MANAGEMENT.DEPENDENCY
                    } else {
                        set coursier::bom::pom::state(current) DEPENDENCY
                        set coursier::bom::pom::state(parent)  $coursier::bom::pom::state(current)
                    }
                    
                }
                default {
                    # save element name as property name
                    if {$coursier::bom::pom::state(current)=="PROPERTIES"} {
                        set coursier::bom::pom::state(property.name) $type
                    } else {
                        set coursier::bom::pom::state(current) VOID
                    }
                    
                }
            }
        
        }

        proc resolveProperties v {
            try {
                #return [uplevel #0 [list subst $v]]
                return [namespace inscope ::coursier::bom::pom [list subst $v]]
            } on error args {
                log.warn "Could not resolve version $v"
                return $v
            }
        }
        proc elementEnd {type args} {
            global state

            switch $type {

                parent {
                    lappend coursier::bom::pom::state(parents) $coursier::bom::pom::state(PARENT.groupId):$coursier::bom::pom::state(PARENT.artifactId):$coursier::bom::pom::state(PARENT.version)
                }

                dependency {
                    
                    #puts "EOF Dependency: $state(current)"
                    if {$coursier::bom::pom::state(parent)=="DEPENDENCY_MANAGEMENT"} {
                        dict set coursier::bom::pom::state(bom) $coursier::bom::pom::state(DEPENDENCY_MANAGEMENT.groupId):$coursier::bom::pom::state(DEPENDENCY_MANAGEMENT.artifactId) [coursier::bom::pom::resolveProperties [lindex $coursier::bom::pom::state(DEPENDENCY_MANAGEMENT.version) 0]]
                    }
                }

                default {
                    if {$coursier::bom::pom::state(current)=="PROPERTIES"} {
                        set properyName   $coursier::bom::pom::state(property.name)
                        set propertyValue [coursier::bom::pom::resolveProperties $coursier::bom::pom::state(PROPERTIES)]
                        dict set coursier::bom::pom::state(properties) $properyName $propertyValue
                        #puts "setting version var ::$state(property.name)"
                        namespace inscope ::coursier::bom::pom [list set $properyName $propertyValue]
                    }
                }
            }
            
        }

        proc elementData {data} {
            global state

            set data [string trim $data]
            if {$data!=""} {
                #puts "Data in $state(current)"
                set coursier::bom::pom::state($coursier::bom::pom::state(current)) $data
            }
           
        }

        proc xmlComment {data} {

        }

        
       
    }

}