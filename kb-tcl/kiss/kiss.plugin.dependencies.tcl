##############################
## Dependencies extension
##############################
kissb.extension dependencies {


    bom dict {
        ## Save provided dict in bom


        #log.info "Adding BOM: $spec"
        ::kiss::dependencies::addBOM $dict
    }

    add {module resolver args} {

        foreach dSpecs $args {
            foreach dSpec $dSpecs {
                log.debug "Adding Dependency: $dSpec"
                ::kiss::dependencies::addDepSpec $module $dSpec $resolver
            }
        }

    }

    getDeps {module args} {
        return [::kiss::dependencies::getDeps $module]
    }

    resolve {module type args} {
        return [::kiss::dependencies::resolveDeps $module $type]
    }

    isScopeDefined module {
        return [::kiss::dependencies::isScopeDefined $module]
    }

    url.toFolder {folder envVAR args} {
        # Resolve URL to folder
    }
}
