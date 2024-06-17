# Installation

## Docker

You can use our docker image to run kissb quickly, by running the image and mapping the current folder to the container's /cwd folder.
For example, setup an alias in your terminal to run the image with your user id:

> alias kissb="docker run -v .:/cwd -u $(id -u ${USER}) --rm -it rleys/kissb:latest"

The following image tags are recommended: *latest* for the latest release, and *dev* for the most up to date version.

To update kissb, just pull the image on a regular basis.

## Flatpack