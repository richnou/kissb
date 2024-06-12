package jsonrpc

import kotlinx.serialization.Serializable
import kotlinx.serialization.SerializationStrategy
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.Json.Default.serializersModule
import kotlinx.serialization.json.JsonArray
import kotlinx.serialization.json.JsonElement
import kotlinx.serialization.serializer
import java.io.File
import java.net.URI
import kotlin.io.path.toPath


interface CommonLSPType
/*
fun <T : CommonLSPType> T.toJsonElement(): JsonElement {
    return Json.encodeToJsonElement(serializersModule.serializer(),this)
}*/

@Serializable
data class Message(val jsonrpc : String )

@Serializable
data class JRPCRequest(val jsonrpc : String,val id: Int? = null, val method:String, val params: JsonElement? = null)

@Serializable
data class JRPCResponse(val jsonrpc : String,val id: Int? = null , val result:JsonElement? = null, val error: ResponseError? = null)

@Serializable
data class ResponseError(val code: Int, val message:String,val data:JsonElement? = null)


// Client Caps
//----------------

@Serializable
data class MsgInitialiseParams(
    
    val clientInfo: MsgInitialiseParamsClientInfo?,
    val locale : String ,
    val trace : JsonElement? = null,
    val workspaceFolders: Array<MsgInitialiseParamsWorkspaceFolder>? = null
)
@Serializable
data class MsgInitialiseParamsClientInfo(
    val name:String,
    val version: String? = null
)

@Serializable
data class MsgInitialiseParamsWorkspaceFolder(
    val uri : String ,
    val name: String
) {
    fun toFile(): File {
        return URI.create(uri).toPath().toFile()
    }
}
