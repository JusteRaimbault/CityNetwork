package interaction

import java.io.File
import scala.util.Random

class ModelLauncher {

  var logmse: Double = 0

  def main(pops: File, dists: File, fdists: File,
    gr: Double, gw: Double, gg: Double, gd: Double,
    fw: Double, fg: Double, fd: Double,
    replication: Int) = {

    //println("Params : " + growthRate + " ; " + gravityWeight + " ; " + gravityGamma + " ; " + gravityDecay + " ; " + feedbackWeight + " ; " + feedbackGamma+ " ; " + feedbackDecay)
    //var t = System.currentTimeMillis()

    implicit val rng = new Random

    val model = new InteractionModel {
      override def growthRate: Double = gr
      override def gravityWeight: Double = gw
      override def gravityGamma: Double = gg
      override def gravityDecay: Double = gd
      override def feedbackWeight: Double = fw
      override def feedbackGamma: Double = fg
      override def feedbackDecay: Double = fd
      override def populations: File = pops
      override def distances: File = dists
      override def feedbackDistances: File = fdists
    }

    model.setup()
    model.run(rng)

    logmse = model.logmse()

    //println("Indicators : logmse = " + logmse)
    //println("Ellapsed Time : " + (System.currentTimeMillis() - t) / 1000.0 + "\n")

  }

}
