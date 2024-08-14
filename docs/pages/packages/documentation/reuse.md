# REUSE (Licensing)

!!! note "Useful Links"
    - Homepage: https://reuse.software/
    - Tutorial: https://reuse.software/tutorial/
    - Tool Documentation: https://reuse.readthedocs.io/

To use this module, we recommend reading the official documentation of REUSE and integrate the needed commands in your build file

## Installation 

The REUSE package will install a python Virtual environment: 

~~~~tcl
package require kissb.reuse 

# Setup a build target for licensing 
@ license {
    

    # Load REUSE
    reuse.init
}

~~~~

## Download a License

Once you have defined which license you need, you can download it. KISSB will download the license using REUSE if needed: 

~~~~tcl
package require kissb.reuse 

# Setup a build target for licensing 
@ license {
    
    reuse.init

    reuse.download GPL-3.0-or-later
}

~~~~

## Files Annotation

The module offers a convenient method to annotate files using a set of Glob patterns. 
The arguments passed to the annotation build command should be taken from REUSE documentation: 

[https://reuse.readthedocs.io/en/stable/man/reuse-annotate.html](https://reuse.readthedocs.io/en/stable/man/reuse-annotate.html){target=_blank}

For example, to annotate all the C files in the src folder: 

~~~~tcl
package require kissb.reuse 

# Setup a build target for licensing 
@ license {
    
    reuse.init

    reuse.download GPL-3.0-or-later

    reuse.annotate.globs src/*.c -c "COPYRIGHT" --merge-copyrights -l GPL-3.0-or-later

}

~~~~

