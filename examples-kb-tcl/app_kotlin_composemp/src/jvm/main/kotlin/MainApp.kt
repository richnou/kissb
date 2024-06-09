
import androidx.compose.runtime.Composable
import androidx.compose.ui.window.WindowState
import androidx.compose.ui.window.singleWindowApplication
import androidx.compose.ui.unit.dp
import androidx.compose.material.Text
import androidx.compose.material.Button
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.foundation.layout.Column

fun main() {
    println("Hi with compose")

      singleWindowApplication(
        title = "Test App",
        state = WindowState(width = 1280.dp, height = 768.dp),
        //icon = BitmapPainter(useResource("ic_launcher.png", ::loadImageBitmap)),
    ) {
        topUI()
    }
}


@Composable
fun topUI() {

    val counter = remember { mutableStateOf(0)}
    Column {
        Text("Test: ${counter.value}")
        Button(onClick= { counter.value += 1 }) {
            Text("Click to increment")
        }
    }
    
}