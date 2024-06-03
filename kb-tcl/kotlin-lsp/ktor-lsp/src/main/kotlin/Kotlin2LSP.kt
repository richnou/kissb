import io.ktor.network.selector.*
import io.ktor.network.sockets.*
import io.ktor.utils.io.*
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.runBlocking
import org.slf4j.LoggerFactory

fun main() {
    
    println("Run LSP Server 2...")
    
    
    val selectorManager = SelectorManager(Dispatchers.IO)
    val serverSocket = aSocket(selectorManager).tcp().bind("0.0.0.0", 9002)
    
    val logger = LoggerFactory.getLogger("main")
    logger.info("Will start listening")
    
    runBlocking {
        while (true) {
                
            val clientSocket = serverSocket.accept()
                
            launch {
                val logger = LoggerFactory.getLogger("client.${clientSocket.socketContext.key.toString()}")
                val read = clientSocket.openReadChannel()
                val write =clientSocket.openWriteChannel(autoFlush = true)
                
                var opened = true
                while (opened) {
                    val line = read.readUTF8Line()
                    logger.info("Got Line from client: $line")
                }
            }
        }
    }
    
}