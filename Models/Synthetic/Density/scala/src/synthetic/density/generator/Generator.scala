package synthetic.density.generator

import java.io.{File, FileWriter}

import synthetic.density.Cell

import scala.util.Random

trait Generator {

  def size : Int

  def world(implicit rng: Random): Seq[Seq[Cell]]

  /**
   * computes config and exports it
   */
  def export(rng:Random) : Unit = {
    val w = world(rng)
    val writer:FileWriter=new FileWriter(new File("../temp_pop.csv"))
    w.foreach(
       row => {
         //println(row.map{c=>c.population}.mkString(";"))
         writer.write(row.map{c=>c.population}.mkString(";")+"\n");
       }
    )
    writer.close()
  }


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
