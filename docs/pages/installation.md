# Installation

- **Latest Version:** {{ latest_dev_release() }}
- **Latest Docker image push (dev):** {{ latest_docker_push() }} , <https://hub.docker.com/r/rleys/kissb>{ target=_blank }

This page describes some methods to install KISSB, we recommend using the wrapper script or Single File Runtime as they are the easiest to use.




## Single File Runtime {.sfr}

KISSB is available as a single executable containing the required TCL runtime and libraries.
It is based on a 9 Kit which we are building specifically to release KISSB.

You can easily download the latest version to a folder or to your home:

```bash
curl -o- https://kissb.dev/get/install-kit.sh | bash
```

Alternatively, download the kissb runtime:

- For Windows: [Download KISSB kit v{{ latest_dev_release() }}](https://kissb.s3.de.io.cloud.ovh.net/kissb/dev/{{ latest_dev_release() }}/kissb-{{ latest_dev_release() }}.exe)
- For Linux:   [Download KISSB kit v{{ latest_dev_release() }}](https://kissb.s3.de.io.cloud.ovh.net/kissb/dev/{{ latest_dev_release() }}/kissb-{{ latest_dev_release() }})

Place the downloaded file in a folder present in your PATH, for example .local/bin under linux, rename it to "kissb", then you can use the kissb command anywhere in your terminal.

## Wrapper Script

To easily install kissb locally in a project and fix the build system version, you can use a wrapper script in the same fashion as with a Gradle or Maven wrapper script

```console
$ curl -o- https://kissb.dev/get/kissbw | /bin/bash
```

Or just download the script and give it runtime permission:

~~~console
$ wget -q https://kissb.dev/get/kissbw
$ chmod +x kissbw
$ ./kissbw
~~~

The Wrapper will in install a [Single File Runtime](#sfr) in your project's folder

## Archive Installation

!!! warning
    KISSB Archive don't include a TCL runtime, you must make sure that required dependencies are available on your system


### TCL dependencies

Kissb requires TCL 8.6 or TCL9 to be installed on your system, with **tcllib**,**tcltls** and **tdom**.

For TCL8  the required TCL packages are usually available for distributions, for example:

| OS | Installation | Requirements |
|----|--------------| ------------- |
| Ubuntu | sudo apt install tcl tcllib tcl-tls tdom | |
| Rocky Linux | sudo dnf install tcl tcllib tcltls tdom | Install EPEL: <https://wiki.rockylinux.org/rocky/repo/#notes-on-epel>{target=_blank} |

If you wish to use TCL9, it is best to use a pre-build binary distribution containing the required dependencies, such as the one we provide here: <https://tcl9.kissb.dev/dist1/>{target=_blank}


### Install Distribution Folder

Download the latest distribution from the desired track, and unpack it for example in ~/.kissb/install/TRACK

~~~bash
mkdir -p ~/.kissb/dist && cd ~/.kissb/dist
wget https://kissb.s3.de.io.cloud.ovh.net/kissb/dev/{{ latest_dev_release() }}/dist-{{ latest_dev_release() }}.zip
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

> alias kissb="docker run -v .:/cwd -u $(id -u ${USER}) --rm -it rleys/kissb:dev"

The following image tags are recommended: *latest* for the latest release, and *dev* for the most up to date version.

To update kissb, just pull the image on a regular basis.
