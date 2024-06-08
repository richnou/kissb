
import androidx.compose.runtime.Composable
import androidx.compose.ui.window.WindowState
import androidx.compose.ui.window.singleWindowApplication
import androidx.compose.ui.unit.dp
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

}