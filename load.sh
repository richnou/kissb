export KISSB_HOME="$(dirname "$(readlink -f ${BASH_SOURCE[0]})")"
export PATH=${KISSB_HOME}/kb-tcl/bin:$PATH
export TCLLIBPATH=${KISSB_HOME}/kb-tcl

if [[ -e ${KISSB_HOME}/vendor/tcl9 ]]
then
    export PATH=${KISSB_HOME}/vendor/tcl9/bin:$PATH
    #alias tclsh=tclsh9.0
fi
