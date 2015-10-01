package density

import java.io.{ File, FileWriter }

import scala.util.Random

trait Generator {

  def size: Int

  def world(implicit rng: Random): Seq[Seq[Cell]]

  //def temp_file: String
  def export_file: File

  /**
   * computes config and exports it
   */
  def export(rng: Random): Unit = {
    val w = world(rng)
    val writer: FileWriter = new FileWriter(export_file)
    w.foreach(
      row => {
        writer.write(row.map { c => c.population }.mkString(";") + "\n");
      }
    )
    writer.close()
  }

  /**
   * Exports grid already computed.
   * (needed not to compute the grid 2 times)
   *
   * @param w : world
   */
  def export_static(w: Seq[Seq[Cell]], f: File): Unit = {
    val writer: FileWriter = new FileWriter(f)
    w.foreach(
      row => {
        writer.write(row.map { c => c.population }.mkString(";") + "\n");
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
      (row: Seq[Cell]) => {
        row.foreach(
          (c: Cell) => { res = res + c.population + " | " }
        )
        res = res + "\n"
      }
    )
    res
  }

}
