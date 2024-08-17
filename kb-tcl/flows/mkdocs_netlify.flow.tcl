# SPDX-FileCopyrightText: 2024 KISSB
#
# SPDX-License-Identifier: Apache-2.0

package require kissb.mkdocs
package require kissb.netlify

netlify::init
mkdocs::init -kissv1



@ configure {

}
@ build {
    mkdocs::build -zip
}
@ serve {
    mkdocs::serve
}

@ deploy {
    
    log.success "Deploying Site to netlify (args=$args)"
    
    > build
    
    netlify::run login
    netlify::run link
    netlify::run deploy -d [mkdocs::buildFolder] {*}$args
}

@ deploy.prod {

    > deploy --prod
}