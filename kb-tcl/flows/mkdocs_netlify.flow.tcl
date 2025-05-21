# SPDX-FileCopyrightText: 2024 KISSB
#
# SPDX-License-Identifier: Apache-2.0

package require kissb.mkdocs
package require kissb.netlify

netlify::init
mkdocs::init -kissv1



@ {configure "Run Netlify Configure command to link site"} {
    netlify.run link
}
@ {build "Build Mkdoc site and zip it"} {
    mkdocs::build -zip
}
@ {serve "Run mkdocs development server"} {
    mkdocs::serve
}

@ {deploy "Builds the site and deploys to netlify (in preview)"} {

    log.success "Deploying Site to netlify (args=$args)"

    > build

    netlify::run login
    netlify::run link
    netlify::run deploy -d [mkdocs::buildFolder] {*}$args
}

@ {deploy.prod "Runs the deploy target to production"} {

    > deploy --prod
}
