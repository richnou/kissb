package jsonrpc.language

import jsonrpc.common.TextDocumentIdentifier
import jsonrpc.common.TextDocumentPosition
import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
data class TextDocumentCompletionParams(

    val textDocument: TextDocumentIdentifier,
    val position : TextDocumentPosition,
    val context: TextDocumentCompletionParamsContext
)

@Serializable
data class TextDocumentCompletionParamsContext(
    val triggerKind : CompletionTriggerKind
)

enum class CompletionTriggerKind(val k : Int) {
    @SerialName("1")
    INVOKED(1),
    @SerialName("2")
    CHARACHTER(2),
    @SerialName("3")
    INCOMPLETE(3)
}