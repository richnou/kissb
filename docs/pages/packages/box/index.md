---
tags:
  - Since v2502
  - Containers
  - Utility
---


# Container Box

This KISSB extension provides a utility to create docker/podman containers to run some tools in a dedicated environment.

Users can enter the containers by opening a shell and work in the new environment as usual from the terminal.

This functionality is very similar to the [Distrobox](https://distrobox.it) tool, which is better supported.


## Quick Start

1. Create a box using a base image:

```console
Syntax=kissb .box.create NAME IMAGE
kissb .box.create test-leap opensuse/leap
```

2. List the boxes to check success:


```console
$ kissb .box.ls
INFO.top TCL version: 9.0
INFO.top KISSB Version=dev@dev
INFO.top Current GIT_ROOT=/home/rleys/git/kissb
INFO.top Running command box.ls: bin=box.ls, args=
INFO.top Image builder, selected runtime=podman
Available boxes:
- Box test-leap is running
```

3. Enter the box


```console
~ $ kissb .box.enter test-leap
INFO.top TCL version: 9.0
INFO.top KISSB Version=dev@dev
INFO.top Current GIT_ROOT=/home/rleys/git/kissb
INFO.top Running command box.enter: bin=box.enter, args= test-leap
INFO.top Image builder, selected runtime=podman
SUCC.top ☑ Entering test-leap with /bin/bash --norc - you are now in the box!
🐳xxx@test-leap ~📦 cat /etc/os-release
NAME="openSUSE Leap"
VERSION="15.6"
...
🐳xxx@test-leap📦
```

## Alias for kiss .box

To work with the box tool faster, you can define an alias:

```console
$ alias kbox="kissb .box"
$ kbox ls
```

## Sudo support

If the image used to create the box comes with the sudo utility installed, it can be created using the **--sudo** argument.
The current user will then be added to the suoders list with a No password rule, so that it is then easy to perform root operations like installing new packages in the image.

## .boxrc file

When entering a box terminal in a folder, if a file named **.boxrc** is present, it will be sourced.


=== ".boxrc"

    ```
    echo "Hello world!"
    ```

=== "Terminal"


    ```console hl_lines="8"
    $ kissb .box.enter test-leap
    INFO.top TCL version: 9.0
    INFO.top KISSB Version=dev@dev
    INFO.top Current GIT_ROOT=/home/rleys/git/kissb
    INFO.top Running command box.enter: bin=box.enter, args= test-leap
    INFO.top Image builder, selected runtime=podman
    SUCC.top ☑ Entering test-leap with /bin/bash --rcfile xxxx/.boxrc - you are now in the box!
    Hello World
    🐳rleys@test-leap ~/git/kissb/examples-kb-tcl/base_box📦
    ```



## Image Persistence

Please be aware that when the box container is destroyed, for example after a "box rm" command or a system reboot, the changes made in the running box are not persisted.

If you have added packages via sudo or a root terminal in the image, it is best to add them to a Dockerfile that can be used to rebuild the same image upon box restart.


## Box for EDA Tools (Cadence/Europractice)

If you are working with Cadence tools that support on distributions like RHEL8 or RHEL9 and require specific packages and fine tuning, you can use the following images:

* For RHEL9 Tools: [rleys/cds-box:rocky9]<https://hub.docker.com/r/rleys/cds-box>
* For RHEL8 Tools: [rleys/cds-box:rocky8]<https://hub.docker.com/r/rleys/cds-box>

If you have tool installation located at the standard path **/eda**, you can create the box this way:

```console
kissb .box.create cds rleys/cds-box:rocky9 -- -v /eda:/eda
```
