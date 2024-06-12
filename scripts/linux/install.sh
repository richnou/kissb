#!/bin/bash

installDir=/tmp/kiss.install
clean_up () {
    ARG=$?
    rm -Rf $installDir
    exit $ARG
} 
trap clean_up EXIT


## Go to the temp directory
#mkdir -p /tmp/kiss.install
#pushd /tmp/kiss.install

## Get TCL install script
#wget -O - https://raw.githubusercontent.com/richnou/kissb/main/kb-tcl/pkgIndex.tcl?token=GHSAT0AAAAAACH3352E4BBISH4B7XOLLTKEZTINCQQ | tclsh
cat install.tcl | tclsh

#popd
