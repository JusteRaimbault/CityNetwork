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

    //for (t <- 0 to feedbackDistancesMatrix.getColumnDimension() - 1) { print(feedbackDistancesMatrix.get(0, t) + " ; ") }

  }

  /**
   *  Run the model
   */
  def run(growthRate: Double, gravityWeight: Double, gravityGamma: Double, gravityDecay: Double, feedbackWeight: Double, feedbackGamma: Double, feedbackDecay: Double): Matrix = {
    val n = populationMatrix.getRowDimension()
    val p = populationMatrix.getColumnDimension()
    var res = new Matrix(n, p)
    res.setMatrix(0, n - 1, 0, 0, populationMatrix.getMatrix(0, n - 1, 0, 0))

    //println("mean feedback mat : " + feedbackDistancesMatrix.getArray().flatten.sum / (feedbackDistancesMatrix.getRowDimension() * feedbackDistancesMatrix.getColumnDimension()))

    //println(distancesMatrix.get(2, 3))
    // mutate potential distances matrices with exp and constants
    // in place mutation DOES NOT WORK
    distancesMatrix = new Matrix(distancesMatrix.getArray().map { _.map { d => Math.exp(-d / gravityDecay) } })
    feedbackDistancesMatrix = new Matrix(feedbackDistancesMatrix.getArray().map { _.map { d => Math.exp(-d / feedbackDecay) } })

    //println("mean dist mat : " + distancesMatrix.getArray().flatten.sum / (distancesMatrix.getRowDimension() * distancesMatrix.getColumnDimension()))
    //println("mean feedback mat : " + feedbackDistancesMatrix.getArray().flatten.sum / (feedbackDistancesMatrix.getRowDimension() * feedbackDistancesMatrix.getColumnDimension()))

    for (t <- 1 to p - 1) {
      val prevpop = res.getMatrix(0, n - 1, t - 1, t - 1).copy()
      val totalpop = prevpop.getArray().flatten.sum
      var diagpops = diag(prevpop).times(1 / totalpop)
      var diagpopsFeedback = diagpops.times((new Matrix(n, n, 1)).times(diagpops))
      diagpops = new Matrix(diagpops.getArray().map { _.map { Math.pow(_, gravityGamma) } })
      //println("mean norm pop : " + diagpops.getArray().flatten.sum / (n * n))
      diagpopsFeedback = new Matrix(diagpopsFeedback.getArray().map { _.map { Math.pow(_, feedbackGamma) } })
      val potsgravity = diagpops.times(distancesMatrix).times(diagpops)
      val potsfeedback = feedbackDistancesMatrix.times(flattenPot(diagpopsFeedback))
      setDiag(potsgravity, 0); //setDiag(potsfeedback, 0)
      val meanpotgravity = potsgravity.getArray().flatten.sum / (n * n)
      val meanpotfeedback = potsfeedback.getArray().flatten.sum / n
      //println("mean pot gravity : " + meanpotgravity)
      //println("mean pot feedback : " + meanpotfeedback)
      //val flatpot = flattenPot(potsfeedback)

      res.setMatrix(0, n - 1, t, t,
        prevpop.arrayTimes(potsgravity.times(new Matrix(n, 1, 1)).times(gravityWeight / (n * meanpotgravity)).plus(new Matrix(n, 1, 1 + growthRate)).plus(
          potsfeedback.times(2 * feedbackWeight / (n * (n - 1) * meanpotfeedback))
        ))
      )

    }

    return res
  }

  def mselog(m: Matrix): Double = {
    val logres = new Matrix(m.getArray().map { _.map { d => Math.log(d) } })
    val logreal = new Matrix(populationMatrix.getArray().map { _.map { d => Math.log(d) } })
    val sqdiff = logres.minus(logreal).arrayTimes(logres.minus(logreal))
    return sqdiff.getArray().flatten.sum
  }

  def logmse(m: Matrix): Double = {
    val sqdiff = m.minus(populationMatrix).arrayTimes(m.minus(populationMatrix))
    return Math.log(sqdiff.getArray().flatten.sum)
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
      if (currentLine != null) res = res :+ (currentLine.split(",").map { s => s.toDouble }) //+: res
    }
    new Matrix(res.toArray)
  }

}
