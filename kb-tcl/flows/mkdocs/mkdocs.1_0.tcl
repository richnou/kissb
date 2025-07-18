# SPDX-FileCopyrightText: 2024 KISSB
#
# SPDX-License-Identifier: Apache-2.0
package provide flow.mkdocs 1.0
package require kissb.mkdocs

vars.define flow.mkdocs.presets \
            -doc "A list containing some mkdocs requirements presets from KISSB" {}



@ {init "Configure Mkdocs"} {

    log.info "Configuring Mkdocs, selected preset=[vars.get flow.mkdocs.presets]"
    mkdocs.init {*}[vars.get flow.mkdocs.presets]
}

@ {build "Build Mkdoc site and zip it"} : init {


    mkdocs.build -zip
}

@ {serve "Run mkdocs development server"} : init {


    mkdocs.serve
}


proc flow.enableNetlify args {

    package require kissb.netlify

    netlify.init

    @ {configure "Run Netlify Configure command to link site"} {
        netlify.run link
    }

    @ {deploy "Builds the site and deploys to netlify (in preview)"} : build {

        log.success "Deploying Site to netlify (args=$args)"



        netlify.run login
        netlify.run link
        netlify.run deploy -d [mkdocs::buildFolder] {*}$args
    }

    @ {deploy.prod "Runs the deploy target to production"} {

        > deploy --prod
    }

}
