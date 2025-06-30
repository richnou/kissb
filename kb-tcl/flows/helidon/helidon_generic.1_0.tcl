package provide flow.helidon.generic 1.0


## Parameters
###################

vars.define flow.image.name         helidon-app     -doc "Image name of build Container image"
vars.define flow.image.tag          latest          -doc "Image tag of build Container image"

vars.set    flow.helidon.java.main  io.helidon.Main
vars.define flow.helidon.version    4.2.0           -doc "Version of Helidon Framework"

vars.set    flow._helidon.bomEnforced false 
proc flow.helidon.loadBOM args {

    if {!${::flow._helidon.bomEnforced}} {
        coursier.bom.enforce io.helidon:helidon-dependencies:[vars.get flow.helidon.version]
        vars.set flow._helidon.bomEnforced true  
    }
    
}

proc flow.helidon.getMPDependencies args {
    flow.helidon.loadBOM
    return {
        helidon-microprofile-core 
        helidon-microprofile-health 
        helidon-microprofile-config 
        helidon-microprofile-metrics 
        helidon-webserver-observe-info 
        helidon-webserver-observe-config
    }
}


