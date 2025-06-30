
package require flow.helidon.scala.applib





flow.addBuilds .


#flow.helidon.loadBOM

flow.helidon.enableMPForBuild .


return

#vars.set java.main kissb.ServerMain

vars.set image.name example-app-helidon
vars.set image.tag  latest

# Load Helidon Flow
flow.load helidon/microprofile_scala_c1
