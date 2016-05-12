package interaction

import java.io.{ File, BufferedReader, FileReader }
import scala.util.Random
import Jama.Matrix

trait InteractionModel extends Model {

  // parameters
  def growthRate: Double
  def gravityWeight: Double
  def gravityGamma: Double
  def gravityDecay: Double
  def feedbackWeight: Double
  def feedbackGamma: Double
  def feedbackDecay: Double

  // config files
  def populations: File = null
  def distances: File = null
  def feedbackDistances: File = null

  //var distancesMatrix: Matrix = null
  //var feedbackDistancesMatrix: Matrix = null

  // setup matrices
  def setup() = {

  }

  /**
   *  Run the model
   */
  def run(implicit rng: Random): Double = {
    return 0
  }

  def logmse() = {
    0
  }

  /**
   * Utils
   */

  def parseMatrixFile(f: File) = {
    val reader = new BufferedReader(new FileReader(f))
    var currentLine = reader.readLine()
    var res: List[Array[Double]] = List()
    while (currentLine != null) {
      //res = res + ({ 0; 0 }) //(currentLine.split(",").map { s => s.toDouble })
      println(currentLine.split(",").map { s => s.toDouble })
      currentLine = reader.readLine()
    }
    //new Matrix(res.toArray)
  }

}
