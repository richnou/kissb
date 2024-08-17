# SPDX-FileCopyrightText: 2024 KISSB 2024
#
# SPDX-License-Identifier: GPL-3.0-or-later

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