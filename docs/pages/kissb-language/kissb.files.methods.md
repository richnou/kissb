
## <a name='::files.appendLine'></a>files\.appendLine

Appends Line to provided file


> `files.appendLine` *`f ?args?`*<br>

### <a name='Parameters'></a>Parameters

|||
|----|----|
|`f`|Target file|
|`args`|joined to a default string with join|


## <a name='::files.appendText'></a>files\.appendText

Appends test to provided file


> `files.appendText` *`f ?args?`*<br>

### <a name='Parameters'></a>Parameters

|||
|----|----|
|`f`|Target file|
|`args`|joined to a default string with join|


## <a name='::files.compressDir'></a>files\.compressDir

Compress dir into output archive
@arg --rename , input dir will be renamed to out file name in output tar


> `files.compressDir` *`dir out ?args?`*<br>

### <a name='Parameters'></a>Parameters

|||
|----|----|
|`dir`|Not documented.|
|`out`|Not documented.|


## <a name='::files.cp'></a>files\.cp

Copy file to directory


> `files.cp` *`f dir`*<br>

### <a name='Parameters'></a>Parameters

|||
|----|----|
|`f`|source file|
|`dir`|target directory|


## <a name='::files.cpSubst'></a>files\.cpSubst


> `files.cpSubst` *`files dir`*<br>

### <a name='Parameters'></a>Parameters

|||
|----|----|
|`files`|Not documented.|
|`dir`|Not documented.|


## <a name='::files.delete'></a>files\.delete

Delete provided files in the args list - if a file is not a regular file or directory, the argument is treated as a glob to delete multiple files at once


> `files.delete` *`?args?`*<br>

### <a name='Parameters'></a>Parameters

|||
|----|----|
|`args`|paths to files/directories or glob to be deleted|


### <a name='Description'></a>Description

Examples:

```tcl
files.delete directory1 file2
files.delete *.log
```

## <a name='::files.download'></a>files\.download

Download source file to target file using wget


> `files.download` *`src ?out?`*<br>

### <a name='Parameters'></a>Parameters

|||
|----|----|
|`src`|Not documented.|
|`out`|Not documented. Optional, default `""`.|


## <a name='::files.downloadOrRefresh'></a>files\.downloadOrRefresh

Downloads file from the URL if needed, or if refresh key is set


> `files.downloadOrRefresh` *`url refresh ?outFile?`*<br>

### <a name='Parameters'></a>Parameters

|||
|----|----|
|`url`|Not documented.|
|`refresh`|Not documented.|
|`outFile`|Not documented. Optional, default `""`.|


## <a name='::files.extract'></a>files\.extract


> `files.extract` *`f ?args?`*<br>

### <a name='Parameters'></a>Parameters

|||
|----|----|
|`f`|Not documented.|


## <a name='::files.extractAndDelete'></a>files\.extractAndDelete


> `files.extractAndDelete` *`f ?args?`*<br>

### <a name='Parameters'></a>Parameters

|||
|----|----|
|`f`|Not documented.|


## <a name='::files.getScriptDirectory'></a>files\.getScriptDirectory

Returns the directory of the current running script


> `files.getScriptDirectory` *`?args?`*<br>

### <a name='Parameters'></a>Parameters

|||
|----|----|


### <a name='Return_value'></a>Return value

Returns the directory of the current running script

## <a name='::files.globAll'></a>files\.globAll


> `files.globAll` *`?args?`*<br>

### <a name='Parameters'></a>Parameters

|||
|----|----|


## <a name='::files.globFiles'></a>files\.globFiles


> `files.globFiles` *`?args?`*<br>

### <a name='Parameters'></a>Parameters

|||
|----|----|


### <a name='Description'></a>Description

## <a name='::files.inBuildDirectory'></a>files\.inBuildDirectory


> `files.inBuildDirectory` *`d script`*<br>

### <a name='Parameters'></a>Parameters

|||
|----|----|
|`d`|Not documented.|
|`script`|Not documented.|


## <a name='::files.inDirectory'></a>files\.inDirectory


> `files.inDirectory` *`d script`*<br>

### <a name='Parameters'></a>Parameters

|||
|----|----|
|`d`|Not documented.|
|`script`|Not documented.|


## <a name='::files.isExecutable'></a>files\.isExecutable

Returns true if a file is executable for the owner by default


> `files.isExecutable` *`f ?for?`*<br>

### <a name='Parameters'></a>Parameters

|||
|----|----|
|`f`|Not documented.|
|`for`|pass -group or -other or -user to check specific group execution Optional, default `-user`.|


### <a name='Return_value'></a>Return value

Returns true if a file is executable for the owner by default

## <a name='::files.joinWithPathSeparator'></a>files\.joinWithPathSeparator


> `files.joinWithPathSeparator` *`?args?`*<br>

### <a name='Parameters'></a>Parameters

|||
|----|----|


### <a name='Description'></a>Description

## <a name='::files.makeExecutable'></a>files\.makeExecutable

Makes a file executable by setting user permissin to +x


> `files.makeExecutable` *`f ?args?`*<br>

### <a name='Parameters'></a>Parameters

