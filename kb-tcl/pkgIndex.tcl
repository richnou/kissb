#puts "In Index"
package ifneeded kiss 1.0 [foreach f [glob $dir/kiss/kiss.plugin*.kb] { source $f}]
package ifneeded kotlin 1.0 [source $dir/kotlin/kotlin.plugin.kb]
package ifneeded ivy 1.0 [source $dir/java-ivy/ivy.plugin.kb]
package ifneeded coursier 1.0 [source $dir/coursier/coursier.plugin.kb]
package ifneeded gradle 1.0 [source $dir/gradle/gradle.plugin.kb]