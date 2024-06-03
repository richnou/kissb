
import org.apache.commons.lang3.concurrent.locks.LockingVisitors.StampedLockVisitor

fun main() {

    val lock = StampedLockVisitor<PrintStream>()

    println("Hello World!")
}