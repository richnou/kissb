
## <a name='::kissb.args.after'></a>kissb\.args\.after


> `kissb.args.after` *`v default ?to? ?varname?`*<br>

### <a name='Parameters'></a>Parameters

|||
|----|----|
|`v`|Not documented.|
|`default`|Not documented.|
|`to`|Not documented. Optional, default `""`.|
|`varname`|Not documented. Optional, default `""`.|


### <a name='Description'></a>Description

## <a name='::kissb.args.contains'></a>kissb\.args\.contains

Tests if `$args` contains a specific argument, runs script if so, or elseScript if provided


> `kissb.args.contains` *`v ?script? ?else? ?elseScript?`*<br>

### <a name='Parameters'></a>Parameters

|||
|----|----|
|`v`|Value to be tested|
|`script`|Script to be run if `$args` contains `$v` Optional, default `""`.|
|`else`|Dummy word for syntax, just write "else" Optional, default `""`.|
|`elseScript`|Script to be run if `$args` doesn't contain `$v` Optional, default `""`.|


### <a name='Description'></a>Description

```tcl
proc foo args {
   kissb.args.contains -test {
       puts "-test passed"
   }
   kissb.args.contains -test {
       puts "-test passed"
   } else {
       puts "-test not passed"
   }
   if {[kissb.args.contains -test]} {
       puts "-test passed"
   } else {
       puts "-test not passed"
   }
}
foo -test
foo
```

### <a name='Return_value'></a>Return value

Returns true or false so that this method can be used without script

## <a name='::kissb.args.containsNot'></a>kissb\.args\.containsNot

Tests if `$args` doesn't contains a specific argument, runs script if so, or elseScript if provided
See [::kissb.args.contains](#kissbargscontains) for usage


> `kissb.args.containsNot` *`v ?script? ?else? ?elseScript?`*<br>

### <a name='Parameters'></a>Parameters

|||
|----|----|
|`v`|Not documented.|
|`script`|Not documented. Optional, default `""`.|
|`else`|Not documented. Optional, default `""`.|
|`elseScript`|Not documented. Optional, default `""`.|


### <a name='Return_value'></a>Return value

Returns true or false

## <a name='::kissb.args.get'></a>kissb\.args\.get

Returns the value of `$v` switch in `$args`, or a default value
if to and `$varname` are provided, the variable represented by varname will be set to the value
Returns the value of `$v` in `$args` or `$default`


> `kissb.args.get` *`v default ?to? ?varname?`*<br>

### <a name='Parameters'></a>Parameters

|||
|----|----|
|`v`|switch to test in `$args`|
|`default`|Default value if `$v` is not in `$args`|
|`to`|Dummy word, set to "to" or "->" for example Optional, default `""`.|
|`varname`|pass the name of a variable to set to the `$v` value or `$default` Optional, default `""`.|


### <a name='Return_value'></a>Return value

Returns the value of `$v` switch in `$args`, or a default value
if to and `$varname` are provided, the variable represented by varname will be set to the value
Returns the value of `$v` in `$args` or `$default`

## <a name='::kissb.args.getFirstNotSwitch'></a>kissb\.args\.getFirstNotSwitch


> `kissb.args.getFirstNotSwitch` *`default ?->? ?varname?`*<br>

### <a name='Parameters'></a>Parameters

|||
|----|----|
|`default`|Not documented.|
|`->`|Not documented. Optional, default `""`.|
|`varname`|Not documented. Optional, default `""`.|


### <a name='Description'></a>Description

## <a name='::kissb.args.popAfter'></a>kissb\.args\.popAfter


> `kissb.args.popAfter` *`v default ?to? ?varname?`*<br>

### <a name='Parameters'></a>Parameters

|||
|----|----|
|`v`|Not documented.|
|`default`|Not documented.|
|`to`|Not documented. Optional, default `""`.|
|`varname`|Not documented. Optional, default `""`.|


### <a name='Description'></a>Description

## <a name='::kissb.args.withValue'></a>kissb\.args\.withValue

Runs provided script with the `$args` value for `$v` passed as `$varname`


> `kissb.args.withValue` *`v varname script`*<br>

### <a name='Parameters'></a>Parameters

|||
|----|----|
|`v`|switch to test in `$args`|
|`varname`|the name of the variable to set the value of the `$v` argument to|
|`script`|the script to run if `$v` is present in `$args`|


