#!/bin/bash

docker run --rm -it -u $(id -u):$(id -g) -v .:/build rleys/kissb-tclsh9-static-full:latest ./copy.tcl
pushd tcl9/bin
rm -f tclsh && ln -s tclsh9.0 tclsh
#-it /install-tcl/bin/tclsh9.0 "puts hi"