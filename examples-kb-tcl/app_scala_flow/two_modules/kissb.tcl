package require flow.scala.applib 1.0

set version 1.0.0-SNAPSHOT

#vars.set flow.scala.version 3.3.5

flow.addBuilds lib app




flow.addDependencies lib {
    "org.scala-lang::toolkit:0.7.0"


}

flow.addDependencies app {
    @lib/main
    "org.scalafx::scalafx:16.0.0-R24"
}

foreach fxModule {"base" "controls" "fxml" "graphics" "media" "swing" "web"} {
    flow.addDependencies app {
        "org.openjfx:javafx-$fxModule:16"
    }
}
#Seq("base", "controls", "fxml", "graphics", "media", "swing", "web")
#    .map(m => "org.openjfx" % s"javafx-$m" % "16" classifier osName)
