
netlify::init
mkdocs::init -material



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