import compiler.LocalKotlinKBFolder
import io.ktor.network.selector.*
import io.ktor.network.sockets.*
import io.ktor.util.*
import io.ktor.utils.io.*
import io.ktor.utils.io.core.*
import jsonrpc.*
import jsonrpc.common.Position
import jsonrpc.common.Range
import jsonrpc.language.*
import jsonrpc.request.DocumentDiagnosticParams
import jsonrpc.request.MessageType
import jsonrpc.request.ShowMessageParams
import jsonrpc.request.lspSendWindowMessage
import jsonrpc.workspace.FileChangeType
import jsonrpc.workspace.WorkspaceChangeWatchedFilesParams
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.runBlocking
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.decodeFromJsonElement
import kotlinx.serialization.json.encodeToJsonElement
import org.jetbrains.kotlin.cli.jvm.K2JVMCompiler
import org.slf4j.LoggerFactory
import java.io.IOException

fun main() {

    println("Run LSP Server 2...")


    val selectorManager = SelectorManager(Dispatchers.IO)
    val serverSocket = aSocket(selectorManager).tcp().bind("0.0.0.0", 9002)

    val logger = LoggerFactory.getLogger("main")
    logger.info("Will start listening")

    val json = Json { ignoreUnknownKeys = true }

    runBlocking {
        while (true) {

            val clientSocket = serverSocket.accept()

            // Launch Handler for Client Connection
            //-----------------------
            launch {
                val logger = LoggerFactory.getLogger("client.${clientSocket.socketContext.key.toString()}")
                val read = clientSocket.openReadChannel()
                val write = clientSocket.openWriteChannel(autoFlush = true)

                // Params
                var kotlinKBFolder: LocalKotlinKBFolder? = null

                // Main Loop

                var opened = true
                while (opened) {
                    var line = read.readUTF8Line()
                    if (line == null) {
                        opened = false
                    } else {
                        logger.info("Got Line from client: $line")
                        if (line.startsWith("Content-Length:")) {

                            val length = line.split(' ').last().toInt()

                            // Get Empty Line
                            read.readUTF8Line()
                            try {

                                // read.read(desiredSize = length)
                                val packet = read.readPacket(length)
                                val messageText = packet.readText().trim()

                                logger.info("Got JSON RPC: " + messageText)
                                logger.info("RPC Length: " + messageText.toByteArray().size)

                                val request = json.decodeFromString<JRPCRequest>(messageText)
                                logger.info("RPC Method: ${request.method}")

                                // Process
                                //---------------
                                when (request.method) {

                                    "initialize" -> {
                                        // Info
                                        request.params?.let {
                                            val initParams: MsgInitialiseParams = json.decodeFromJsonElement(it)
                                            initParams.workspaceFolders?.forEach {
                                                logger.info("Available Folder: ${it.name} -> ${it.uri}")

                                                // Search for Local Compiler
                                                //-----------
                                                kotlinKBFolder = LocalKotlinKBFolder(it.toFile())
                                            }
                                        }

                                        // Create Compiler
                                        //val compiler = K2JVMCompiler()
                                        //compiler.createArguments().fil

                                        //val compiler = org.jetbrains.kotlin.compiler.
                                        // Response
                                        val response = JRPCResponse(
                                            jsonrpc = "2.0",
                                            id = request.id,
                                            result = json.encodeToJsonElement(
                                                InitializedResult(
                                                    capabilities = InitializedResultServerCapabilities(
                                                        hoverProvider = false,
                                                        diagnosticProvider = InitializedResultServerCapabilitiesDiagnosticOptions(
                                                            identifier = "kissb-kotlin"
                                                        ),
                                                        completionProvider = CompletionOptions()
                                                    ),
                                                    serverInfo = InitializedResultServerInfo(
                                                        name = "KISSB-KLSP",
                                                        version = "1.0"
                                                    )
                                                )
                                            )
                                        )
                                        val responseText = json.encodeToString(response)
                                        write.sendJRPCMessage(responseText)

                                        // Message
                                        write.lspSendWindowMessage(
                                            "Welcome to KISSB-Kotlin Build Server",
                                            MessageType.Info
                                        )

                                    }

                                    "textDocument/diagnostic" -> {
                                        request.params?.let { json.decodeFromJsonElement<DocumentDiagnosticParams>(it) }
                                            ?.let { diagRequest ->

                                                if (kotlinKBFolder == null) {
                                                    write.lspSendWindowMessage("No Kotlin Folder", MessageType.Log)
                                                } else {
                                                    write.lspSendWindowMessage("Found Kotlin Folder", MessageType.Log)
                                                }


                                                val diag = JRPCRequest(
                                                    "2.0",
                                                    method = "textDocument/publishDiagnostics",
                                                    params = json.encodeToJsonElement(
                                                        PublishDiagnosticsParams(
                                                            //uri = "file:///c%3A/Users/leysr/git/promd/sw/kotlin-vscodetest/src/main/kotlin/Hello.kt",
                                                            uri = diagRequest.textDocument.uri,
                                                            diagnostics = arrayOf(
                                                                PublishDiagnosticsParamsDiagnostic(
                                                                    range = Range(
                                                                        start = Position(
                                                                            line = 1,
                                                                            character = 1
                                                                        ), end = Position(line = 1, character = 2)
                                                                    ),
                                                                    message = "Diagnostic from KISSB",
                                                                    severity = DiagnosticSeverity.Error,

                                                                    )
                                                            )
                                                        )
                                                    )
                                                )
                                                logger.info("Returning diagnostic: " + json.encodeToString(diag))
                                                write.sendJRPCMessage(json.encodeToString(diag))
                                            }
                                        // val diagRequest = request.params?


                                    }

                                    "textDocument/completion" -> {
                                        request.params?.let {
                                            val completionParam =
                                                json.decodeFromJsonElement<TextDocumentCompletionParams>(it)

                                            // Get File
                                            //---------------
                                            val file = completionParam.textDocument.toFile()

                                            // Get Line Part

                                            //val searchPrefix = file.readLines()[completionParam.position.line].substring(0 until completionParam.position.character)

                                            //logger.info("Searching for definition starting with: $searchPrefix")

                                        }
                                    }
                                    "workspace/didChangeWatchedFiles" -> {

                                        if (kotlinKBFolder == null) {
                                            write.lspSendWindowMessage("No Kotlin Folder", MessageType.Info)
                                        } else {
                                            write.lspSendWindowMessage("Found Kotlin Folder", MessageType.Info)

                                            request.params?.let {
                                                val changesParams =
                                                    json.decodeFromJsonElement<WorkspaceChangeWatchedFilesParams>(it)
                                                changesParams.changes.forEach { fileChange ->
                                                    if (fileChange.type != FileChangeType.DELETED) {

                                                        logger.info("Compiling file: ${fileChange.toFile()}")
                                                        val compileResults =
                                                            kotlinKBFolder!!.compileFileResult(fileChange.toFile())
                                                        logger.info("Compilation result: $compileResults")

                                                        val diag = JRPCRequest("2.0",
                                                            method = "textDocument/publishDiagnostics",
                                                            params = json.encodeToJsonElement(
                                                                PublishDiagnosticsParams(
                                                                    //uri = "file:///c%3A/Users/leysr/git/promd/sw/kotlin-vscodetest/src/main/kotlin/Hello.kt",
                                                                    uri = fileChange.uri,
                                                                    diagnostics = compileResults.map { compileRes ->
                                                                        PublishDiagnosticsParamsDiagnostic(
                                                                            range = Range(
                                                                                start = Position( line = compileRes.line, character = compileRes.col ),
                                                                                end = Position( line = compileRes.line, character = compileRes.col )
                                                                            ),
                                                                            message = compileRes.message,
                                                                            severity = DiagnosticSeverity.Error, )
                                                                    }.toTypedArray()
                                                                )
                                                            ))

                                                        write.sendJRPCMessage(json.encodeToString(diag))

                                                    }
                                                }
                                            }

                                        }


                                    }

                                    else -> {

                                    }
                                }


                                /*if (request.method == "initialize") {


                                    //write.write
                                    //write.writeStringUtf8("^$responseText\r\n")

                                } else if (request.method == "workspace/didChangeWatchedFiles") {

                                    val diag = JRPCRequest("2.0", method = "textDocument/publishDiagnostics", params = json.encodeToJsonElement(
                                        PublishDiagnosticsParams(
                                            uri = "file:///c%3A/Users/leysr/git/promd/sw/kotlin-vscodetest/src/main/kotlin/Hello.kt",
                                            diagnostics = arrayOf(
                                                PublishDiagnosticsParamsDiagnostic(
                                                    range = Range(start = Position(line = 1, character = 1),end = Position(line = 1, character = 2)),
                                                    message = "Diagnostic from KISSB",
                                                    severity = DiagnosticSeverity.Error,

                                                )
                                            )
                                        )
                                    ))
                                    logger.info("Returning diagnostic: "+json.encodeToString(diag))
                                    write.sendJRPCMessage(json.encodeToString(diag))

                                } else {
                                    write.writeStringUtf8("{}\r\n")

                                }*/

                                // Send Response
                                //-------------


                                /* read.readAvailable(min= length) {
                                                    println("Content received: ${String(it.moveToByteArray())}")

                                    }*/
                                //write.writeStringUtf8("\r\n")
                            } catch (e: IOException) {
                                e.printStackTrace()
                                opened = false
                            }


                        }
                        //write.writeStringUtf8("\r\n")
                    }

                }
            }
        }
    }

}