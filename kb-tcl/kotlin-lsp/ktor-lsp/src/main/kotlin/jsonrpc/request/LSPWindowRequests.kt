package jsonrpc.request

import io.ktor.utils.io.*
import jsonrpc.JRPCRequest
import jsonrpc.sendJRPCMessage
import kotlinx.serialization.Serializable
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.encodeToJsonElement


@Serializable
data class ShowMessageParams(
    val type : MessageType,
    val message: String
)

enum class MessageType(val t : Int) {
    Error(1),
    Warning(2),
    Info(3),
    Log(4),
    Debug(5)
}


suspend fun ByteWriteChannel.lspSendWindowMessage(msg:String,t:MessageType) {
    val clientMsg = JRPCRequest(
        jsonrpc = "2.0",
        method = "window/showMessage",
        params = Json.encodeToJsonElement(
            ShowMessageParams(
                type = t,
                message = msg
            )
        )
    )
    this.sendJRPCMessage(Json.encodeToString(clientMsg))
}