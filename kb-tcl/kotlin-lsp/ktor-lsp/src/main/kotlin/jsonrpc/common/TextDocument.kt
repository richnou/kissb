package jsonrpc.common

import kotlinx.serialization.Serializable
import java.io.File
import java.net.URI
import kotlin.io.path.toPath


@Serializable
data class TextDocumentIdentifier(
    val uri:String
) {
    fun toFile(): File {
        return URI.create(uri).toPath().toFile()
    }
}

@Serializable
data class TextDocumentPosition(
    val line:Int,
    val character: Int
) {
     
}

interface TextDocumentPositionParams {
     val textDocument:TextDocumentIdentifier
     val position : TextDocumentPosition
}
