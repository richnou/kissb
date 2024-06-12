package jsonrpc.common

import kotlinx.serialization.Serializable

@Serializable
data class Range(
    val start : Position,
    val end:Position
)
@Serializable
data class Position(
    val line: Int,
    val character:Int
)
