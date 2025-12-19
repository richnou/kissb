# Verible

!!! note "Useful Links"
    - Homepage: <https://chipsalliance.github.io/verible/>
    - Github: <https://github.com/chipsalliance/verible>
    - Current default version: {{ verible.version }}




## Verible Package Variables

Before or after Loading the flow, you can set configuration variables:

~~~tcl
package require kissb.eda.verible

vars.set CONFIGURATION VALUE
~~~

{%
    include-markdown "./_verible.vars.inc.md"
%}


## Verible Commands Reference

{%
    include-markdown "./verible.methods.md"
    dedent=true
    heading-offset=1
%}
