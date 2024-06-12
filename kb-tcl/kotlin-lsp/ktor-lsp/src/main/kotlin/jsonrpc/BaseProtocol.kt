package jsonrpc

import io.ktor.utils.io.*


suspend fun ByteWriteChannel.sendJRPCMessage(rsp:String) {
    
    val bytes = rsp.toByteArray(Charsets.UTF_8)
    this.writeStringUtf8("Content-Length: ${bytes.size}\r\n")
    this.writeStringUtf8("\r\n")
    this.writeFully(bytes)
} 
