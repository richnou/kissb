# Mkdocs

## Introduction

The Mkdocs plugin provides installation of a python venv and mkocs, with functions to build and serve documentation.

~~~~tcl 
package require mkdocs

# Load a base mkdocs toolchain locally
mkdocs::init

# Alternative: Load mkdocs with Material for mkdocs
mkdocs::init -material

# To build 
mkdocs::build 

# To Server in dev mode
mkdocs::serve
~~~~

## Usage with command line argument

~~~~tcl 
package require mkdocs

mkdocs::build $argv
~~~~

From the command line: 

> kissb -zip

Or to select between serving and building 

~~~~tcl 
package require mkdocs

switch $argv {
    -serve {
        mkdocs::serve
    }
    default {
        mkdocs::build $argv
    }
}
~~~~

From the command line, to serve:

> kissb -serve

to build: 

> kissb

## Usage with targets

~~~~tcl 
package require mkdocs

@ build {
    mkdocs::build
}
~~~~

# `build` function

**Default build output**: .kb/build/mkdocs 

- Use mkdocs::build to build the site, add `-zip` argument to create a zip file 
- Use The toplevel `build.name` variable to change the output zip and build folder names

~~~~tcl 
package require mkdocs

# Change build name to produce mydocs/ and mydocs.zip outputs
set build.name mydocs 

# Just build  the site folder 
mkdocs::build

# Build with ZIP output
mkdocs::build -zip
~~~~

## Deployment with Netlify