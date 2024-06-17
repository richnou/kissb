
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
    
    > build
    
    netlify::run login
    netlify::run link
    netlify::run deploy -d [mkdocs::buildFolder] $args
}