package synthetic.density.test

import synthetic.density.generator.ExpMixtureGenerator
import synthetic.density.metric.Morphology

import scala.util.Random


object TestGenerator extends App{

  val t = System.currentTimeMillis()

  implicit val rng = new Random

  val gen = new ExpMixtureGenerator {
    override def size: Int = 50

    // exp Mixture params
    override def kernelRadius = 1
    override def centersNumber = 4
    override def maxPopulation  =1000

    //prefAttdiff
    /*override def totalPopulation :Double = 10000
    override def diffusion : Double = 0.02
    override def diffusionSteps : Int = 2
    override def growthRate : Int = 100
    override def alphaAtt : Double = 1.1
    */
  }

  // compute
  val world = gen.world(rng)

  // generate instance of container
  println("Moran : "+Morphology.moran(world)+"\n Distance : "+Morphology.distanceMean(world)+"\n "+"\n Slope : "+Morphology.slope(world)+"\n Entropy : "+Morphology.entropy(world))

  println("Ellapsed Time : "+(System.currentTimeMillis()-t)/1000.0)
}
