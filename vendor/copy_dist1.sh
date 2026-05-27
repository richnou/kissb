#!/bin/bash
#

version=260106
tclversion=9.0.3

wget https://kissb.s3.de.io.cloud.ovh.net/tcl9/dist1/${version}/tcl9-dist1-x86_64-redhat-linux-rhel8-${tclversion}-${version}.tar.gz
rm -Rf tcl9-dist1-x86_64-redhat-linux-rhel8-${tclversion}-${version}
tar xvaf tcl9-dist1-x86_64-redhat-linux-rhel8-${tclversion}-${version}.tar.gz
rm tcl9-dist1-x86_64-redhat-linux-rhel8-${tclversion}-${version}.tar.gz

# Relink
rm -f tcl9 
ln -s tcl9-dist1-x86_64-redhat-linux-rhel8-${tclversion}-${version} tcl9