vars.set kissb.userhome $::env(HOME)
vars.set kissb.home $::env(HOME)/.kissb
files.mkdir ${kissb.home}

vars.set kissb.projectFolder [pwd]
vars.set kissb.buildDir ${kissb.projectFolder}/.kb

vars.set kissb.distribution portable
