package jsonrpc.language

import jsonrpc.common.Range
import kotlinx.serialization.Serializable
import kotlinx.serialization.json.JsonElement
import java.lang.Error
import java.net.URI



@Serializable
data class PublishDiagnosticsParams(
    val uri:String,
    val version:Int?= null,
    val diagnostics : Array<PublishDiagnosticsParamsDiagnostic>? = null 
)

enum class DiagnosticSeverity(val s : Int) {
     Error(1),
     WARNING(2),
     INFO(3),
     HINT(4) 
}
enum class DiagnosticTag(val t : Int) {
     UNNECESSARY(1) ,
    DEPRECATED(2),
}
@Serializable
data class PublishDiagnosticsParamsDiagnostic(
    val range : Range,
    val message: String,
    val severity:  DiagnosticSeverity? = null,
    val code : Int? = null,
    val codeDescription:String? = null,
    val tags: Array<DiagnosticTag>? = null,
    val data : JsonElement? = null 
    
)
 
