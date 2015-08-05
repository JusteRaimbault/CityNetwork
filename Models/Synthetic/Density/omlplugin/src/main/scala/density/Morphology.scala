package density

import org.apache.commons.math3.stat.regression.SimpleRegression

import scala.math._

object Morphology {

  /**
   * Rank-size slope
   *
   * @param matrix
   * @return
   */
  def slope(matrix: Seq[Seq[Cell]]) = {
    def distribution = matrix.flatten.map(_.population).sorted(Ordering.Double.reverse).filter(_ > 0)
    def distributionLog = distribution.zipWithIndex.map { case (q, i) => Array(log(i + 1), log(q)) }.toArray
    val simpleRegression = new SimpleRegression(true)
    simpleRegression.addData(distributionLog)
    (simpleRegression.getSlope(), simpleRegression.getRSquare())
  }

  /**
   * Mean distance between individuals.
   *
   * @param matrix
   * @return
   */
  def distanceMean(matrix: Seq[Seq[Cell]]) = {

    def totalQuantity = matrix.flatten.map(_.population).sum

    def numerator =
      (for {
        (c1, p1) <- zipWithPosition(matrix)
        (c2, p2) <- zipWithPosition(matrix)
      } yield distance(p1, p2) * c1.population * c2.population).sum

    def normalisation = matrix.length / math.sqrt(math.Pi)

    (numerator / (totalQuantity * (totalQuantity))) / normalisation
  }

  /**
   * Distance between two positions.
   *
   * @param p1
   * @param p2
   * @return
   */
  def distance(p1: (Int, Int), p2: (Int, Int)): Double = {
    val (i1, j1) = p1
    val (i2, j2) = p2
    val a = i2 - i1
    val b = j2 - j1
    math.sqrt(a * a + b * b)
  }

  def zipWithPosition(m: Seq[Seq[Cell]]): Seq[(Cell, (Int, Int))] = {
    for {
      (row, i) <- m.zipWithIndex
      (content, j) <- row.zipWithIndex
    } yield content -> (i, j)
  }

  /**
   * Entropy of population distribution.
   *
   * @param matrix
   * @return
   */
  def entropy(matrix: Seq[Seq[Cell]]) = {
    val totalQuantity = matrix.flatten.map(_.population).sum
    assert(totalQuantity > 0)
    matrix.flatten.map {
      p =>
        val quantityRatio = p.population / totalQuantity
        val localEntropy = if (quantityRatio == 0.0) 0.0 else quantityRatio * math.log(quantityRatio)
        //assert(!localEntropy.isNaN, s"${quantityRatio} ${math.log(quantityRatio)}")
        localEntropy
    }.sum * (-1 / math.log(matrix.flatten.length))
  }

  /**
   * Moran Index.
   *  (in O(N4))
   *
   * @param matrix
   * @return
   */
  def moran(matrix: Seq[Seq[Cell]]): Double = {
    def flatCells = matrix.flatten
    val totalPop = flatCells.map(_.population).sum
    val averagePop = totalPop / matrix.flatten.length

    def vals =
      for {
        (c1, p1) <- zipWithPosition(matrix)
        (c2, p2) <- zipWithPosition(matrix)
      } yield (decay(p1, p2) * (c1.population - averagePop) * (c2.population - averagePop), decay(p1, p2))

    def numerator: Double = vals.map { case (n, _) => n }.sum
    def totalWeight: Double = vals.map { case (_, w) => w }.sum

    def denominator =
      flatCells.map {
        cell =>
          if (cell.population == 0) 0
          else math.pow(cell.population - averagePop.toDouble, 2)
      }.sum

    if (denominator == 0) 0
    else (matrix.flatten.length / totalWeight) * (numerator / denominator)
  }

  /**
   * Decay distance for Moran.
   *
   * @param p1
   * @param p2
   * @return
   */
  def decay(p1: (Int, Int), p2: (Int, Int)) = {
    if (p1 == p2) 0.0
    else 1 / distance(p1, p2)
  }


  /**
   * Moran index using fast convolution.
   *
   * @param matrix
   * @return
   */
  def moran_convol(matrix: Seq[Seq[Cell]]): Double = {
    0.0
  }

  /**
   * Mean distance using fast convolution.
   *
   * @param matrix
   * @return
   */
  def distance_convol(matrix: Seq[Seq[Cell]]): Double = {

    val flatMat = zipWithPosition(matrix)
    val p = matrix(0).length
    val n = matrix.length

    //new FastFourierTransformer(DftNormalization.STANDARD).transform(matrix.flatten.toArray.map{c=>c.population},TransformType.FORWARD)

    0.0
  }
}
