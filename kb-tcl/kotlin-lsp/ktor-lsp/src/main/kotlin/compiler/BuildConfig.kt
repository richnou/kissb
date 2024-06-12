package compiler

import kotlinx.serialization.Serializable
import kotlinx.serialization.json.JsonElement
import kotlinx.serialization.json.JsonObject


@Serializable
data class BuildConfig(
    val toolchain : String,
    val platform : String,
    val module : String,
    val env: JsonObject,
    val buildDirectory : String,
    val args: Array<JsonElement>,
    val sources: Array<String>,
    val classpath: Array<String>
)
