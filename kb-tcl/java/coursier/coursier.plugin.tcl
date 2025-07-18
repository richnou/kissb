# SPDX-FileCopyrightText: 2024 KISSB
#
# SPDX-License-Identifier: Apache-2.0

package provide kissb.coursier 1.0
package require sha256

namespace eval coursier {

    set buildFolder ".kb/coursier"
    set tcFolder ".kb/toolchain/coursier"
    set outputFolder "repository"

    set binPath ""

    set repositories {ivy2Local central sonatype:releases https://oss.sonatype.org/content/groups/public/}

    ## Repos
    ###############
    proc addRepository url {
        lappend ::coursier::repositories $url
    }

    ## Dependency resolution
    ################
    proc resolveModule {module {forcedVersions {}}} {

        # Get  the deps dictionary
        set depsForModule [kiss::dependencies::getDeps $module]

        log.debug "Coursier resolve deps for $module with foced versions: $forcedVersions ->"
        log.debug  $depsForModule

        # Create a SHA of the required specs for caching purpose
        set specList {}
        foreach {spec depDict} $depsForModule {
            lappend specList $spec
        }
        set specSHA [::sha2::sha256 -hex -- [join [lsort $specList]]]
        log.debug "Coursier spec SHA256 of $specList: $specSHA"

        # Get Cache file
        set cacheFileName coursier-${module}-deps-${specSHA}
        kissb.cached.fileOrElse ${cacheFileName}.txt deps cachedDepsDict {

            # Forced versions args
            set forcedVersionsArgs {}
            if {[llength $forcedVersions]>0} {
                set forcedVersionsArgs [list -V {*}[join $forcedVersions " -V "]]
            }

            # Resolve what needs be
            dict for {spec depInfo} $depsForModule {
                dict with depInfo {
                    if {$resolved==false} {
                        set resolvedDict [::coursier::fetchSpec $spec {*}$forcedVersionsArgs]
                        dict set depsForModule $spec resolved $resolvedDict
                        #log.info "Resolving $spec -> $resolvedDict"
                        #dict merge depInfo [::coursier::fetchSpec $spec]
                    }
                }
            }

            # Write Dict output to file
            kissb.cached.cleanFiles coursier-${module}-deps
            kissb.cached.writeFile ${cacheFileName}.txt  $depsForModule
            kissb.cached.writeFile ${cacheFileName}.json [json.toString $depsForModule]
        }
        log.debug "[namespace current] Cached deps: $cachedDepsDict"
        set mergedDict [kiss::dependencies::mergeDeps $module $cachedDepsDict]
        #log.info "Merged deps for $module: $mergedDict"


    }

    ## On Load -> Toolchain
    ###########
    kiss::toolchain::register coursier {
        #puts "Init Coursier Toolchain"

        set ::coursier::tcFolder $toolchainFolder
        file mkdir ${::coursier::tcFolder}

        if {[os.isWindows]} {
            set ::coursier::binPath [file normalize ${::coursier::tcFolder}/cs.exe]
        } else {
            set ::coursier::binPath [file normalize ${::coursier::tcFolder}/cs]
        }

        files.inDirectory ${::coursier::tcFolder} {
            if {![file exists ${::coursier::binPath}]} {
                log.info "Downloading Coursier"
                if {[os.isWindows]} {
                    files.download "https://github.com/coursier/launchers/raw/master/cs-x86_64-pc-win32.zip" ${::coursier::tcFolder}/cs-x86_64-pc-win32.zip
                    exec.run powershell -command "Expand-Archive cs-x86_64-pc-win32.zip -DestinationPath ."
                    exec.run powershell -command "mv cs-x86_64-pc-win32.exe cs.exe"
                    exec.run powershell -command ".\\cs.exe"
                } else {
                    files.download "https://github.com/coursier/launchers/raw/master/cs-x86_64-pc-linux.gz" ${::coursier::tcFolder}/cs-x86_64-pc-linux.gz
                    exec.run gunzip -d cs-x86_64-pc-linux.gz
                    exec.run mv cs-x86_64-pc-linux cs
                    exec.run chmod +x cs
                }

                #exec.run $tcFolder curl -fL "https://github.com/coursier/launchers/raw/master/cs-x86_64-pc-linux.gz" | gzip -d > cs
            } else {
                log.fine "Coursier TC ready in ${::coursier::binPath}"
            }
        }


    }

    ## Fetch
    ##############
    set currentDeps {}
    proc + {dep args} {
        set outFolder [uplevel {set outFolder}]
        #puts "Getting to $outFolder"
        lappend ::coursier::currentDeps $dep
        #::coursier::runtime::fetchSingle $outFolder org.apache.commons commons-lang3 3.14.0 --default=true --javadoc --sources
        log.info "Fetching $dep"
        #set files  [string map {\\ /} [::coursier::runtime::fetchSingle $dep {*}$args]]
        set files  [::coursier::runtime::fetchSingle $dep --default=true --javadoc --sources  {*}$args]

        log.debug "- Result ([llength $files]): $files"

        ## Parse result to sort dependencies in main artifact, javadoc, sources
        set sortedDeps [dict create]
        dict lappend sortedDeps $dep spec $dep
        foreach resolvedFile $files {
            set resolvedFile [string map {\\ /} $resolvedFile]
            set tail [file tail $resolvedFile]
            switch -glob $tail {
                *-sources.jar {
                    log.debug "$resolvedFile is sources"
                    dict lappend sortedDeps [string map {-sources ""} $tail] sources $resolvedFile
                }
                *-javadoc.jar {
                    log.debug "$resolvedFile is javadoc"
                    dict lappend sortedDeps [string map {-javadoc ""} $tail] doc $resolvedFile
                }
                default {
                    log.debug "$resolvedFile is lib"
                    dict lappend sortedDeps $tail lib [file normalize $resolvedFile]
                }
            }

        }
        log.debug "Result map: $sortedDeps"
        #exit 0
        #kiss::dependencies::addDeps [uplevel {set module}] {*}$files
        kiss::dependencies::addDeps [uplevel {set module}] $sortedDeps
    }

    proc fetchSpec {specId args} {

        set files  [::coursier::runtime::fetchSingle $specId --default=true --javadoc --sources  {*}$args]
        set sortedDeps [dict create]
        #dict lappend sortedDeps $dep spec $dep
        foreach resolvedFile $files {
            set resolvedFile [string map {\\ /} $resolvedFile]
            set tail [file tail $resolvedFile]
            set specKey $specId
            switch -glob $tail {
                *-sources.jar {
                    log.debug "$specId -> $resolvedFile is sources"
                    # [string map {-sources ""} $tail]
                    dict lappend sortedDeps [string map {-sources ""} $tail] sources $resolvedFile
                }
                *-javadoc.jar {
                    log.debug "$specId -> $resolvedFile is javadoc"
                    # [string map {-javadoc ""} $tail]
                    dict lappend sortedDeps [string map {-javadoc ""} $tail] doc $resolvedFile
                }
                default {
                    log.debug "$specId -> $resolvedFile is lib"
                    # $tail
                    dict lappend sortedDeps $tail lib [file normalize $resolvedFile]
                }
            }

        }
        return $sortedDeps

    }

    proc fetchSpecv2 {specId args} {

        set files  [::coursier::runtime::fetchSingle $specId --default=true --javadoc --sources  {*}$args]
        log.info "Fetched for $specId -> $files"
        set sortedDeps [dict create]
        #dict lappend sortedDeps $dep spec $dep
        foreach resolvedFile $files {
            set resolvedFile [string map {\\ /} $resolvedFile]
            set tail [file tail $resolvedFile]
            set specKey $specId
            switch -glob $tail {
                *-sources.jar {
                    log.debug "$resolvedFile is sources"
                    # [string map {-sources ""} $tail]
                    dict lappend sortedDeps $specKey sources $resolvedFile
                }
                *-javadoc.jar {
                    log.debug "$resolvedFile is javadoc"
                    # [string map {-javadoc ""} $tail]
                    dict lappend sortedDeps $specKey doc $resolvedFile
                }
                default {
                    log.debug "$resolvedFile is lib"
                    # $tail
                    dict lappend sortedDeps $specId lib [file normalize $resolvedFile]
                }
            }

        }
        return $sortedDeps

    }

    proc fetchAll {module deps} {

        set outFolder ${::coursier::tcFolder}/repository/$module
        file mkdir $outFolder

        ## Load deps
        eval $deps


    }

    proc fetchSingleLib {dep} {
        return [::coursier::runtime::fetchSingle $dep]
    }


    ## Java
    ############

    ## This method gets env settings for the target java and update current env
    proc selectJava {name args} {
        set jEnv [kiss::terminal::callIn ${::coursier::tcFolder} ${::coursier::binPath} java --jvm $name --env {*}$args]
        foreach {export v} $jEnv {
            puts "Coursier java env: $v"
            if {[string match JAVA_HOME=* $v]} {
                set ::env(JAVA_HOME) [string map {\" ""} [lindex [split $v =] end]]
                puts "New Java home: $::env(JAVA_HOME)"
                set ::env(PATH) "$::env(JAVA_HOME)/bin[kiss::files::pathSeparator]$::env(PATH)"
            }
        }
    }

    namespace eval runtime {

        proc fetchSingle {dep args} {
            set repos {}
            foreach r $::coursier::repositories {
                lappend repos -r $r
            }
            set resLibs [kiss::terminal::callIn ${::coursier::tcFolder} ${::coursier::binPath} fetch -q {*}$repos {*}$args $dep]
            #set resLibsNormalized [lmap f $resLibs {kiss::files::normalizePath $f}]
            set resLibsNormalized [kiss::files::normalizePath $resLibs]
            return $resLibsNormalized
        }
    }


    ####################
    ## Extension
    #####################
    kissb.extension coursier {

        init args {
            kiss::toolchain::init coursier
        }

        run args {
            exec.run ${::coursier::binPath} {*}$args
        }
        call args {
            return [exec.call ${::coursier::binPath} {*}$args]
        }

        install args {
            return [coursier.run install {*}$args]
        }

        setup args {
            return [exec.call ${::coursier::binPath} setup {*}$args]
        }

        env args {
            # Runs command with --env and using exec.call to return env result
            return [coursier.call {*}$args --env]
        }

        resolve module {
            ::coursier::resolveModule $module
        }

        fetch.classpath.of {dep {classifier ""} {type ""} args} {

            if {$classifier!=""} {
                lappend args -C $classifier
            }
            if {$type!=""} {
                lappend args -A $type
            }
            return [::coursier::runtime::fetchSingle $dep {*}$args]

        }


        classpath {dep {classifier ""} {type ""} args} {
            # Returns classpath string for dep
            return [files.joinWithPathSeparator  [coursier.fetch.classpath.of $dep $classifier $type {*}$args]]

        }

        ## App
        withApp {apps script} {
            # Runs provided script with environment path updated to provide applications listed in $apps
            #  apps - list of apps to be provided in path by coursier

            set jvmVersion   [vars.get scala.jvm.name 21]
            set compileEnv [exec.cmdGetBashEnv coursier.setup -q --env --jvm $jvmVersion --apps [join $apps ,]]
            exec.withEnv $compileEnv $script

        }
    }

    # Always init coursier on package require
    coursier.init
}

source [file dirname [info script]]/coursier.bom.plugin.tcl
