


vars.define ktor.version 2.3.12
vars.define ktor.engine netty
vars.define ktor.platform jvm

flow.load kotlin/simple_kotlin


kotlin.dependencies.add main org.slf4j:slf4j-api:2.0.9
kotlin.dependencies.add main ch.qos.logback:logback-classic:1.5.8

kotlin.dependencies.add main io.ktor:ktor-server-core-[vars.get ktor.platform]:[vars.get ktor.version]
kotlin.dependencies.add main io.ktor:ktor-server-[vars.get ktor.engine]-[vars.get ktor.platform]:[vars.get ktor.version]
kotlin.dependencies.add main io.ktor:ktor-server-websockets-[vars.get ktor.platform]:[vars.get ktor.version]

kotlin.dependencies.add main org.jetbrains.kotlinx:kotlinx-coroutines-core:1.9.0
kotlin.dependencies.add main org.jetbrains.kotlinx:kotlinx-coroutines-core-jvm:1.9.0




