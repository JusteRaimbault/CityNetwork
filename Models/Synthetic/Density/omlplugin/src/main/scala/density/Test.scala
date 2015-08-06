package density

import org.apache.commons.math3.complex._
import org.apache.commons.math3.transform._
import org.apache.commons.math3.util.MathArrays

import scala.util.Random

object Test extends App {

  def testFFT() = {
    val rng = new Random
    // create large array
    val x = Array.fill(1024) { rng.nextDouble() }
    val y = Array.fill(512) { rng.nextDouble() }

    // direct convolution
    var t = System.currentTimeMillis()
    val convdir = MathArrays.convolve(x, y).splitAt(x.length)._1
    //println(convdir.mkString(";"))
    //println(convdir.splitAt(x.length)._1.mkString(";"))
    println("Ellapsed : " + (System.currentTimeMillis() - t) + " ms\n")

    // using fft
    t = System.currentTimeMillis()
    val tr = new FastFourierTransformer(DftNormalization.STANDARD)
    val ftx = tr.transform(x.padTo(Math.max(x.length, y.length) / 2, 0.0).reverse.padTo(Math.max(x.length, y.length), 0.0).reverse, TransformType.FORWARD)
    val fty = tr.transform(y.padTo(Math.max(y.length, x.length) / 2, 0.0).reverse.padTo(Math.max(y.length, x.length), 0.0).reverse, TransformType.FORWARD)
    val real = MathArrays.ebeSubtract(MathArrays.ebeMultiply(ftx.map { z => z.getReal }, fty.map { z => z.getReal }), MathArrays.ebeMultiply(ftx.map { z => z.getImaginary }, fty.map { z => z.getImaginary }))
    val im = MathArrays.ebeAdd(MathArrays.ebeMultiply(ftx.map { z => z.getReal }, fty.map { z => z.getImaginary }), MathArrays.ebeMultiply(ftx.map { z => z.getImaginary }, fty.map { z => z.getReal }))
    val conv = tr.transform(Array.tabulate(real.length) { i => new Complex(real(i), im(i)) }, TransformType.INVERSE).map { z => z.getReal }.splitAt(y.length)._2

    //println(conv.map{z=>z.getReal}.splitAt(y.length)._2.mkString(";"))
    println("Ellapsed : " + (System.currentTimeMillis() - t) + " ms")

    println(MathArrays.ebeSubtract(convdir, conv).sum)

  }

  def fastConvolution(x: Array[Double], k: Array[Double]): Array[Double] = {
    val tr = new FastFourierTransformer(DftNormalization.STANDARD)
    val ftx = tr.transform(x.padTo(k.length, 0.0).reverse.padTo(2 * k.length, 0.0).reverse, TransformType.FORWARD)
    val ftk = tr.transform(k, TransformType.FORWARD)
    val real = MathArrays.ebeSubtract(MathArrays.ebeMultiply(ftx.map { z => z.getReal }, ftk.map { z => z.getReal }), MathArrays.ebeMultiply(ftx.map { z => z.getImaginary }, ftk.map { z => z.getImaginary }))
    val im = MathArrays.ebeAdd(MathArrays.ebeMultiply(ftx.map { z => z.getReal }, ftk.map { z => z.getImaginary }), MathArrays.ebeMultiply(ftx.map { z => z.getImaginary }, ftk.map { z => z.getReal }))
    tr.transform(Array.tabulate(real.length) { i => new Complex(real(i), im(i)) }, TransformType.INVERSE).map { z => z.getReal }.splitAt(k.length)._2
  }

