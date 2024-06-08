
//import org.apache.commons.lang3.concurrent.locks.LockingVisitors.StampedLockVisitor
import java.io.File 
import java.util.jar.JarFile
import java.net.URLClassLoader
import java.sql.DriverManager 
import org.duckdb.DuckDBTime
 
fun main() {

    //val lock = StampedLockVisitor<PrintStream>()

    println("Hello World!")

    val testDep = File("/home/rleys/.cache/coursier/v1/https/repo1.maven.org/maven2/org/apache/commons/commons-lang3/3.14.0/commons-lang3-3.14.0.jar")
    println("Test dep: ${testDep.exists()}")

    // DB
    //---------------
    Class.forName("org.duckdb.DuckDBDriver");
    val conn = DriverManager.getConnection("jdbc:duckdb:");
    val stmt = conn.createStatement();
    val rs = stmt.executeQuery("SELECT 42");

    // Open
    //-----------
    val jar = JarFile(testDep)
    jar.entries().toList().find {
        entry -> entry.realName.endsWith(".class")
           

    }?.let { entry -> 
         println("Class: $entry")

         // Load
         val cl = URLClassLoader(arrayOf(testDep.toURI().toURL()))
         jar.getInputStream(entry).read()

         val loadedClass = cl.loadClass("org.apache.commons.lang3.AnnotationUtils")
         println("P=${loadedClass.packageName}")
    }

}