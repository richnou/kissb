vars.set kissb.userhome $::env(HOME)
vars.set kissb.home $::env(HOME)/.kissb
files.mkdir ${kissb.home}

vars.set kissb.projectFolder [pwd]
vars.set kissb.buildDir ${kissb.projectFolder}/.kb

vars.set kissb.distribution portable

# KISSB_LIBPATH can be set to add folders where .lib.tcl from users will be search for
vars.define kissb.libpath ""

# KISSB_PACKAGEPATH can be set to add folders where packages will be searched for.
vars.define kissb.packagepath ""
