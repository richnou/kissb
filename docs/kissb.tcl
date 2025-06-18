

# Required:
# Required: apt-get install libcairo2-dev libfreetype6-dev libffi-dev libjpeg-dev libpng-dev libz-dev pngquant

set build.name "kissb-docs"

flow.load mkdocs+netlify

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

@ generate.apidoc {

    package require git:https://github.com/richnou/ruff.git 2.5.0
    package require ruff 2.5.0

    makeMd "files.*"            pages/kissb-language/kissb.files.methods.md
    makeMd "kissb.args.*"       pages/kissb-language/kissb.args.methods.md
    makeMd "refresh.*"    pages/kissb-language/kissb.refresh.methods.md
    makeMd "exec.*"             pages/kissb-language/kissb.exec.methods.md

    makeMd "node.*"             pages/packages/nodejs/node.methods.md

    package require kissb.scala
    makeMd "scala.*"             pages/packages/jee/bloop.methods.md
    makeMd "bloop.*"             pages/packages/jee/scala.methods.md



}

@ generate.variables {

    set packagesNamespaces {

        kissb.verilator verilator
        kissb.cocotb    cocotb
        kissb.quarkus   quarkus
        kissb.coursier  coursier
    }

    files.withWriter data/packages.variables.yml {
        files.writer.printLine "id: \"packages.variable\""

        foreach {package ns} $packagesNamespaces {
            files.writer.printLine "${ns}:"
            files.writer.indent

            package require $package
            foreach v [info vars ::${ns}::*] {
                puts "V: $v"
                set vName [string range [string map {:: .} $v] 1 end]
                set localName [lindex [split $vName .] end]
                files.writer.printLine "${localName}: \"[set $v]\""
            }

            files.writer.outdent
        }
        package require kissb.verilator


    }
}
