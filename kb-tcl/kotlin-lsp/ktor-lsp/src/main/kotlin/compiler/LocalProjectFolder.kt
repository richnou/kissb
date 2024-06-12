package compiler

import com.intellij.openapi.project.Project
import com.intellij.psi.PsiFileFactory
import index.DuckIndexdbInstanceR1
import index.JSONJarIndexer
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.jsonPrimitive
import org.jetbrains.kotlin.cli.jvm.K2JVMCompiler
import org.jetbrains.kotlin.cli.jvm.compiler.EnvironmentConfigFiles
import org.jetbrains.kotlin.cli.jvm.compiler.KotlinCoreEnvironment
import org.slf4j.LoggerFactory
import java.io.File
import java.io.PipedInputStream
import java.io.PipedOutputStream
import java.io.PrintStream
import java.lang.IllegalArgumentException
import kotlin.coroutines.resume
import kotlin.coroutines.resumeWithException
import kotlin.coroutines.suspendCoroutine


class LocalKotlinKBFolder(val base: File) {

    val logger = LoggerFactory.getLogger("kotlin.compiler")
    
    val toolchainFolder = File(base, ".kb/toolchain/kotlin")
    val kotlinc = File(toolchainFolder, "kotlinc/bin/kotlinc").absolutePath

    val buildFile = File(base, ".kb/toolchain/kotlin/build.main.json")
    //val jvmK2 = K2JVMCompiler()
    
    val compiler = K2JVMCompiler()
    
    /*val psiFactory = PsiFileFactory.getInstance(KotlinCoreEnvironment.createForProduction(CompilerConfiguration(),EnvironmentConfigFiles())
        
    ))*/
    
    val indexDb = DuckIndexdbInstanceR1(File(toolchainFolder,"semantic-index-r1.db"))
    
    init {
        
    }

    fun isBuildFile() = buildFile.exists()

    fun getBuildConfig() = buildFile.takeIf { it.exists() }?.let { Json.decodeFromString<BuildConfig>(it.readText()) }

    class CompileResult(
        val file: File,
        val line: Int,
        val col: Int,
        val message: String,
        val error: Boolean
    ) {

    }

    suspend fun compileFileResult(f: File): List<CompileResult> {
        return this.compileFromBuild(listOf(f)) ?: emptyList()
    }
    
    fun List<String>.parseCompileResults(): List<CompileResult> {
        return this.mapNotNull { line -> 
            if (line.contains("error")) {
                val split = line.split(':')
                CompileResult(
                    file = File(split[0]),
                    line = split[1].toInt(),
                    col = split[2].toInt(),
                    error = true,
                    message = split.drop(3).joinToString(" ")
                )
            } else {
                null
            }
        }
    }

    suspend fun compileFromBuild(f: List<File> = emptyList()) : List<CompileResult>? {
        return getBuildConfig()?.let {

            logger.info("Building module: ${it.module}")
            when (it.platform) {
                "jvm" -> {
                    
                    logger.info("K2 JVm Compilation")
                    
                    

                    // Gather all args
                    val cargs = arrayOf(
                        *it.args.map { it.jsonPrimitive.content }.toTypedArray(),
                        "-cp", *it.classpath,
                        *it.sources
                    )
                    
                    logger.info("Args: ${cargs.toList()}")
                    
                    // Run
                    val pis = PipedInputStream()
                    val os = PipedOutputStream(pis)
                    val r = withContext(Dispatchers.IO) {
                        suspendCoroutine<List<String>> { continuation ->

                            launch {

                                val resLines = pis.bufferedReader().readLines()
                                println("Compiler es: $resLines")
                                continuation.resume(resLines)
                            }
                            launch {
                                try {
                                    val pos = PrintStream(os)
                                    val exit = compiler.exec(pos, *cargs)
                                    println("Done Running ${exit.code}")
                                    pos.close()
                                } catch (e: Throwable) {
                                    e.printStackTrace()
                                    continuation.resumeWithException(e)
                                }

                            }
                        }
                    }
                    
                    r.parseCompileResults()
                }

                else -> {
                    throw IllegalArgumentException("Non supported platform ${it.platform}")
                }
            }
        }
    }

    suspend fun compileFile(f: File): List<String> {

        val processBuilder = ProcessBuilder(
            kotlinc, "-Xenable-incremental-compilation", "-Xuse-fir-ic", "-language-version", "2.0", f.absolutePath
        )
        processBuilder.redirectErrorStream(true)
        //processBuilder.redirectOutput()
        //processBuilder.inheritIO()

        return withContext(Dispatchers.IO) {
            suspendCoroutine<List<String>> { continuation ->
                val process = processBuilder.start()
                launch {
                    val reader = process.inputStream.bufferedReader()
                    /*var l : String? = ""
                    while (l!=null) {
                        l = reader.readLine()
                        println("Got line: $l")
                    }
                    //val lines = reader.readLines()*/
                    val lines = reader.readLines()
                    println("Finished readlines: $lines")
                    continuation.resume(lines)
                    //continuation.resume(emptyList())
                }
                /*launch {
                    val reader = process.errorStream.bufferedReader()
                    var l : String? = ""
                    while (l!=null) {
                        l = reader.readLine()
                        println("Got Err line: $l")
                    }
                    //val lines = reader.readLines()
                    println("Finished readlines")
                // continuation.resume(lines)
                    //continuation.resume(emptyList())
                }*/
                launch {
                    try {
                        val res = process.waitFor()
                        // continuation.resume(res)
                    } catch (e: Throwable) {
                        continuation.resumeWithException(e)
                    }
                }


            }

        }

    }
    
    
    // index
    //----------
    suspend fun indexBuildDependencies() {
        indexDb.resetTable()
        getBuildConfig()?.let {
            build ->
            
            build.classpath.forEach {
                cp ->
                
                    if (cp.endsWith(".jar")) {
                        indexJarParquet(File(cp))      
                    }
            }
        }
    }
    suspend fun indexJarParquet(jar:File) {
        logger.info("Indexing Jar as Parquet file $jar")
        
        val targetParquetFile = File(jar.parentFile.absoluteFile,jar.name.replace(".jar","")+".r1-index.parquet")
        val targetJsonFile = File(jar.parentFile.absoluteFile,jar.name.replace(".jar","")+".r1-index.json")
        logger.info("Output index file: $targetParquetFile")
        
        // Indexing: Open Jar file, load all symbols and write to parket
        JSONJarIndexer.indexJarToJson(jar,targetJsonFile)
        
        // Load Parquet into DB
        indexDb.loadJSONFile(targetJsonFile)
    }
}
