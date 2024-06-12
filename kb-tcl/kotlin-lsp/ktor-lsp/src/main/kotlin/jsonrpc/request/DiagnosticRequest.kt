package jsonrpc.request

import jsonrpc.common.TextDocumentIdentifier
import kotlinx.serialization.Serializable


@Serializable
data class DocumentDiagnosticParams(
    val textDocument: TextDocumentIdentifier,
    val identifier:String? = null ,
    val previousResultId : String? = null 
)
