set ::kissDir $dir

## Kissb Core
proc _load_kissb_conf dir {

    foreach f [concat [lsort [glob $dir/kiss/kiss.plugin.*]] [list $dir/globals.tcl] [list $dir/info.tcl] ] { source $f }
    foreach c [lsort [glob -nocomplain $dir/*.conf.tcl]] {
        try {
            uplevel [list source $c]

        } on error {msg stack} {
            log.error "Could not load conf file $c: $msg"
        }
    }
}
#package ifneeded kissb                      1.0 [list foreach f [concat [lsort [glob $dir/kiss/kiss.plugin.*]] [list $dir/globals.tcl] [list $dir/info.tcl] ] { source $f } ]
package ifneeded kissb                      1.0 [list _load_kissb_conf $dir ]


package ifneeded kissb.internal.update      1.0 [list source $dir/kiss/kiss.update.tcl]
package ifneeded kissb.internal.tls         1.0  [list source $dir/kiss/kiss.tls.tcl]

## Standard Plugins
package ifneeded kissb.i18n                 1.0  [list source $dir/i18n/i18n.plugin.kb]
package ifneeded kissb.git                  1.0  [list source $dir/git/git.plugin.kb]
package ifneeded kissb.liquibase            1.0  [list source $dir/liquibase/liquibase.plugin.kb]


package ifneeded kissb.python3              1.0  [list source $dir/python3/python3.plugin.tcl]
package ifneeded kissb.mkdocs               1.0  [list source $dir/mkdocs/mkdocs.plugin.tcl]
package ifneeded kissb.netlify              1.0  [list source $dir/netlify/netlify.plugin.tcl]

package ifneeded kissb.nodejs               1.0  [list source $dir/nodejs/nodejs.plugin.kb]

package ifneeded kissb.builder.container    1.0  [list source $dir/builder/builder.container.plugin.tcl]
package ifneeded kissb.builder.rclone       1.0  [list source $dir/builder/builder.rclone.plugin.tcl]
package ifneeded kissb.docker               1.0  [list source $dir/containers/docker.plugin.tcl]
package ifneeded kissb.podman               1.0  [list source $dir/containers/podman.plugin.tcl]
package ifneeded kissb.box                  1.0  [list source $dir/containers/box.plugin.tcl]

## TCL
#########
package ifneeded kissb.tclkit               1.0  [list source $dir/tclkit/tclkit.plugin.tcl]
package ifneeded kissb.tcl9.kit             1.0  [list source $dir/tclkit/tclkit9.plugin.tcl]
package ifneeded kissb.runtime              1.0  [list source $dir/tclkit/runtime.plugin.tcl]
package ifneeded kissb.critcl               1.0  [list source $dir/critcl/critcl.plugin.tcl]

## Licensing
#######
package ifneeded kissb.reuse                1.0  [list source $dir/licensing/reuse.plugin.tcl]


## EDA Packages
####################
package ifneeded kissb.eda.f                1.0  [list source $dir/eda/eda.f.plugin.tcl]
package ifneeded kissb.eda.cocotb           1.0  [list source $dir/eda/cocotb/cocotb.plugin.tcl]
package ifneeded kissb.eda.verilator        1.0  [list source $dir/eda/verilator/verilator.plugin.tcl]

## Java and JEE Packages
#####################
package ifneeded kissb.java                 1.0  [list source $dir/java/java.plugin.tcl]
package ifneeded kissb.coursier             1.0  [list source $dir/java/coursier/coursier.plugin.tcl]
package ifneeded kissb.gradle               1.0  [list source $dir/java/gradle/gradle.plugin.kb]
package ifneeded kissb.maven                1.0  [list source $dir/java/maven/maven.plugin.kb]
package ifneeded kissb.ivy                  1.0  [list source $dir/java/ivy/ivy.plugin.kb]


package ifneeded kissb.kotlin               1.0 [list source $dir/java/kotlin/kotlin.plugin.kb]
package ifneeded kissb.kotlin.maven         1.0 [list source $dir/java/kotlin/kotlin.maven.plugin.kb]
package ifneeded kissb.kotlin.mp            1.0 [list source $dir/java/kotlin/kotlin.mp.plugin.kb]
package ifneeded kissb.kotlin.mp.compose    1.0 [list source $dir/java/kotlin/kotlin.mp.compose.plugin.kb]

package ifneeded kissb.scala                1.0 [list source $dir/java/scala/scala.plugin.tcl]

package ifneeded kissb.proguard             1.0 [list source $dir/java/proguard/proguard.plugin.tcl]

package ifneeded kissb.quarkus              1.0 [list source $dir/java/quarkus/quarkus.plugin.kb]

## Native
###############
package ifneeded kissb.rust 1.0 [list source $dir/native/rust/rust.plugin.tcl ]

## UI Frameworks
#############
package ifneeded kissb.tauri 1.0 [list source $dir/tauri/tauri.plugin.tcl]


## Flows
############
package ifneeded flow.helidon.generic        1.0 [list source $dir/flows/helidon/helidon_generic.1_0.tcl]
package ifneeded flow.helidon.scala.applib   1.0 [list source $dir/flows/helidon/helidon_scala_applib.1_0.tcl]

package ifneeded flow.mkdocs                 1.0 [list source $dir/flows/mkdocs/mkdocs.1_0.tcl]
package ifneeded flow.scala.applib           1.0 [list source $dir/flows/scala/applib.1_0.tcl]
