
import androidx.compose.runtime.Composable
import androidx.compose.ui.window.WindowState
import androidx.compose.ui.window.singleWindowApplication
import androidx.compose.ui.unit.dp
import androidx.compose.ui.Modifier
import androidx.compose.material.Text
import androidx.compose.material.Button
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.fillMaxHeight
import java.io.File
import test.extensions.testExt4


fun main() {
    println("Hi with compose")
    val f = File("tt").readText()

    val f = File("")
    f.listFiles()
    
    //topUI()  
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
        Button(modifier = Modifier.fillMaxWidth().fillMaxHeight(),onClick= { counter.value += 1 }) {
            Text("Click to increment")
        }
    }
    
}