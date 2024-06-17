puts "In Index"
set ::kissDir $dir
package ifneeded kiss               1.0 [list foreach f [glob $dir/kiss/kiss.plugin*.kb] { source $f}]

package ifneeded kotlin             1.0 [list source $dir/kotlin/kotlin.plugin.kb]
package ifneeded kotlin.mp          1.0 [list source $dir/kotlin/kotlin.mp.plugin.kb]
package ifneeded kotlin.mp.compose  1.0 [list source $dir/kotlin/kotlin.mp.compose.plugin.kb]

package ifneeded liquibase             1.0 [list source $dir/liquibase/liquibase.plugin.kb]

package ifneeded ivy                1.0 [list source $dir/java-ivy/ivy.plugin.kb]
package ifneeded coursier           1.0 [list source $dir/coursier/coursier.plugin.kb]
package ifneeded gradle             1.0 [list source $dir/gradle/gradle.plugin.kb]

package ifneeded python3            1.0 [list source $dir/python3/python3.plugin.kb]
package ifneeded mkdocs             1.0 [list source $dir/mkdocs/mkdocs.plugin.kb]
package ifneeded netlify            1.0 [list source $dir/netlify/netlify.plugin.kb]

package ifneeded nodejs             1.0 [list source $dir/nodejs/nodejs.plugin.kb]

package ifneeded builder.podman     1.0 [list source $dir/builder/builder.podman.plugin.kb]
package ifneeded builder.rclone     1.0 [list source $dir/builder/builder.rclone.plugin.kb]

## Flows
##############
proc kissb_search {name version} {
    log.info "Searching for Package $name"
    if {[string match flow::* $name]} {
        
        set flowFile $::kissDir/flows/[string map {flow:: "" + _} $name].flow.tcl
        log.info "Searching for Flow in $flowFile"
        if {[file exists $flowFile]} {
            log.success "Found, providing"
            package provide $name $version
            source $flowFile
        }
    }
}
package unknown kissb_search