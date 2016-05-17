package interaction

import java.io.File

object Test extends App {

  def testMatrix() = {
    InteractionModel.parseMatrixFile(new File("/Users/Juste/Documents/ComplexSystems/CityNetwork/Models/NetworkNecessity/InteractionGibrat/data/pop50.csv"))
  }

  def testRun() = {
    val pop = new File("/Users/Juste/Documents/ComplexSystems/CityNetwork/Models/NetworkNecessity/InteractionGibrat/data/pop50.csv")
    val dists = new File("/Users/Juste/Documents/ComplexSystems/CityNetwork/Models/NetworkNecessity/InteractionGibrat/data/dist50.csv")
    val fdists = new File("/Users/Juste/Documents/ComplexSystems/CityNetwork/Models/NetworkNecessity/InteractionGibrat/data/fdists50.csv")
    InteractionModel.setup(pop, dists, fdists)
    val res = InteractionModel.run(0.06, 0.002, 0.8, 1000, 0.5, 0.8, 100)
    println(res.get(0, 20))
    val real = InteractionModel.populationMatrix.copy()

    res.getArray().map { _.map { d => Math.log(d) } }
    real.getArray().map { _.map { d => Math.log(d) } }
    val sqdiff = res.minus(real).arrayTimes(res.minus(real))
    println(sqdiff.getArray().flatten.sum)

  }

  //testMatrix()
  testRun

}
