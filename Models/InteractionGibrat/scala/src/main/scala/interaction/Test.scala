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
    val fdates = new File("/Users/Juste/Documents/ComplexSystems/CityNetwork/Models/NetworkNecessity/InteractionGibrat/data/dates.csv")
    InteractionModel.setup(pop, dists, fdists, fdates)
    var res: Matrix = null
    //for (decay <- 10.0 to 200.0 by 10.0) {
    //  println(decay)
    res = InteractionModel.run(0.002, 0.01, 2.0, 100.0, 2.0, 0.01, 2.0, 50.0)
    /*for (t <- 0 to res.getColumnDimension() - 1) { println(res.get(0, t)) }
    val real = InteractionModel.populationMatrix.copy()

    val logres = new Matrix(res.getArray().map { _.map { d => Math.log(d) } })
    val logreal = new Matrix(real.getArray().map { _.map { d => Math.log(d) } })
    val sqdiff = logres.minus(logreal).arrayTimes(logres.minus(logreal))
    println(sqdiff.getArray().flatten.sum)
    */
    println(InteractionModel.logmse(res))
    println(InteractionModel.mselog(res))
    //}
  }

  def testLauncher() = {
    val pop = new File("/Users/Juste/Documents/ComplexSystems/CityNetwork/Models/NetworkNecessity/InteractionGibrat/data/pop50.csv")
    val dists = new File("/Users/Juste/Documents/ComplexSystems/CityNetwork/Models/NetworkNecessity/InteractionGibrat/data/dist50.csv")
    val fdists = new File("/Users/Juste/Documents/ComplexSystems/CityNetwork/Models/NetworkNecessity/InteractionGibrat/data/distMat_Ncities50_alpha03_n03.csv")
    val fdates = new File("/Users/Juste/Documents/ComplexSystems/CityNetwork/Models/NetworkNecessity/InteractionGibrat/data/dates.csv")

    for (decay <- 10.0 to 200.0 by 10.0) {
      ModelLauncher.main(pop, dists, fdists, fdates, 0.02, 0.0, 1.0, 1000, 0.0, 0.2, 1.0, decay, 1)
      println(ModelLauncher.logmse)
      println(ModelLauncher.mselog)
    }
  }

  //testMatrix()
  testRun
  //testLauncher

}
