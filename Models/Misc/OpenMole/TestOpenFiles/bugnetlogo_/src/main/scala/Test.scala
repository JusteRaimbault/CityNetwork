
import org.nlogo.headless.HeadlessWorkspace

object Test extends App {

  def main(file:String) = {
     for(i <- 1 to 1000){
       println("ws instance "+i.toString)
       open(file)
       //Thread.sleep(1000)
     }
  }


  def open(file:String) = {
     val ws =  HeadlessWorkspace.newInstance
     ws.open(file)
     Thread.sleep(2000)
     ws.dispose()
  }


  main(args(0))

}
