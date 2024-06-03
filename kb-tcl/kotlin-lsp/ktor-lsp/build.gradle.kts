plugins {
    kotlin("jvm")
    id("io.ktor.plugin") version "2.3.11"
    id("application")
}

java {
    sourceCompatibility = JavaVersion.VERSION_21
    targetCompatibility = JavaVersion.VERSION_21
}

application {
    mainClass = "Kotlin2LSPKt" 
}
kotlin {
    compilerOptions {
       // jvmTarget.set(JvmTarget.JVM_21)
    }
}

dependencies {
    val ktor_version = "2.3.11"
    implementation("io.ktor:ktor-server-core")
    implementation("io.ktor:ktor-server-netty")
    implementation("io.ktor:ktor-network")
    
    implementation("ch.qos.logback:logback-classic:1.5.6")
}