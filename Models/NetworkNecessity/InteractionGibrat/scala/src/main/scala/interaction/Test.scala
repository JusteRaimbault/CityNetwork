package interaction

import java.io.File

object Test extends App {

  def testMatrix() = {
    val model = new InteractionModel
    val m = model.parseMatrixFile(new File("/Users/Juste/Documents/ComplexSystems/CityNetwork/Models/NetworkNecessity/InteractionGibrat/data/pop50.csv"))
  }

  testMatrix()

}
