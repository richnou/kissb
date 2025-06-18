# Reference: Files

## Usage

**Overview**

This module offers a set of utilities for common file operations, including file manipulation, directory handling, and basic file management.
It focuses on simplicity and clarity, making it easy to perform tasks like deleting files, moving data, or downloading resources.

**Key Functions**

- **File/Directory Management**: Create directories, move files, delete files (with glob support).
- **File Operations**: Download files, make files executable, read file contents.
- **Contextual Tools**: Work within specific directories or scripts.

**Examples**

1. **Delete multiple files**:
   ```tcl
   files.delete *.log
   ```
2. **Download a file**:
   ```tcl
   files.download https://example.com/file.txt
   ```
3. **Make a file executable**:
   ```tcl
   files.makeExecutable script.sh
   ```


## Commands Reference

{%
    include-markdown "./kissb.files.methods.md"
    dedent=true
    heading-offset=1
%}
