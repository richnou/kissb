package jsonrpc.language

import kotlinx.serialization.Serializable

@Serializable
data class CompletionOptions(
    val resolveProvider : Boolean = false,
    val triggerCharacters : Array<String>? =null,
    val allCommitCharacters : Array<String>? =null,
    val completionItem : CompletionOptionsCompletionItem = CompletionOptionsCompletionItem()
    
)

@Serializable
data class CompletionOptionsCompletionItem(
    val labelDetailsSupport : Boolean = true,
    
    
    
)
