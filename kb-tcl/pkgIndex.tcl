puts "In Index"
package ifneeded kiss       1.0 [list foreach f [glob $dir/kiss/kiss.plugin*.kb] { source $f}]

package ifneeded kotlin             1.0 [list source $dir/kotlin/kotlin.plugin.kb]
package ifneeded kotlin.mp          1.0 [list source $dir/kotlin/kotlin.mp.plugin.kb]
package ifneeded kotlin.mp.compose  1.0 [list source $dir/kotlin/kotlin.mp.compose.plugin.kb]

package ifneeded ivy        1.0 [list source $dir/java-ivy/ivy.plugin.kb]
package ifneeded coursier   1.0 [list source $dir/coursier/coursier.plugin.kb]
package ifneeded gradle     1.0 [list source $dir/gradle/gradle.plugin.kb]