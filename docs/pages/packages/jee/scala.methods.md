
## <a name='::scala.addDependencies'></a>scala\.addDependencies

Add dependencies to specified module
If a dependency is named @xxxx it will refer to another project module


> `scala.addDependencies` *`module ?args?`*<br>

### <a name='Parameters'></a>Parameters

|||
|----|----|
|`module`|Not documented.|


## <a name='::scala.amm'></a>scala\.amm

Run provided script File using ammonite


> `scala.amm` *`scriptFile`*<br>

### <a name='Parameters'></a>Parameters

|||
|----|----|
|`scriptFile`|Not documented.|


## <a name='::scala.compile'></a>scala\.compile

Compile module


> `scala.compile` *`module ?args?`*<br>

### <a name='Parameters'></a>Parameters

|||
|----|----|
|`module`|Not documented.|


## <a name='::scala.defaultRunEnv'></a>scala\.defaultRunEnv

Runs coursier to get default scala and jvm versions set in this plugin


> `scala.defaultRunEnv` *`?args?`*<br>

### <a name='Parameters'></a>Parameters

|||
|----|----|


### <a name='Return_value'></a>Return value

Returns an environment dict that can be used by the exec module to run scala command line or scalac

## <a name='::scala.getModuleEnv'></a>scala\.getModuleEnv

Runs couriser to get scala and jvm path environment for the provided module


> `scala.getModuleEnv` *`module`*<br>

### <a name='Parameters'></a>Parameters

|||
|----|----|
|`module`|Not documented.|


### <a name='Return_value'></a>Return value

Returns an environment dict that can be used by the exec module to run scala command line or scalac

## <a name='::scala.init'></a>scala\.init

Init project module, this method creates ${module}.xxx variables used by other functions and tools to build the module and output files in the desired location
Users can provide arguments to customize behavior.


> `scala.init` *`module ?args?`*<br>

### <a name='Parameters'></a>Parameters

|||
|----|----|
|`module`|Not documented.|
|`args`|Supported arguments described below:|
|`-baseDir`|Base directory of module, default to current directory|
|`-javac-args`|Arguments for javac|
|`-jvm-name`|JVM name used to run scala, ${::jvm.default.version} - The name is used by coursier to use a specific vendor of the JVM.|
|`-jvm-version`|JVM version used to run scala, default to ${::jvm.default.version}|
|`-scala`|Scala version , default to ${::scala.default.version} module variable|
|`-scalac-args`|Arguments for scalac|
|`-srcDirs`|Source directories to use for compilation|
|`-target`|JVM version target output for scalac, default to ${::jvm.default.version}|


## <a name='::scala.jvm'></a>scala\.jvm

Select the JVM version for the application module


> `scala.jvm` *`module version ?descriptor?`*<br>

### <a name='Parameters'></a>Parameters

|||
|----|----|
|`module`|Not documented.|
|`version`|Not documented.|
|`descriptor`|Not documented. Optional, default `""`.|


## <a name='::scala.repl'></a>scala\.repl


> `scala.repl` *`?args?`*<br>

### <a name='Parameters'></a>Parameters

|||
|----|----|


## <a name='::scala.resolveDeps'></a>scala\.resolveDeps

Returns list of dependencies, including module dependencies output build directory in classpath
If -classpath if passed, module's own classes output is added to the results to generate a full classpath


> `scala.resolveDeps` *`module ?args?`*<br>

### <a name='Parameters'></a>Parameters

|||
|----|----|
|`module`|Not documented.|
|`-classpath`|Pass  to add module's output class directory to list of dependencies|


### <a name='Return_value'></a>Return value

Returns list of dependencies, including module dependencies output build directory in classpath
If -classpath if passed, module's own classes output is added to the results to generate a full classpath

## <a name='::scala.run'></a>scala\.run

Run module's provided main class - doesn't build


> `scala.run` *`module mainClass ?args?`*<br>

### <a name='Parameters'></a>Parameters

|||
|----|----|
|`module`|Not documented.|
|`mainClass`|Not documented.|


## <a name='::scala.runner'></a>scala\.runner


> `scala.runner` *`?args?`*<br>

### <a name='Parameters'></a>Parameters

|||
|----|----|


## <a name='::scala.script'></a>scala\.script


> `scala.script` *`file`*<br>

### <a name='Parameters'></a>Parameters

|||
|----|----|
|`file`|Not documented.|


