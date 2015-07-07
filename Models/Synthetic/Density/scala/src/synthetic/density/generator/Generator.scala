package synthetic.density.generator

import synthetic.density.Cell

import scala.util.Random


trait Generator {

  def size : Int

  def world(implicit rng: Random): Seq[Seq[Cell]]


    /**
     * Stringify just to check validity of generators ; has no sense in general context as a new instance will be randomly generated at each
     * call of container.
     *
     * @return
     */
    override def toString: String = {
      var res = ""
      world(new Random).foreach(
        (row : Seq[Cell]) => {
          row.foreach(
            (c : Cell) => {res = res +c.population+" | "}
          )
          res = res + "\n"
        }
      )
      res
    }


}
