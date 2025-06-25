# SPDX-FileCopyrightText: 2024 KISSB
#
# SPDX-License-Identifier: Apache-2.0
package provide flow.mkdocs 1.0
package require kissb.mkdocs

vars.define flow.mkdocs.presets \
            -doc "A list containing some mkdocs requirements presets from KISSB" {}





@ {build "Build Mkdoc site and zip it"} {

    mkdocs.init {*}[vars.get flow.mkdocs.presets]
    mkdocs.build -zip
}

@ {serve "Run mkdocs development server"} {

    mkdocs.init {*}[vars.get flow.mkdocs.presets]
    mkdocs.serve
}


proc flow.enableNetlify args {

    package require kissb.netlify

    netlify.init

    @ {configure "Run Netlify Configure command to link site"} {
        netlify.run link
    }

    @ {deploy "Builds the site and deploys to netlify (in preview)"} {

        log.success "Deploying Site to netlify (args=$args)"

        > build

        netlify.run login
        netlify.run link
        netlify.run deploy -d [mkdocs::buildFolder] {*}$args
    }

    @ {deploy.prod "Runs the deploy target to production"} {

        > deploy --prod
    }

}
