package provide flow.helidon.scala.applib 1.0
package require flow.helidon.generic 
package require flow.scala.applib



proc flow.helidon.enableMPForBuild name {

    flow.addDependencies $name [flow.helidon.getMPDependencies]

    flow.build.properties $name {
        java {
            mainClass ${::flow.helidon.java.main}
        }
    }
}