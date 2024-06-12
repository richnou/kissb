package jsonrpc.workspace

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable
import java.io.File
import java.net.URI
import kotlin.io.path.toPath

@Serializable
enum class FileChangeType(val t: Int) {
    @SerialName("1")
    CREATED(1),
    @SerialName("2")
    CHANGED(2),
    @SerialName("3")
    DELETED(3)
}
@Serializable
data class FileEvent (
    val uri: String,
    val type: FileChangeType
) {
    fun toFile(): File {
        return URI.create(uri).toPath().toFile()
    }
}
@Serializable
data class WorkspaceChangeWatchedFilesParams (
    val changes: Array<FileEvent>
)
