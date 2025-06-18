# Build Targets


In KISSB, build targets are defined using a concise Tcl-based syntax that emphasizes clarity and modularity. This system allows developers to create semantic, reusable workflows for tasks like compiling, packaging, or releasing software by defining targets with dependencies, documentation, and argument handling. Below is an example of how to define build targets, illustrated through the provided code snippet:

---

## Defining a Basic Target
A simple target is declared using the `@` command followed by the target name and its execution commands. For instance:
```tcl
@ foo {
    log.info "In Foo"
}
```
This declares a target named `foo` that logs a message when executed.

---

## Adding Dependencies and Documentation
Targets can depend on other targets, ensuring they run in the correct order. The `bar` target, for example, depends on `foo` and includes documentation:
```tcl
@ {bar "An example target"} : foo {
    log.info "In Bar"
}
```
Here, `bar` is declared with a documentation string (`"An example target"`) and explicitly depends on the `foo` target. This ensures `foo` runs before `bar`.

---

## Passing Command-Line Arguments to Targets
KISSB supports passing command-line arguments to targets using `$args`, which can be accessed within the target’s TCL script. This allows targets to dynamically respond to user input or environment-specific configurations. For example:

```tcl
@ test {
    # Log passed arguments (e.g., ./kissbw test -arg1 -arg2)
    log.info "In test with arguments: $args"

    # Call bar target
    > bar

    # Pass arguments to foo target
    >> foo
}
```

- **Argument Capture**: When you run `./kissbw test -arg1 -arg2`, the arguments `-arg1` and `-arg2` are stored in `$args`.
- **Passing Arguments Down**: The `>>` syntax allows targets to pass these arguments to dependent tasks. For instance, `>> foo` ensures that `foo` receives the same arguments as the current target (`test`).
- **Dynamic Behavior**: This feature enables targets to adapt their logic based on inputs, such as compiling with different flags or environment variables.

---

## Key Features for Build Workflows
1. **Modular Task Chains**: Targets can depend on others (e.g., `bar` depends on `foo`) to enforce execution order.
2. **Argument Handling**: `$args` captures command-line parameters, allowing dynamic behavior in targets.
3. **Documentation**: Targets can include descriptive text for clarity, such as the `"An example target"` string in the `bar` example.
4. **Flexibility**: The syntax supports both simple tasks and complex workflows, making it ideal for customizing build processes.

---

## Full Example


```tcl
@ foo {
    log.info "In Foo"
}

# The bar target will run after the foo target, the script in the first list is used as documentation for the bar target
@ {bar "An example target"} : foo {
    log.info "In Bar"
}

@ test  {

    # Call the bar target
    > bar

    # $args contain sthe arguments passed like: ./kissbw test -arg1 -arg2
    log.info "In test with arguments: $args"

    # Call foo target passing arguments down
    >> foo

}
```
