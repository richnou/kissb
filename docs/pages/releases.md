# Releases

Download Links for Releases:

| Version | Distribution | Link |
|----|----|----|
| 250601 | Single File | <{{s3.kissb_dev_250601}}/kissb-250601> |
| 250601 | Archive | <{{s3.kissb_dev_250601}}/dist-250601.zip> |
| 250502 | Single File | <{{s3.kissb_dev_250502}}/kissb-250502> |
| 250502 | Archive | <{{s3.kissb_dev_250502}}/dist-250502.zip> |
| 250501 | Single File | <{{s3.kissb_dev_250501}}/kissb-250501> |
| 250501 | Archive | <{{s3.kissb_dev_250501}}/dist-250501.zip> |


## 250601

- Added utility to create a new Single File Runtime from an existing runtime, while adding new TCL package or configuration file loaded on startup. This feature allows creating new kissb variants with custom packages and scripts, for example to distribute customized runtimes for specific applications or environments
- Updated the Box plugin: GUI applications run in the box now still run after a logout/login and the container is still running, fixed user register in image's sudo.
- Added environment variables to load extra lib files or augment the tcl pakage search path:
  - KISSB_LIBPATH can be set from env to add folder from which to load .lib.tcl files
  - KISSB_PACKAGEPATH can be set from env to add folder from which packages can be found

**Full Changelog**: https://github.com/richnou/kissb/compare/v250502...v250601

## 250502


- Added Box plugin to create and manage containers to use as dev environment (as shell or via devcontainer in vscode)
- Added more utilities to core extensions, see documentation for details
- Added gpg signature to produce artifacts

**Full Changelog**: https://github.com/richnou/kissb/compare/v250501...v250502

## 250501

* Updated main modules to be TCL9 Compatible
* Added more utilities to core kissb library for file manipulation (download, compression, extraction) and variable definition for modules
* Improved workflow of modules for mkdocs, netlify, python3, nodejs and more
* Improved Cocotb and Verilator workflows
