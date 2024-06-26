set ::kissDir $dir
package ifneeded kissb                    1.0 [list foreach f [concat [lsort [glob $dir/kiss/kiss.plugin*.kb]] [list $dir/info.tcl]] {source $f}]

package ifneeded kissb.kotlin             1.0 [list source $dir/kotlin/kotlin.plugin.kb]
package ifneeded kissb.kotlin.maven       1.0 [list source $dir/kotlin/kotlin.maven.plugin.kb]
package ifneeded kissb.kotlin.mp          1.0 [list source $dir/kotlin/kotlin.mp.plugin.kb]
package ifneeded kissb.kotlin.mp.compose  1.0 [list source $dir/kotlin/kotlin.mp.compose.plugin.kb]

package ifneeded kissb.scala              1.0 [list source $dir/scala/scala.plugin.kb]

package ifneeded kissb.quarkus            1.0 [list source $dir/quarkus/quarkus.plugin.kb]
package ifneeded kissb.liquibase          1.0 [list source $dir/liquibase/liquibase.plugin.kb]

package ifneeded kissb.ivy                1.0 [list source $dir/java-ivy/ivy.plugin.kb]
package ifneeded kissb.coursier           1.0 [list source $dir/coursier/coursier.plugin.kb]
package ifneeded kissb.gradle             1.0 [list source $dir/gradle/gradle.plugin.kb]
package ifneeded kissb.maven              1.0 [list source $dir/maven/maven.plugin.kb]


package ifneeded kissb.python3            1.0 [list source $dir/python3/python3.plugin.kb]
package ifneeded kissb.mkdocs             1.0 [list source $dir/mkdocs/mkdocs.plugin.kb]
package ifneeded kissb.netlify            1.0 [list source $dir/netlify/netlify.plugin.kb]

package ifneeded kissb.nodejs             1.0 [list source $dir/nodejs/nodejs.plugin.kb]

package ifneeded kissb.builder.podman     1.0 [list source $dir/builder/builder.podman.plugin.kb]
package ifneeded kissb.builder.rclone     1.0 [list source $dir/builder/builder.rclone.plugin.kb]
package ifneeded kissb.docker              1.0 [list source $dir/docker/docker.plugin.kb]