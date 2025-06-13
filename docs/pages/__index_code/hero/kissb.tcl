package require kissb.python3

log.info "Welcome to this project build script"


# Load a python venv (python should be installed)
python3.venv.init {
    log.info "Installing Requirements"
    python3.venv.require PySide6
}

# Run
python3.venv.run.script main.py
