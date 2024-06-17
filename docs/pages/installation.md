# Installation

**Current Version:** {{ latest_dev_release() }}

## Manualy

### Install TCL and TCL Lib

Kissb requires TCL 8 to be installed on your system:

| OS | Installation | Requirements |
|----|--------------| ------------- |
| Ubuntu |  sudo apt install tcl tcllib        | |
| Rocky Linux |  sudo dnf install tcl tcllib       | Install EPEL: [https://wiki.rockylinux.org/rocky/repo/#notes-on-epel](https://wiki.rockylinux.org/rocky/repo/#notes-on-epel){target=_blank} |

### Install Distribution Folder 

Download the latest distribution, and unpack it for example in .kissb/dist

~~~bash 
mkdir -p ~/.kissb/dist && cd ~/.kissb/dist
wget https://kissb.s3.de.io.cloud.ovh.net/kissb/dev/dist-{{ latest_dev_release() }}.zip
unzip dist-{{ latest_dev_release() }}.zip
# Make a link as "current", so that kissb can update itself
ln -s current kissb-{{ latest_dev_release() }}
~~~

Then add the bin folder to your path, or link the "kissb" script from the bin folder to a folder already on your path: 

~~~bash
# In .bashrc for example
export PATH="~/.kissb/dist/current/bin:$PATH"
~~~

## Docker

You can use our docker image to run kissb quickly, by running the image and mapping the current folder to the container's /cwd folder.
For example, setup an alias in your terminal to run the image with your user id:

> alias kissb="docker run -v .:/cwd -u $(id -u ${USER}) --rm -it rleys/kissb:latest"

The following image tags are recommended: *latest* for the latest release, and *dev* for the most up to date version.

To update kissb, just pull the image on a regular basis.

## Flatpack