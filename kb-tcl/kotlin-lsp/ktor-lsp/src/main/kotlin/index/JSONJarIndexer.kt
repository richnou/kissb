package index

import kotlinx.serialization.Serializable
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json
import java.io.File
import java.lang.reflect.Field
import java.lang.reflect.Method
import java.net.URLClassLoader
import java.util.jar.JarFile


@Serializable
data class Entry(
    val name : String,
    val category : String,
    val type : String 
)

@Serializable
data class IndexFile(
    var entries : Array<Entry>
)

object JSONJarIndexer {
    
    fun indexJarToJson(jarFile:File,jsonFile:File) {
        
        val jar = JarFile(jarFile)
        val cl = URLClassLoader(arrayOf(jarFile.toURI().toURL()))
        try {
            // Map entries to loaded classes
            val classes = jar.entries().toList().mapNotNull {
                entry ->
                entry.takeIf { it.realName.endsWith(".class") && !it.realName.contains("module-info")  }?.let {
                    // Clean name and load
                    val cleanName = it.realName.replace('/','.').replace("""(\$.+)?\.class""".toRegex(),"")
                    println("Load class $cleanName")
                    cl.loadClass(cleanName)
                }
            }
            
            // Index Packages
            println("Number of classes: ${classes.size}")
            val packagesEntries = classes.map{it.packageName}.distinct().map {
                println("Found package: $it")
                Entry(name = it, category = "package", type="undefined")
            }.toTypedArray()
            
            val classesEntries = classes.flatMap {
                cla -> 
                arrayOf(
                    Entry(name = cla.canonicalName, category = "class",type="undefined"),
                    *cla.declaredMethods.filter { it.modifiers == (Method.PUBLIC) }.map { m -> 
                        Entry(name = "${cla.canonicalName}.${m.name}",category="method", type=m.returnType.canonicalName)
                    }.toTypedArray(),
                    *cla.declaredFields.filter { it.modifiers == (Field.PUBLIC)  }.map { f -> 
                     Entry(name = "${cla.canonicalName}.${f.name}",category="field", type = f.type.canonicalName)
                    }.toTypedArray()
                ).toList()
            }.toTypedArray()
            
            // Store out
            //val jsonOut = Json.encodeToString(arrayOf(packagesEntries))
            //jsonFile.writeText(Json.encodeToString(IndexFile(packagesEntries)))
            jsonFile.delete()
            jsonFile.writeText(Json.encodeToString((packagesEntries + classesEntries)))
            
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
