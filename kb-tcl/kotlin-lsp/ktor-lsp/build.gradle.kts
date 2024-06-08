plugins {
    kotlin("jvm")
    id("io.ktor.plugin") version "2.3.11"
    id("application")
    kotlin("plugin.serialization") version "2.0.0"
}

java {
    sourceCompatibility = JavaVersion.VERSION_21
    targetCompatibility = JavaVersion.VERSION_21
}

application {
    mainClass = "Kotlin2LSPKt"
    //mainClass = "compiler.TryCompileKt" 
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
    
    implementation("org.jetbrains.kotlinx:kotlinx-serialization-json:1.6.3")

    implementation("ch.qos.logback:logback-classic:1.5.6")

    // KotlinC
    implementation("org.jetbrains.kotlin:kotlin-compiler:2.0.0")
    implementation("org.jetbrains.kotlin:kotlin-compiler-runner:2.0.0")
    //implementation("org.jetbrains.kotlin:kotlin-compiler-embeddable:2.0.0")

    // Index DB
    implementation("org.duckdb:duckdb_jdbc:1.0.0")
}