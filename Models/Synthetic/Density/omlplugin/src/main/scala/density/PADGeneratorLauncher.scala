package density

import java.io.File

import scala.util.Random

class PADGeneratorLauncher {

  // static mutable fields to get indicators

  var moran: Double = 0
  var distance: Double = 0
  var entropy: Double = 0
  var slope: Double = 0
  var rsquared: Double = 0

  def main(worldwidth: Int, pop: Double, diff: Double, diffSteps: Double, growth: Double, alpha: Double, replication: Int, f: File) = {

    println("Params : " + pop + " ; " + diff + " ; " + diffSteps + " ; " + growth + " ; " + alpha + " ; " + replication)

    // replication and diffsteps should be enough in 'small' explorations,
    // easier to retrieve later (exact int value)
    //val UIR = replication.toString + diffSteps.toString

    var t = System.currentTimeMillis()

    implicit val rng = new Random

    val gen = new PrefAttDiffusionGenerator {
      override def size: Int = worldwidth
      override def totalPopulation: Double = pop
      override def diffusion: Double = diff
      override def diffusionSteps: Int = diffSteps.toInt
      override def growthRate: Double = growth
      override def alphaAtt: Double = alpha
      //override def temp_file: String = "tmp/pop_" + UIR + ".csv"
      override def export_file: File = f
    }

    // compute
    val world = gen.world(rng)

    // export to file variable, created by openmole
    gen.export_static(world, gen.export_file)

    moran = Morphology.moran_convol(world)
    distance = Morphology.distance_convol(world)
    entropy = Morphology.entropy(world)
    val slopeVals = Morphology.slope(world)
    slope = slopeVals._1
    rsquared = slopeVals._2

    println("Indicators : Moran = " + moran + " ; D = " + distance + " ; E = " + entropy + " ; alpha = " + slope + " ; R2 = " + rsquared)
    println("Ellapsed Time : " + (System.currentTimeMillis() - t) / 1000.0 + "\n")

  }

}
