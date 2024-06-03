
pluginManagement {
  
    plugins {
        kotlin("jvm") version "2.0.0"
        kotlin("plugin.allopen") version "2.0.0"
        id("org.gradle.toolchains.foojay-resolver-convention") version("0.7.0")
    }
    repositories {
        mavenLocal()
        gradlePluginPortal()
        google()
        maven("https://maven.pkg.jetbrains.space/public/p/compose/dev")
        maven {
            name = "Compose Dev"
            url = uri("https://maven.pkg.jetbrains.space/public/p/compose/dev")
        }
        mavenCentral()
        maven {
            name = "ODFI Releases"
            url = uri("https://repo.opendesignflow.org/maven/repository/internal/")
        }
        maven {
            name = "ODFI Snapshots"
            url = uri("https://repo.opendesignflow.org/maven/repository/snapshots/")
        }
        maven {
            name = "Jitpack"
            url = uri("https://jitpack.io")
        }
    }
}


dependencyResolutionManagement {
    repositories {
        mavenLocal()
        mavenCentral()
        google()
        maven("https://maven.pkg.jetbrains.space/public/p/compose/dev")
        maven {
            name = "Jitpack"
            url = uri("https://jitpack.io")
        }
        maven {
            name = "Sonatype Nexus Snapshots"
            url = uri("https://oss.sonatype.org/content/repositories/snapshots/")
        }
        maven {
            name = "ODFI Releases"
            url = uri("https://repo.opendesignflow.org/maven/repository/internal/")
        }
        maven {
            name = "ODFI Snapshots"
            url = uri("https://repo.opendesignflow.org/maven/repository/snapshots/")
        }
        maven {
            url = uri("https://repo.triplequote.com/libs-release/")
        }


    }
}