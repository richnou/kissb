package index

import java.io.File
import java.net.URLClassLoader
import java.util.jar.JarFile

object ParquetJARIndexer {
    
    fun indexJarToParquet(jarFile:File,parquetFile:File) {
        
        val jar = JarFile(jarFile)
        val cl = URLClassLoader(arrayOf(jarFile.toURI().toURL()))
        try {
            // Map entries to loaded classes
            val classes = jar.entries().toList().mapNotNull {
                entry ->
                entry.takeIf { it.realName.endsWith(".class") && !it.realName.contains("module-info") }?.let {
                    // Clean name and load
                    val cleanName = it.realName.replace('/','.').replace("""(\$.+)?\.class""".toRegex(),"")
                    println("Load class $cleanName")
                    cl.loadClass(cleanName)
                }
            }
            
            // Index Packages
            classes.flatMap{cl.definedPackages.map { it.name }}.distinct().forEach {
                
            }
        } finally {
            cl.close()
            jar.close()
        }
        
        
        
        /*jar.entries().toList().find {
            entry -> entry.realName.endsWith(".class")
                
        
        }?.map { entry -> 
            println("Class: $entry")
        
            // Load
            //jar.getInputStream(entry).read()
        
            val loadedClass = cl.loadClass("org.apache.commons.lang3.AnnotationUtils")
            println("P=${loadedClass.packageName}")
        }*/
    }
}