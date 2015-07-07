package synthetic.density.generator

import synthetic.density.Cell

import scala.util.Random


trait ExpMixtureGenerator extends Generator{


  /** maximal capacity C_m */
  def maxPopulation : Int

  /** Size of exponential kernels, of the form C_m*exp(-||x-x_0||/r_0) */
  def kernelRadius : Double

  /** Number of exponential kernels */
  def centersNumber : Int

  def world(implicit rng: Random) : Seq[Seq[Cell]] = {
    val arrayVals = Array.fill[Cell](size, size) {
      new Cell(0)
    }

    // generate random center positions
    val centers = Array.fill[Int](centersNumber, 2) {
      rng.nextInt(size)
    }

    for (i <- 0 to size - 1; j <- 0 to size - 1) {
      for (c <- 0 to centersNumber - 1) {
        arrayVals(i)(j).population = arrayVals(i)(j).population + maxPopulation * math.exp(-math.sqrt(math.pow((i - centers(c)(0)), 2) + math.pow((j - centers(c)(1)), 2)) / kernelRadius)
      }
    }

    Seq.tabulate(size,size){(i:Int,j:Int)=>new Cell(arrayVals(i)(j).population) }

  }

}
