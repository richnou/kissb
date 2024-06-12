package jsonrpc

import jsonrpc.language.CompletionOptions
import kotlinx.serialization.Serializable


@Serializable
data class InitializedResult(
    
    val capabilities : InitializedResultServerCapabilities,
    val serverInfo: InitializedResultServerInfo? = null 
) : CommonLSPType

@Serializable
data class InitializedResultServerInfo(
    val name:String,
    val version:String? = null 
)

@Serializable
data class InitializedResultServerCapabilities(
    
    val hoverProvider: Boolean? = null,
    val diagnosticProvider : InitializedResultServerCapabilitiesDiagnosticOptions? = null,
    val completionProvider : CompletionOptions? = null
)
@Serializable
data class InitializedResultServerCapabilitiesDiagnosticOptions(
    val workspaceDiagnostics : Boolean = true ,
    val interFileDependencies : Boolean = true ,
    
    val identifier : String ? = null 
)
