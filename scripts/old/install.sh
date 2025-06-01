#!/bin/bash


## Get TCL install script
#wget -qO- https://kissb.s3.de.io.cloud.ovh.net/kissb/dev/install.tcl | tclsh
cat install.tcl | tclsh

return 
installDir=/~/.kissb/install
clean_up () {
    ARG=$?
    rm -Rf $installDir
    exit $ARG
} 
trap clean_up EXIT


## Go to the temp directory
mkdir -p $installDir
pushd $installDir

## Get TCL install script
#wget -qO- https://raw.githubusercontent.com/richnou/kissb/main/scripts/linux/install.tcl | tclsh
cat install.tcl | tclsh

#popd
