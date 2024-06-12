package compiler

import com.intellij.openapi.Disposable
import com.intellij.openapi.project.Project
import com.intellij.openapi.util.Disposer
import kotlinx.coroutines.runBlocking
import org.jetbrains.kotlin.cli.jvm.K2JVMCompiler
import org.jetbrains.kotlin.cli.jvm.compiler.KotlinCoreEnvironment
import org.jetbrains.kotlin.cli.jvm.compiler.TopDownAnalyzerFacadeForJVM
import org.jetbrains.kotlin.cli.metadata.K2MetadataCompiler
import org.jetbrains.kotlin.config.CompilerConfiguration
import java.io.File

fun main(args: Array<String>) {

    println("Hi: " + File("").absolutePath)

    val localProject = LocalKotlinKBFolder(File("/home/rleys/git/promd/kissbuild/examples-kb-tcl/app_kotlin"))


    val env = KotlinCoreEnvironment.getOrCreateApplicationEnvironmentForProduction(
        Disposer.newDisposable(),
        CompilerConfiguration()
    )

    env.
    TopDownAnalyzerFacadeForJVM.analyzeFilesWithJavaIntegration(
        null,null,null
    )

    // Testing Build
    /*runBlocking {
        localProject.compileFromBuild()
        localProject.compileFromBuild()
    }*/

    // Indexing
    //-----------------
    println("Args: ${args.toList()}")
    when (args.firstOrNull()) {
        null -> {
            // TEsting indexing
            runBlocking {
                //localProject.indexBuildDependencies()
            }
        }

        else -> {
            val q = args[1]
            println("Query: $q")

            localProject.indexDb.searchPossibleNextPackage("org.").forEach {
                println("Possible package: $it")
            }
        }
    }


    /*val mdc = K2MetadataCompiler()
    val jvmK2 = K2JVMCompiler()
    
    val compArgs = arrayOf(
        "-kotlin-home","/home/rleys/git/promd/kissbuild/examples-kb-tcl/app_kotlin/.kb/toolchain/kotlin/kotlinc",
        "-language-version","2.0",
        "/home/rleys/git/promd/kissbuild/examples-kb-tcl/app_kotlin/src/main/kotlin/MyClass.kt")
    
    val args = jvmK2.createArguments()
    
    println("Pass1")
    jvmK2.exec(System.out,*compArgs)
    println("Pass2")
    jvmK2.exec(System.out,*compArgs)
    println("Pass3")
    jvmK2.exec(System.out,*compArgs)
    //jvmK2.exec(System.out,*compArgs)
   // mdc.exec(System.out,"-d","out.md",*compArgs)
    */
    println("Finished")
}
