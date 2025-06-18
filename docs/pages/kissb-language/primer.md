# Language Introduction

KISSB is a powerful collection of packages built upon the [**TCL Language**](https://tcl-lang.org).
It's designed to offer a user-friendly **API**, simplifying the process of writing flexible and robust build scripts for any project.

Tcl's adoption as a command language is widespread,
particularly within the **Electronic Design Automation (EDA)** industry.
Its inherent flexibility is a key advantage, allowing developers to craft highly customized APIs that perfectly fit diverse use cases, making it an ideal foundation for KISSB.

To help you get started, this documentation offers a flexible learning path.
We will begin by introducing you to the core KISSB API through actual KISSB script examples.
These examples are written in Tcl, and for your convenience,
a comprehensive Tcl language tutorial is included directly within this document.

* **If you are new to Tcl**, we recommend you review the fundamental syntax of the Tcl language section before diving deep into the KISSB API examples.
* **For Tcl-savvy users**, you can proceed directly to the KISSB examples and the overview of the core KISSB package API to understand how to leverage its capabilities immediately.

Following these introductory sections, you'll find more advanced topics, such as creating your own packages or integrating custom toolchains, in the other dedicated sections of this documentation.


{%
    include-markdown "./primer.kissb.md"
%}



## TCL Introduction


**Tcl (Tool Command Language)** is a powerful scripting language often used for automating tasks –
particularly in areas like Electronic Design Automation (EDA). I
ts flexibility makes it ideal for building custom tools.

This introduction to Tcl will cover:

* The fundamental syntax and structure of Tcl commands.
* How to define, set, and retrieve variables.
* Working with Tcl's versatile list data structure, including creation and modification.
* Defining reusable procedures (functions).
* Essential control flow constructs for decision-making and looping.
* An overview of Tcl's namespace and package system.




### Tcl Basics - Quick Overview

A core tenet of Tcl is that everything is a command.
Unlike many other languages where keywords like if or for have special grammatical status, in Tcl,
these are simply commands that accept arguments (which can include code blocks).
This philosophy provides Tcl with immense flexibility, which KISSB tries to leverage at best.

Tcl's fundamental data structure is the **list**, and its syntax is heavily whitespace-sensitive.
Spaces are absolutely *critical* for separating commands, their arguments, and elements within lists.
This "command-oriented" nature also means that multi-word constructs like "else if" are not valid; instead, they are single commands such as elseif.

**Examples:**

* **List Definition:** Tcl treats everything as a string, but it has robust mechanisms for working with lists of strings.

    ```tcl
    # Using 'list' command: Best for constructing lists dynamically,
    # or when elements might contain spaces themselves.
    set my_list [list item1 "item 2 with space" item3]
    puts "my_list: $my_list" ;# Output: my_list: item1 {item 2 with space} item3

    # Using curly braces '{}': Convenient for literal lists, especially
    # when you don't need variable substitution or command evaluation inside.
    # Elements are simply separated by spaces.
    set another_list {a b c d}
    puts "another_list: $another_list" ;# Output: another_list: a b c d

    # Critical Distinction: Variable substitution DOES NOT happen inside curly braces {}.
    set var_name "Bob"
    set literal_list {Hello, $var_name!} ;# '$var_name' is treated as a literal string.
    puts "literal_list: $literal_list" ;# Output: literal_list: Hello, $var_name!

    # Compare with double quotes, where substitution DOES happen:
    set substituted_string "Hello, $var_name!"
    puts "substituted_string: $substituted_string" ;# Output: substituted_string: Hello, Bob!
    ```

* **Setting and Changing Variables:** The `set` command assigns a value to a variable or updates its existing value. **Crucially, when you are setting or changing the value of a variable, you refer to it by its name *without* the leading dollar sign (`$`).** The dollar sign is used *only* when you want to retrieve its content.

    ```tcl
    # Setting a new variable: Use the variable name directly.
    set user_name "Alice"
    puts "Current user: $user_name" ;# Output: Current user: Alice

    # Changing an existing variable: Again, use the variable name directly.
    set user_name "Charlie"
    puts "New user: $user_name" ;# Output: New user: Charlie

    # When the value contains spaces or special characters,
    # enclose it in double quotes (") or curly braces ({}).
    set greeting_message "Welcome to Tcl!"
    puts "$greeting_message" ;# Output: Welcome to Tcl!
    ```

* **Retrieving Variable Content (Substitution):** The dollar sign (`$`) is used for variable substitution. When Tcl encounters `$` followed by a variable name, it replaces it with the variable's value *before* executing the command.

    ```tcl
    set city "Paris"
    puts "I live in $city." ;# Output: I live in Paris. (Here, $city is replaced by "Paris")

    # Accessing elements of a list stored in a variable
    set my_fruit_list {apple banana orange}
    puts "First fruit: [lindex $my_fruit_list 0]" ;# Output: First fruit: apple
    puts "Second fruit: [lindex $my_fruit_list 1]" ;# Output: Second fruit: banana
    # The 'lindex' command is used to retrieve elements from a Tcl list.
    ```

* **Command Substitution (`[]`):** Square brackets in Tcl trigger **command substitution**.
When Tcl encounters a block of code enclosed in `[]`, it first executes that code as a command, and then replaces the entire `[...]` block with the *result* of that command.
This allows you to nest commands and use the output of one command as an argument to another.

    ```tcl
    # Using a command's result directly as an argument
    puts "The length of 'hello' is: [string length "hello"]"; # Output: The length of 'hello' is: 5

    # Nesting command substitutions
    set radius 5
    set area [expr {3.14159 * ($radius * $radius)}] ;# 'expr' evaluates a mathematical expression
    puts "Area of circle: $area" ;# Output: Area of circle: 78.53975

    # Combining with variable substitution
    set my_fruit_list {apple banana orange}
    puts "First fruit: [lindex $my_fruit_list 0]" ;# Output: First fruit: apple
    # Here, '$my_fruit_list' is substituted first, then 'lindex' command is executed.
    ```

* **Procedures (Functions):** Procedures are defined using the `proc` command. They are Tcl's way of creating reusable blocks of code (functions).

    ```tcl
    # Define a procedure named 'greet_user' that takes one argument.
    proc greet_user {name} {
        puts "Hello, $name!"
    }

    # Call the procedure with an argument.
    greet_user "Alice" ;# Output: Hello, Alice!

    # Define a procedure with multiple arguments and a return value.
    proc add_numbers {a b} {
        set sum [expr {$a + $b}]
        return $sum
    }

    set result [add_numbers 10 25]
    puts "The sum is: $result" ;# Output: The sum is: 35
    ```

* **Variable Scope and Global Access:** Variables in Tcl are typically associated with the current scope (e.g., a procedure where they are defined). To explicitly access or define variables in the **global (top-level)** namespace from anywhere in your script (including inside procedures), you prefix their name with `::`.

    ```tcl
    set global_var "I am global"

    proc print_global {} {
        # Accessing the global variable
        puts "Inside proc: $::global_var"
    }

    print_global ;# Output: Inside proc: I am global

    # Even if a local variable has the same name, :: ensures global access
    proc modify_global {} {
        set global_var "I am local" ;# This creates a NEW local variable
        puts "Inside proc (local): $global_var"
        set ::global_var "I am modified globally" ;# This modifies the GLOBAL variable
    }

    modify_global ;# Output: Inside proc (local): I am local
    puts "Outside proc (global): $global_var" ;# Output: Outside proc (global): I am modified globally
    ```



### Modifying Lists and Variables

In Tcl, while you use `$` to **retrieve** the *value* of a variable, when you are **modifying** the variable itself (like adding elements to a list, or changing its content), you refer to it directly by its name, *without* the `$` prefix. This distinction is crucial for understanding Tcl's variable handling.

* **Appending to a List (`lappend`):** The `lappend` command is used to add one or more elements to the end of a list variable. It directly modifies the variable in place.

    ```tcl
    set my_shopping_list {milk bread}
    puts "Initial list: $my_shopping_list" ;# Output: Initial list: milk bread

    # Appending a single item: Notice 'my_shopping_list' without '$'
    lappend my_shopping_list "eggs"
    puts "After appending 'eggs': $my_shopping_list" ;# Output: After appending 'eggs': milk bread eggs

    # Appending multiple items:
    lappend my_shopping_list cheese "fruit juice"
    puts "After appending more: $my_shopping_list" ;# Output: After appending more: milk bread eggs cheese {fruit juice}
    ```

* **Retrieving Multiple Elements (`lrange`):** While `lindex` retrieves a *single* element by its index, the `lrange` command is used to extract a sub-list (a range of elements) from an existing list.

    ```tcl
    set colors {red green blue yellow purple orange}
    puts "Full list: $colors"

    # Retrieve elements from index 1 to 3 (inclusive)
    set selected_colors [lrange $colors 1 3]
    puts "Selected colors (index 1 to 3): $selected_colors" ;# Output: Selected colors (index 1 to 3): green blue yellow

    # Retrieve all elements from a starting index to the end
    set remaining_colors [lrange $colors 4 end]
    puts "Remaining colors (from index 4 to end): $remaining_colors" ;# Output: Remaining colors (from index 4 to end): purple orange
    ```

* **Modifying a Specific List Element (`lset`):** The `lset` command allows you to change the value of a specific element within a list variable by its index. It directly modifies the list in place.

    ```tcl
    set task_status {pending in_progress completed}
    puts "Original status: $task_status" ;# Output: Original status: pending in_progress completed

    # Change the element at index 0
    lset task_status 0 "started"
    puts "Updated status: $task_status" ;# Output: Updated status: started in_progress completed

    # You can also use 'end' for the last element
    lset task_status end "finished"
    puts "Final status: $task_status" ;# Output: Final status: started in_progress finished
    ```


### Control Flow

Tcl provides a robust set of commands for directing the flow of script execution, allowing you to create dynamic and responsive programs. These control structures enable your scripts to make decisions, repeat actions, and handle different scenarios based on specific conditions.

* **Conditional Execution (`if`/`elseif`/`else`):**
    The `if` command is used to execute a block of code only if a specified condition evaluates to true. You can extend its functionality with `elseif` for additional conditions and `else` for a fallback block if none of the preceding conditions are met. The condition itself is typically a boolean expression, often implicitly evaluated using Tcl's `expr` capabilities. It's good practice to enclose the condition in curly braces `{}` to prevent premature substitution and improve performance.

    ```tcl
    set temperature 25

    if {$temperature > 30} {
        puts "It's a hot day!"
    } elseif {$temperature >= 20} {
        puts "The weather is pleasant."
    } else {
        puts "It's a bit chilly."
    }
    # Output for temperature = 25: The weather is pleasant.

    set is_sunny true
    set has_umbrella false

    if {$is_sunny && !$has_umbrella} {
        puts "Enjoy the sun!"
    } else {
        puts "Be prepared for rain, or enjoy the shade."
    }
    # Output: Enjoy the sun!
    ```

* **Multi-way Branching (`switch`):**
    The `switch` command provides a clean and efficient way to handle multiple possible conditions based on the value of a single expression. It evaluates an expression and compares its result against a series of patterns, executing the code block associated with the first matching pattern. A `default` case can be provided for situations where no other patterns match.

    ```tcl
    set command "status"

    switch $command {
        "start" {
            puts "Starting service..."
        }
        "stop" {
            puts "Stopping service..."
        }
        "status" {
            puts "Checking service status..."
        }
        default {
            puts "Unknown command: $command"
        }
    }
    # Output: Checking service status...

    # 'switch' can also use pattern matching options like -glob or -regexp
    set filename "report_v2.txt"
    switch -glob $filename {
        "*.log" { puts "It's a log file." }
        "*.txt" { puts "It's a text file." }
        default { puts "File type unknown." }
    }
    # Output: It's a text file.
    ```

* **Looping with `foreach`:**
    The `foreach` command is the most common way to iterate over elements in a list. It assigns each element, in turn, to one or more loop variables and then executes a script body for each element. This is highly versatile for processing collections of data.

    ```tcl
    set fruits {apple banana orange grape}

    foreach fruit $fruits {
        puts "I like $fruit."
    }
    # Output:
    # I like apple.
    # I like banana.
    # I like orange.
    # I like grape.

    # Iterating with multiple loop variables (e.g., key-value pairs)
    set person_data {name Alice age 30 city NewYork}
    foreach {key value} $person_data {
        puts "$key: $value"
    }
    # Output:
    # name: Alice
    # age: 30
    # city: NewYork
    ```

* **Iterating with `for`:**
    The `for` command provides a traditional C-style looping mechanism, ideal for iterating a specific number of times or when you need to manage an explicit counter. It takes an initialization script, a boolean condition, a step script, and the loop body.

    ```tcl
    for {set i 0} {$i < 5} {incr i} {
        puts "Count: $i"
    }
    # Output:
    # Count: 0
    # Count: 1
    # Count: 2
    # Count: 3
    # Count: 4
    ```

* **Conditional Looping with `while`:**
    The `while` command executes a block of code repeatedly as long as a specified condition remains true. This is useful when the number of iterations is not known beforehand, but depends on a dynamic condition.

    ```tcl
    set counter 3

    while {$counter > 0} {
        puts "$counter..."
        incr counter -1 ;# Decrement counter by 1
    }
    puts "Blast off!"
    # Output:
    # 3...
    # 2...
    # 1...
    # Blast off!
    ```

### Tcl Namespaces and  Packages

At its core, Tcl uses namespaces to provide logical containers for commands and variables,
ensuring a clean separation of concerns.
This fundamental feature is key to building modular applications, as it allows packages and libraries to operate in isolation,
free from the risk of global naming conflicts.

#### Defining a Namespace and Package Implementation

The core of defining a package's functionality in Tcl involves the `namespace eval` command. This command is fundamental for creating and populating namespaces, thereby isolating code pertinent to specific packages or functionalities. Consider the `mynamespace_pkg.tcl` file, which encapsulates the implementation details of a sample package:

```tcl
# mynamespace_pkg.tcl (Example package implementation file)

# Declare the package. While often placed at the end of the file,
# placing it here ensures immediate declaration upon sourcing.
package provide mynamespace_utils 1.0

# Define the 'mynamespace' namespace and its procedures.
namespace eval mynamespace {
    proc function_a { arg } {
        puts "Function A called with: $arg"
    }

    proc function_b { arg1 arg2 } {
        puts "Function B called with: $arg1, $arg2"
    }
}
```

In this example, we begin by declaring the `mynamespace_utils` package and its version (1.0) using `package provide`. This command informs Tcl that this specific package is now available. Immediately following this declaration, we define `mynamespace` using `namespace eval`. Within this namespace, two procedures, `function_a` and `function_b`, are established. The `namespace eval` command is responsible for creating this namespace and associating these defined procedures directly with it, ensuring they reside within this isolated context.

#### Package Definition and the `pkgIndex.tcl` File

The mechanism by which Tcl discovers and loads packages is primarily managed through the `pkgIndex.tcl` file. This vital file resides in a directory that Tcl is configured to search for packages and acts as an index, guiding Tcl on how to load a particular package when it is requested. A typical `pkgIndex.tcl` entry for our example package would look like this:

```tcl
# pkgIndex.tcl (Example)
# This command informs Tcl what script to execute if 'mynamespace_utils'
# (version 1.0 or a compatible later version) is requested.
package ifneeded mynamespace_utils 1.0 [list source [file join $dir mynamespace_pkg.tcl]]
```

Here, the `package ifneeded` command serves a critical role. It instructs Tcl that if a script calls `package require mynamespace_utils` for version 1.0 (or a later compatible version), it should execute the specified script: `source [file join $dir mynamespace_pkg.tcl]`. This script will dynamically load the `mynamespace_pkg.tcl` file. Upon sourcing this file, the `mynamespace` namespace and its associated procedures will be defined, and the `package provide` command within that file will confirm the package's availability. The `$dir` variable within `pkgIndex.tcl` is a special construct that conveniently points to the directory where the `pkgIndex.tcl` file itself is located, allowing for relative pathing to package implementation files.

#### Using the Package in a Tcl Script

To incorporate and utilize the functions provided by `mynamespace_utils` within your main Tcl script, a straightforward process is followed:

```tcl
# Your main script
package require mynamespace_utils

# Once the package is loaded, you can call its functions,
# qualifying them with their respective namespace.
mynamespace::function_a "Hello from the main script!"
mynamespace::function_b 100 200
```

By executing `package require mynamespace_utils`, your Tcl script signals its dependency on this package. Tcl then consults its package index (including `pkgIndex.tcl`) to locate and load the necessary files. Once the package is successfully loaded, the procedures defined within `mynamespace` become accessible. It is crucial to qualify these procedures with their namespace, for instance, `mynamespace::function_a`, to ensure they are executed within the isolated and correct context of the `mynamespace` namespace. This qualification prevents potential naming conflicts, especially if other loaded packages happen to define procedures with identical names in different namespaces.
