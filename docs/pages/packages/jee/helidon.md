# Helidon

Using Helidon with KISSB can be done without using maven as integration build configuration. 

There is not Helidon kissb package, but rather some predefined flow scripts that configure the project and create a standard set of 
targets.

## Setup: Microprofile With Scala 

The Scala+Microprofile flow configures scala with the Standard Folder Convention (C1), and add the basic Microprofile dependencies.

For example: 

~~~~
# Load Helidon Flow
flow.load helidon/microprofile_scala_c1
~~~~

Then run Kissb to view the created targets:

    $ kissb 

## Running Helidon 

The Helidon Flows all create the same set of standard targets like "build" to compile. 

To run Helidon: 

    $ kissb run