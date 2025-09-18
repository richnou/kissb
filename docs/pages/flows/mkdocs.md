---
tags:
  - Documentation
  - Mkdocs
  - Netlify
---


# Mkdocs v1.0

The mkdocs flow installs [Mkdocs](https://www.mkdocs.org/){target=_blank} in a python venvironment in the build folder and offers targets to serve or build the site.

It also offers extra targets to publish the site to:

- Netlify (link the site to your account, publish to preview and prod)

To load the flow in your build file:

~~~tcl
package require flow.mkdocs 1.0
~~~

Make sure that your local folder has a properly configured Mkdocs project, then:

~~~console
$ ./kissbw serve # To start mkdocs dev server
$ ./kissbw build # Generate static site
~~~

## Flow Variables

Before or after Loading the flow, you can set configuration variables:

~~~tcl
package require flow.mkdocs 1.0

vars.set CONFIGURATION VALUE
~~~

{%
    include-markdown "./_vars/flow_mkdocs_1_0.inc.md"
%}

## Python Plugin installation

To install mkdocs plugins or python packages, create a requirements.txt file and add packages.

When running mkdocs, the packages will be installed.

This method can be used to install for example the popular [Material for Mkdocs Theme](https://squidfunk.github.io/mkdocs-material/){target=_blank}


## Enable Netlify

To deploy your mkdocs site to netlify, enable the netlify target using the `flow.enableNetlify` command:

~~~tcl
package require flow.mkdocs 1.0

flow.enableNetlify
~~~

You can then use the `configure`,`deploy` and `deploy.prod` targets:

~~~console
$ ./kissbw configure # Login and Link your site 
$ ./kissbw deploy # Builds the site then publish as preview
$ ./kissbw deploy.prod # Builds the site then publish as production
~~~