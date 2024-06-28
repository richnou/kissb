# Python 3

Package loading: 

    package require kissb.python3

## Virtual Environment installation

To use a virtual environment, you can request the creation and pass some requirements for packages: 

~~~tcl
# Create a venv
python3.venv.init

# Create a venv and require some packages 
python3.venv.init {
    python3.venv.require pip-package ...
}
~~~

## Virtual Environment script run 

To run a script through the virtual environment: 

~~~tcl

...

# After the venv has been initialised 
python3.venv.run script.py

..
~~~