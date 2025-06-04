

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
