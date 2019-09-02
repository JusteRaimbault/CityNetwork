
import org.nlogo.headless.HeadlessWorkspace

object Test extends App {

  val modelFile = "Flocking3D.nlogo3d"

  def main(file: String) = {
     //test_many_open(file)
     val ws = open(file)
     run(ws,"setup")
     ws.dispose()
  }

  def test_many_open(file: String) = {
    for(i <- 1 to 1000){
      println("ws instance "+i.toString)
      open(file)
    }
  }

  def open(file:String): HeadlessWorkspace = {
     val ws =  HeadlessWorkspace.newInstance
     ws.open(file)
     //Thread.sleep(2000)
     //ws.dispose()
     ws
  }

  def run(ws: HeadlessWorkspace,command: String): Unit = {
    ws.command(command)
  }

  //main(args(0))
  main(modelFile)

}
