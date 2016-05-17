package interaction

import java.io.{ File, BufferedReader, FileReader }
import scala.util.Random
import Jama.Matrix

object InteractionModel {

  // parameters
  /*def growthRate: Double
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

*/
  var populationMatrix: Matrix = null
  var distancesMatrix: Matrix = null
  var feedbackDistancesMatrix: Matrix = null

  // setup matrices
  def setup(populations: File, distances: File, feedbackDistances: File) = {
    populationMatrix = parseMatrixFile(populations)
    distancesMatrix = parseMatrixFile(distances)
    feedbackDistancesMatrix = parseMatrixFile(feedbackDistances)
  }

  /**
   *  Run the model
   */
  def run(growthRate: Double, gravityWeight: Double, gravityGamma: Double, gravityDecay: Double, feedbackWeight: Double, feedbackGamma: Double, feedbackDecay: Double): Matrix = {
    val n = populationMatrix.getRowDimension()
    val p = populationMatrix.getColumnDimension()
    var res = new Matrix(n, p)
    res.setMatrix(0, n - 1, 0, 0, populationMatrix.getMatrix(0, n - 1, 0, 0))

    println(distancesMatrix.get(2, 3))
    // mutate potential distances matrices with exp and constants
    distancesMatrix.getArray().map { _.map { d => Math.exp(-d / gravityDecay) * gravityWeight / n } }
    feedbackDistancesMatrix.getArray().map { _.map { d => Math.exp(-d / feedbackDecay) * 2 * feedbackWeight / (n * n - 1) } }

    println(distancesMatrix.get(2, 3))

    for (t <- 1 to p - 1) {
      val prevpop = res.getMatrix(0, n - 1, t - 1, t - 1).copy()
      val totalpop = prevpop.getArray().flatten.sum
      val diagpops = diag(prevpop).times(1 / totalpop)
      val diagpopsFeedback = diagpops.copy()
      diagpops.getArray().map { _.map { Math.pow(_, gravityGamma) } }
      diagpopsFeedback.getArray().map { _.map { Math.pow(_, feedbackGamma) } }
      val potsgravity = diagpops.times(distancesMatrix).times(diagpops)
      val potsfeedback = diagpops.times(distancesMatrix).times(diagpops)
      setDiag(potsgravity, 0); setDiag(potsfeedback, 0)
      val meanpotgravity = potsgravity.getArray().flatten.sum / (n * n)
      val meanpotfeedback = potsfeedback.getArray().flatten.sum / (n * n)
      //println(meanpotgravity)
      val flatpot = flattenPot(potsfeedback)

      res.setMatrix(0, n - 1, t, t,
        prevpop.arrayTimes(potsgravity.times(new Matrix(n, 1, 1)).times(1 / meanpotgravity).plus(new Matrix(n, 1, 1 + growthRate)).plus(
          feedbackDistancesMatrix.times(flatpot).times(1 / meanpotfeedback)
        ))
      )

    }

    return res
  }

  def logmse() = {
    0
  }

  /**
   * Utils
   */

  def diag(m: Matrix): Matrix = {
    val n = m.getRowDimension()
    val res = Matrix.identity(n, n)
    for (i <- 0 to n - 1) {
      res.set(i, i, m.get(i, 0))
    }
    return res
  }

  def setDiag(m: Matrix, s: Double): Unit = {
    val n = m.getRowDimension()
    for (i <- 0 to n - 1) {
      m.set(i, i, s)
    }
  }

  def flattenPot(m: Matrix): Matrix = {
    val n = m.getRowDimension()
    val res = new Matrix(n * (n - 1) / 2, 1)
    //println(res.getRowDimension)
    for (i <- 0 to n - 2) {
      //println("i :" + i)
      //println("range : " + ((i * (n - 1)) - (i * (i - 1) / 2)) + " ; " + ((i + 1) * (n - 1) - (i * (i + 1) / 2)))
      val col = m.getMatrix(i + 1, n - 1, i, i)
      //println(col.getRowDimension() + " ; " + col.getColumnDimension())
      //println((i + 1) * (n - 1) - (i * (i + 1) / 2) - (i * (n - 1)) - (i * (i - 1) / 2))
      res.setMatrix((i * (n - 1)) - (i * (i - 1) / 2), (i + 1) * (n - 1) - (i * (i + 1) / 2) - 1, 0, 0, col)
    }
    return res
  }

  def parseMatrixFile(f: File) = {
    val reader = new BufferedReader(new FileReader(f))
    var currentLine = reader.readLine()
    var res = List((currentLine.split(",").map { s => s.toDouble })) //= new List[Array[Double]] {}
    while (currentLine != null) {
      //res = res + ({ 0; 0 }) //(currentLine.split(",").map { s => s.toDouble })
      currentLine = reader.readLine()
      if (currentLine != null) res = (currentLine.split(",").map { s => s.toDouble }) +: res
    }
    new Matrix(res.toArray)
  }

}
