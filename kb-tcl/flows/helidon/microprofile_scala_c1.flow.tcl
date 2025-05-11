# SPDX-FileCopyrightText: 2024 KISSB
#
# SPDX-License-Identifier: Apache-2.0

## Parameters
###################
vars.set java.main io.helidon.Main
vars.set image.name helidon-app
vars.set image.tag  latest

## Utils
###############
kissb.extension helidon {

    microprofile.bundles {module args} {
        foreach bundle $args {
            dependencies.add $module coursier io.helidon.microprofile.bundles:$bundle
        }
    }
}

## Flow
###############

# Load app C1 convention flow
flow.load scala/single_app_c1

## Load BOM
coursier.bom.enforce io.helidon:helidon-dependencies:4.0.11

#puts "BOM: [dict filter $::kiss::dependencies::modulesBom key *:helidon-microprofile-core]"

 
## Add dependencies
dependencies.add main coursier helidon-microprofile-core helidon-microprofile-health helidon-microprofile-config helidon-microprofile-metrics helidon-webserver-observe-info helidon-webserver-observe-config
#helidon.microprofile.bundles main 



## Add Targets
############

