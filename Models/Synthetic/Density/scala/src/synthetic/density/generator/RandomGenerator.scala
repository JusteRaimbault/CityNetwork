package synthetic.density.generator

import synthetic.density.Cell

import scala.util.Random


trait RandomGenerator extends Generator {

  def maxPopulation : Int

  def container(implicit rng: Random) = {
    Seq.fill(size, size) {
      val pop: Double = rng.nextInt(maxPopulation).toDouble
      new Cell(pop)
    }
  }

}
