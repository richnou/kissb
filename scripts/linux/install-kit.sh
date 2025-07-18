#!/usr/bin/env bash

{ # this ensures the entire script is downloaded #

## VERSION= 1.1

## KISSB Wrapper script to start kissb using terminal without installation

## Specify version here
kissbChannel=dev
kissbVersion=250601

## By default install to  local folder, if --user is set, install to  installDir=/~/.kissb/install
installDir=$(pwd)
#if [[ $1 == "--local" ]]
read -p "Would to like to install to your user home (~/.kissb/bin) (y/n) default=n ?" -e ITARGET </dev/tty
echo "Response: $ITARGET"
if [[ $ITARGET == "y" ]]
then
    installDir=~/.kissb/bin
    echo "* Installing to user home's $installDir"
    echo "* After installation, you can add $installDir to your PATH (do not use ~ character in the path)"
    mkdir -p $installDir

fi

## Download Kit
curl -sS https://kissb.s3.de.io.cloud.ovh.net/kissb/${kissbChannel}/${kissbVersion}/kissb-${kissbVersion} -o ${installDir}/kissb
chmod +x ${installDir}/kissb
echo "Done, KISSB is now installed at: $installDir"

} # this ensures the entire script is downloaded #
