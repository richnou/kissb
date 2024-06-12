package index

import kotlinx.coroutines.yield
import java.io.File
import java.sql.Connection
import java.sql.DriverManager
import java.sql.ResultSet
import java.sql.SQLException


class DuckIndexdbInstanceR1(output: File) {

    lateinit var connection: Connection

    init {
        Thread.currentThread().contextClassLoader.loadClass("org.duckdb.DuckDBDriver");
        connection = DriverManager.getConnection("jdbc:duckdb:${output.absolutePath}");
        Runtime.getRuntime().addShutdownHook(object : Thread() {
            override fun run() {
                super.run()
                connection.close()
            }
        })
        //val stmt = connection.createStatement();
        //val rs = stmt.executeQuery("SELECT 42");

    }

    fun resetTable() {
        try {
            connection.createStatement().execute("TRUNCATE indexed_lib;")
            connection.createStatement().execute("DROP TABLE indexed_lib;")
        } catch (e: SQLException) {
            e.printStackTrace()
        } finally {
            connection.createStatement()
                .execute("CREATE TABLE indexed_lib (name VARCHAR, category VARCHAR, type VARCHAR, filename VARCHAR);")
        }


    }

    fun loadParquetFile(f: File) {
        connection.createStatement()
            .execute("INSERT INTO indexed_lib SELECT * FROM read_parquet('${f.absolutePath}',filename = true);")
    }

    fun loadJSONFile(f: File) {
        connection.createStatement()
            .execute("INSERT INTO indexed_lib SELECT * FROM read_json('${f.absolutePath}',format='array',filename = true);")
    }


    // Queries
    //----------------
    fun searchPossibleNextPackage(prefix: String): List<String> {
        val q = "SELECT name FROM indexed_lib WHERE category = 'package' AND name ILIKE '$prefix%' ;"
        println("Q=$q")
        val res = connection.createStatement().executeQuery(q)
        return res.asStringList().map {
            println("Found package: $it")
            it.removePrefix(prefix).split('.').first() }.distinct()
    }

    fun ResultSet.asStringList():  List<String> {
        var lst = mutableListOf<String>()
        while (next()) {
            lst += getString(1)
        }
        return lst
    }
}