  /**
   * Fast convolution between input 2d data and 2d kernel.
   *
   * @param x input data
   * @param k kernel
   * @return convolution (FFT)
   */
  def fastConvolution2D(x: Array[Array[Double]], k: Array[Array[Double]]): Array[Array[Double]] = {

    //must first extend k to a square array which width is a power of 2

    val ksize = Math.pow(2, Math.ceil(Math.log(Math.max(k.length, k(0).length)) / Math.log(2))).toInt

    val paddedX = x.map { row => row.padTo(((ksize + x(0).length) / 2), 0.0).reverse.padTo(ksize.toInt, 0.0) }.padTo(((ksize + x.length) / 2), Array.fill(ksize) { 0.0 }).reverse.padTo(ksize, Array.fill(ksize) { 0.0 }).reverse
    val paddedK = k.map { row => row.padTo(((ksize + k(0).length) / 2), 0.0).reverse.padTo(ksize.toInt, 0.0) }.padTo(((ksize + k.length) / 2), Array.fill(ksize) { 0.0 }).reverse.padTo(ksize, Array.fill(ksize) { 0.0 }).reverse

    paddedX

  }

  def testDistanceMatrix(): Unit = {

    val m = Seq.tabulate(21, 21) { (i: Int, j: Int) => Math.sqrt((i - 10.0) * (i - 10.0) + (j - 10.0) * (j - 10.0)) }
    m.foreach(row => println(row.mkString(";")))
  }

  def distanceMatrix(n: Int): Array[Array[Double]] = {
    Array.tabulate(n, n) { (i, j) => Math.sqrt((i - n / 2) * (i - n / 2) + (j - n / 2) * (j - n / 2)) }
  }

  def testConvol(): Unit = {
    val k = Array.tabulate(8, 8) { (i: Int, j: Int) => Math.sqrt((i - 8.0) * (i - 8.0) + (j - 8.0) * (j - 8.0)) }
    val x = Array.fill(4, 4) { 1.0 }
    //println(k.flatten.length)

    fastConvolution(x.flatten, k.flatten).sliding(10).foreach(row => println(row.mkString(";")))

    //fastConvolution2D(x,k).foreach(row=>println(row.mkString(";")))
  }

  def testConvolKernel(): Unit = {
    val rng = new Random
    val x = Array.fill(15) { 1.0 }
    val k = Array.fill(15) { 1.0 }
    println("x : " + x.mkString(" "))
    println("Direct   : " + (Convolution.directConvol(x, k).splitAt(k.length / 2)._2.splitAt(x.length)._1).mkString(" "))
    println("FFT      : " + Convolution.convolution(x, k).map { _.round }.mkString(" "))
    println("Built-In : " + (MathArrays.convolve(x, k).splitAt(k.length / 2)._2.splitAt(x.length)._1).mkString(" "))
  }

  def testConvol2D(): Unit = {
    //val x = Array.fill(4,4){1.0}

    val x = Array.tabulate(5, 5) { (i, j) => (i + j).toDouble }
    val k = Array.fill(3, 3) { 1.0 }
    val conv = Convolution.convolution2D(x, k)
    Morphology.printMat(conv)
  }

  def testDistanceMean(n: Int) = {
    val rng = new Random
    val dm = distanceMatrix(2 * n - 1)
    //val pop = Array.fill(n,n){rng.nextInt(10).toDouble}
    var k = 0
    //val pop =  Array.tabulate(n,n){(i,j)=>(i+j/2).toDouble}
    val pop = Array.fill(n, n) { k = k + 1; k.toDouble }
    val totPop = pop.flatten.sum
    val conv = Convolution.convolution2D(pop, dm)
    //Morphology.printMat(dm)
    Morphology.printMat(pop)
    Morphology.printMat(conv)
    //println(conv.flatten.mkString(" "))
    //println(pop.flatten.mkString(" "))
    //println(MathArrays.ebeMultiply(pop.flatten,conv.flatten).mkString(" "))
    val res = MathArrays.ebeMultiply(pop.flatten, conv.flatten).sliding(pop(0).length, pop.length).toArray
    Morphology.printMat(res)
    println(res.flatten.sum * math.sqrt(math.Pi) / (pop.flatten.length * totPop * totPop))
    println()
  }

  //testFFT()

  //testDistanceMatrix()

  //testConvol()

  //testConvolKernel()

  //shitty tests
  //println(Array.tabulate(10){i=>i}.splitAt(3)._2.mkString(" "))
  //println(pow(2.0,ceil(log(9.0)/log(2.0))))

  //testConvol2D()

  testDistanceMean(3)

}
