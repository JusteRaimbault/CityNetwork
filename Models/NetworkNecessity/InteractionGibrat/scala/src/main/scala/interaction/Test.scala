package interaction

import java.io.File
import Jama.Matrix

object Test extends App {

  def testMatrix() = {
    InteractionModel.parseMatrixFile(new File("/Users/Juste/Documents/ComplexSystems/CityNetwork/Models/NetworkNecessity/InteractionGibrat/data/pop50.csv"))
  }

  def testRun() = {
    val pop = new File("/Users/Juste/Documents/ComplexSystems/CityNetwork/Models/NetworkNecessity/InteractionGibrat/data/pop50.csv")
    val dists = new File("/Users/Juste/Documents/ComplexSystems/CityNetwork/Models/NetworkNecessity/InteractionGibrat/data/dist50.csv")
    val fdists = new File("/Users/Juste/Documents/ComplexSystems/CityNetwork/Models/NetworkNecessity/InteractionGibrat/data/distMat_Ncities50_alpha03_n03.csv")
    InteractionModel.setup(pop, dists, fdists)
    val res = InteractionModel.run(0.06, 0.002, 0.8, 1000, 0.001, 0.8, 100)
    for (t <- 0 to res.getColumnDimension() - 1) { println(res.get(0, t)) }
    val real = InteractionModel.populationMatrix.copy()

    val logres = new Matrix(res.getArray().map { _.map { d => Math.log(d) } })
    val logreal = new Matrix(real.getArray().map { _.map { d => Math.log(d) } })
    val sqdiff = logres.minus(logreal).arrayTimes(logres.minus(logreal))
    println(sqdiff.getArray().flatten.sum)

  }

  //testMatrix()
  testRun

}
