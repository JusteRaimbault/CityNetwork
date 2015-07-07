package synthetic.density

import java.io.{BufferedReader, File, FileReader}


import synthetic.density.generator.PrefAttDiffusionGenerator
import scala.util.Random
import scala.sys.process._

object TestGenerator extends App{

  val t = System.currentTimeMillis()

  implicit val rng = new Random

  val gen = new PrefAttDiffusionGenerator {
    override def size: Int = 100

    // exp Mixture params
    /*override def kernelRadius = 1
    override def centersNumber = 4
    override def maxPopulation  =1000
*/

    //prefAttdiff
    override def totalPopulation :Double = 10000
    override def diffusion : Double = 0.08
    override def diffusionSteps : Int = 2
    override def growthRate : Int = 1000
    override def alphaAtt : Double = 1.1

  }

  // compute
  //val world = gen.world(rng)
  gen.export(rng)

  println("Ellapsed Time generation : "+(System.currentTimeMillis()-t)/1000.0)

  // external call to compute indicators
  ("R -e source('../csv2raster.R',chdir=TRUE);source('../morpho.R',chdir=TRUE);exportIndics()").!


  //get back indicators
  val r = new BufferedReader(new FileReader(new File("temps_indics.csv")))
  r.readLine();
  val indics = r.readLine().split(";")
  val moran = indics(0)
  val distance=indics(1)
  val entropy=indics(2)
  val slope=indics(3)
  val rsquared=indics(4)

  println(moran)
  // generate instance of container
  /*println("Moran : "+Morphology.moran(world)+" ("+(System.currentTimeMillis()-t)/1000.0+" s)")
  println("Distance : "+Morphology.distanceMean(world)+" ("+(System.currentTimeMillis()-t)/1000.0+" s)")
  println("Slope : "+Morphology.slope(world)+" ("+(System.currentTimeMillis()-t)/1000.0+" s)")
  println("Entropy : "+Morphology.entropy(world)+" ("+(System.currentTimeMillis()-t)/1000.0+" s)")

*/
  println("Ellapsed Time : "+(System.currentTimeMillis()-t)/1000.0)

}
