
## <a name='::exec.bashEnvToDict'></a>exec\.bashEnvToDict

Converts "export XXX=YYY" lines to an environment dict


> `exec.bashEnvToDict` *`str`*<br>

### <a name='Parameters'></a>Parameters

|||
|----|----|
|`str`|Not documented.|


## <a name='::exec.call'></a>exec\.call


> `exec.call` *`?args?`*<br>

### <a name='Parameters'></a>Parameters

|||
|----|----|


## <a name='::exec.call.in'></a>exec\.call\.in


> `exec.call.in` *`pwd ?args?`*<br>

### <a name='Parameters'></a>Parameters

|||
|----|----|
|`pwd`|Not documented.|


## <a name='::exec.cmdGetBashEnv'></a>exec\.cmdGetBashEnv

Runs a command and returns a dict of env based on export lines


> `exec.cmdGetBashEnv` *`?args?`*<br>

### <a name='Parameters'></a>Parameters

|||
|----|----|


## <a name='::exec.run'></a>exec\.run


> `exec.run` *`?args?`*<br>

### <a name='Parameters'></a>Parameters

|||
|----|----|


## <a name='::exec.run.in'></a>exec\.run\.in


> `exec.run.in` *`pwd ?args?`*<br>

### <a name='Parameters'></a>Parameters

|||
|----|----|
|`pwd`|Not documented.|


## <a name='::exec.withEnv'></a>exec\.withEnv

Runs the script provided in `$args` list with a temporary environment modified using the provided envDict.


> `exec.withEnv` *`envDict ?args?`*<br>

### <a name='Parameters'></a>Parameters

|||
|----|----|
|`envDict`|Env dict format: {VARNAME {merge 0/1 value VAL} ... }|
|`merge`|<ul><li>Merge = 1, the VARNAME will be added to any existing environment value for that name </li><li> Merge = 0 , the VARNAME will be overriden by value </li>|


