

# Required:
# Required: apt-get install libcairo2-dev libfreetype6-dev libffi-dev libjpeg-dev libpng-dev libz-dev pngquant

set build.name "kissb-docs"

package require flow.mkdocs 1.0

vars.set flow.mkdocs.presets -kissv2

flow.enableNetlify

# Ensure node initialised
node.init
npm.exec --version
node.exec --version


@ copy-scripts {
    files.delete pages/get/*
    files.cp ../scripts/wrapper/kissbw      pages/get/
    files.cp ../scripts/linux/install-kit.sh    pages/get/
}


@> copy-scripts



proc makeMd {pattern file} {

    ::ruff::document :: -pattern $pattern -include "procs" -includeprocs procs -format markdown -md_skiplevel 2 -outdir [file dirname $file] -outfile [file tail $file]

}

proc variablesMd {pattern file} {

}

@ loadRuff {
    package require git:https://github.com/richnou/ruff.git 2.5.0
    package require ruff 2.5.0
}

@ generate.apidoc {

    package require git:https://github.com/richnou/ruff.git 2.5.0
    package require ruff 2.5.0

    makeMd "files.*"            pages/kissb-language/kissb.files.methods.md
    makeMd "kissb.args.*"       pages/kissb-language/kissb.args.methods.md
    makeMd "refresh.*"    pages/kissb-language/kissb.refresh.methods.md
    makeMd "exec.*"             pages/kissb-language/kissb.exec.methods.md

    makeMd "node.*"             pages/packages/nodejs/node.methods.md

    package require kissb.scala
    makeMd "scala.*"             pages/packages/jee/scala.methods.md
    makeMd "bloop.*"             pages/packages/jee/bloop.methods.md



}


@ generate.flows : loadRuff {





    ## Flow Variables
    ###################
    set flowPackages {

        flow.mkdocs 1.0 mkdocs
        flow.scala.applib 1.0 scala

    }



    # Generate flows file with all vars
    files.withWriter data/flows.variables.yml {

        files.writer.printLine "id: \"flows.variable\""


        puts "all flow packages: $flowPackages"
        foreach {package version ns} $flowPackages {


            # Common Key for this flow is the flow name
            set flowName [string map {. _} ${package}.$version]
            files.writer.printLine "$flowName:"
            files.writer.indent

            # Load Flow package and generate a key for each value
            # Also write a table file to be included in the main doc
            set mdFile pages/flows/_vars/${flowName}.inc.md
            files.writeLine $mdFile "|Variable|Description|Default Value|Env. Override|"
            files.appendLine $mdFile "|---|---|---|---|"



            #catch {package forget $package}
            package require $package
            #$version

            puts "package: $package - [info vars ::flow.*]"

            foreach v [info vars ::flow.*] {
                puts "V: $v"
                set vNoNS [string range $v 2 end]


                set localName [join [lrange [split $v .] 1 end] _]
                #set vName [string range [string map {:: .} $v] 1 end]
                #set localName [lindex [split $vName .] end]
                #files.writer.printLine "${localName}: \"[set $v]\""
                files.writer.printLine "${localName}_default: \"[vars.get $v]\""

                set vDoc [vars.getDoc $vNoNS]
                if {$vDoc==false} {
                    log.warn "Variable $v has no documentation"
                    set vDoc ""
                }
                files.writer.printLine "${localName}_doc: \"$vDoc\""

                # Add Line to Markdown
                files.appendLine $mdFile "|$vNoNS|$vDoc|[set $v]|[string toupper [string map {. _} $vNoNS]]|"

                #unset $v
            }


            ## Generate RUFF Documentation
            ########
            makeMd "flow.*"             pages/flows/_methods/${flowName}.inc.md


            package forget $package

            # Forget all flow. variables to avoid conflicts between packages
            foreach v [info vars ::flow.*] {
                unset $v
            }

            # Forget all flow. methods to avoid conflicts between packages
            foreach v [info commands ::flow.*] {
                rename $v ""
            }
        }

        files.writer.outdent
    }
}

@ generate.variables {

    ## Package Variables
    ############"
    set packagesNamespaces {

        kissb.scala         {scala scalac bloop}    pages/packages/jee/_scala.vars.inc.md
        kissb.coursier      coursier                pages/packages/jee/_coursier.vars.inc.md
        kissb.eda.verilator verilator               pages/packages/eda/_verilator.vars.inc.md
        kissb.eda.cocotb    cocotb                  pages/packages/eda/_cocotb.vars.inc.md

    }

    files.withWriter data/packages.variables.yml {
        files.writer.printLine "id: \"packages.variable\""




        foreach {package nslist tableFile} $packagesNamespaces {

            package require $package

            ## Generate Table for the package variables
            files.writeLine $tableFile  "|Variable|Description|Default Value|Env. Override|"
            files.appendLine $tableFile "|---|---|---|---|"

            foreach ns $nslist {
                files.writer.printLine "${ns}:"
                files.writer.indent






                foreach v [info vars ::${ns}.*] {
                    puts "V: $v"

                    set vNoNS [string range $v 2 end]

                    set localName [join [lrange [split $v .] 1 end] _]
                    #set vName [string range [string map {:: .} $v] 1 end]
                    #set localName [lindex [split $vName .] end]
                    #files.writer.printLine "${localName}: \"[set $v]\""
                    files.writer.printLine "$localName: \"[set $v]\""

                    # Add Line to Markdown
                    set vDoc [vars.getDoc $vNoNS]
                    if {$vDoc==false} {
                        log.warn "Variable $v has no documentation"
                        set vDoc ""
                    }
                    files.appendLine $tableFile "|$vNoNS|$vDoc|[set $v]|[string toupper [string map {. _} $vNoNS]]|"
                }

                files.writer.outdent

            }
        }
        #package require kissb.verilator




    }



    puts "EOF vars"


}