|||
|----|----|
|`f`|Not documented.|


## <a name='::files.mkdir'></a>files\.mkdir

Create directory


> `files.mkdir` *`dir`*<br>

### <a name='Parameters'></a>Parameters

|||
|----|----|
|`dir`|path to directory to be created|


## <a name='::files.moveFileToTemp'></a>files\.moveFileToTemp

Reads and write provided file to a tempfile


> `files.moveFileToTemp` *`f`*<br>

### <a name='Parameters'></a>Parameters

|||
|----|----|
|`f`|Source file path|


### <a name='Description'></a>Description

If a file is in Zipfs archive but needs to be used by an external command for example, move it to a temporary file on host

### <a name='Return_value'></a>Return value

Returns the path to the created temp file

## <a name='::files.mv'></a>files\.mv


> `files.mv` *`src dst`*<br>

### <a name='Parameters'></a>Parameters

|||
|----|----|
|`src`|Not documented.|
|`dst`|Not documented.|


## <a name='::files.read'></a>files\.read


> `files.read` *`f`*<br>

### <a name='Parameters'></a>Parameters

|||
|----|----|
|`f`|Not documented.|


## <a name='::files.require'></a>files\.require

Require File, if not present, run script


> `files.require` *`f script`*<br>

### <a name='Parameters'></a>Parameters

|||
|----|----|
|`f`|File to be required|
|`script`|Script to be evaluated if the file is not present|


## <a name='::files.requireOrForce'></a>files\.requireOrForce


> `files.requireOrForce` *`f script`*<br>

### <a name='Parameters'></a>Parameters

|||
|----|----|
|`f`|Not documented.|
|`script`|Not documented.|


## <a name='::files.requireOrRefresh'></a>files\.requireOrRefresh

Executes `$script` if the provided file `$f` doesn't exist, or the refresh key `$key` was requested


> `files.requireOrRefresh` *`f key script`*<br>

### <a name='Parameters'></a>Parameters

|||
|----|----|
|`f`|path of file to check for existence|
|`key`|the key provided by user to kissb as argument --refresh-**key** to force file refresh|
|`script`|Script executed, user must ensure it creates the requested file. File path is passed as ${\_\_f} variable|


### <a name='Description'></a>Description

Doesn't return anything.

## <a name='::files.sha256'></a>files\.sha256

Checksum the provided file and write to a .sha256 file


> `files.sha256` *`file ?args?`*<br>

### <a name='Parameters'></a>Parameters

|||
|----|----|
|`file`|Sourec file to checksum|
|`args`|Use -nowrite to not  write the sha to the file output|


### <a name='Return_value'></a>Return value

Returns the calculated sha if -nowrite, or the path to checksum file

## <a name='::files.tarDir'></a>files\.tarDir


> `files.tarDir` *`dir out ?args?`*<br>

### <a name='Parameters'></a>Parameters

|||
|----|----|
|`dir`|Not documented.|
|`out`|Not documented.|


## <a name='::files.untar'></a>files\.untar


> `files.untar` *`f ?args?`*<br>

### <a name='Parameters'></a>Parameters

|||
|----|----|
|`f`|Not documented.|


## <a name='::files.unzip'></a>files\.unzip

Unzip


> `files.unzip` *`f ?args?`*<br>

### <a name='Parameters'></a>Parameters

|||
|----|----|
|`f`|Not documented.|


## <a name='::files.withGlobAll'></a>files\.withGlobAll


> `files.withGlobAll` *`?args? script`*<br>

### <a name='Parameters'></a>Parameters

|||
|----|----|
|`script`|Not documented.|


## <a name='::files.withGlobFiles'></a>files\.withGlobFiles


> `files.withGlobFiles` *`?args? script`*<br>

### <a name='Parameters'></a>Parameters

|||
|----|----|
|`script`|Not documented.|


## <a name='::files.withWriter'></a>files\.withWriter

Files writer


> `files.withWriter` *`outPath script`*<br>

### <a name='Parameters'></a>Parameters

|||
|----|----|
|`outPath`|Not documented.|
|`script`|Not documented.|


## <a name='::files.writer.indent'></a>files\.writer\.indent


> `files.writer.indent` *`?args?`*<br>

### <a name='Parameters'></a>Parameters

|||
|----|----|


## <a name='::files.writer.outdent'></a>files\.writer\.outdent


> `files.writer.outdent` *`?args?`*<br>

### <a name='Parameters'></a>Parameters

|||
|----|----|


## <a name='::files.writer.printLine'></a>files\.writer\.printLine


> `files.writer.printLine` *`?args?`*<br>

### <a name='Parameters'></a>Parameters

|||
|----|----|


## <a name='::files.writeText'></a>files\.writeText

Writes text to provided file


> `files.writeText` *`f ?args?`*<br>

### <a name='Parameters'></a>Parameters

|||
|----|----|
|`f`|Target file|
|`args`|joined to a default string with join|


## <a name='::files.zipDir'></a>files\.zipDir


> `files.zipDir` *`dir out ?args?`*<br>

### <a name='Parameters'></a>Parameters

|||
|----|----|
|`dir`|Not documented.|
|`out`|Not documented.|


