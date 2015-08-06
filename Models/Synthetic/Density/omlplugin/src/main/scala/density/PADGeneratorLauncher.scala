package density

import scala.util.Random

class PADGeneratorLauncher {

  // static mutable fields to get indicators

  var moran: Double = 0
  var distance: Double = 0
  var entropy: Double = 0
  var slope: Double = 0
  var rsquared: Double = 0

  def main(worldwidth: Int, pop: Double, diff: Double, diffSteps: Int, growth: Double, alpha: Double, replication: Int) = {

    println("Params : " + pop + " ; " + diff + " ; " + diffSteps + " ; " + growth + " ; " + alpha + " ; " + replication)

    // replication and diffsteps should be enough in 'small' explorations,
    // easier to retrieve later (exact int value)
    val UIR = replication.toString + diffSteps.toString

    var t = System.currentTimeMillis()

    implicit val rng = new Random

    val gen = new PrefAttDiffusionGenerator {
      override def size: Int = worldwidth
      override def totalPopulation: Double = pop
      override def diffusion: Double = diff
      override def diffusionSteps: Int = diffSteps
      override def growthRate: Double = growth
      override def alphaAtt: Double = alpha
      override def temp_file: String = "tmp/pop_" + UIR + ".csv"
    }

    // compute
    val world = gen.world(rng)
    gen.export_static(world)

    moran = Morphology.moran_convol(world)
    distance = Morphology.distance_convol(world)
    entropy = Morphology.entropy(world)
    val slopeVals = Morphology.slope(world)
    slope = slopeVals._1
    rsquared = slopeVals._2

    println(gen.temp_file)
    println("Indicators : Moran = " + moran + " ; D = " + distance + " ; E = " + entropy + " ; alpha = " + slope + " ; R2 = " + rsquared)
    println("Ellapsed Time : " + (System.currentTimeMillis() - t) / 1000.0+"\n")

    /*

    //t=System.currentTimeMillis()
    //println("direct : "+ Morphology.distanceMean(world))
    //println("Ellapsed Time : " + (System.currentTimeMillis() - t) / 1000.0+"\n")


    t=System.currentTimeMillis()
    println("FFT : "+ Morphology.distance_convol(world))
    println("Ellapsed Time : " + (System.currentTimeMillis() - t) / 1000.0+"\n")

    //t=System.currentTimeMillis()
    //println("moran : "+ Morphology.moran(world))
    //println("Ellapsed Time : " + (System.currentTimeMillis() - t) / 1000.0+"\n")

    t=System.currentTimeMillis()
    println("moran FFT : "+ Morphology.moran_convol(world))
    println("Ellapsed Time : " + (System.currentTimeMillis() - t) / 1000.0+"\n")

    */

  }

}
