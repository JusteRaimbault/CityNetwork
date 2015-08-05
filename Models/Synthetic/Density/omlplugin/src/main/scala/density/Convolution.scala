package density

import org.apache.commons.math3.complex.Complex
import org.apache.commons.math3.transform.{TransformType, DftNormalization, FastFourierTransformer}
import org.apache.commons.math3.util.MathArrays

import scala.math._

object Convolution {

  /**
   * Generic convol for double Arrays (in O(nlog(n)), using FFT)
   *
   * @param x
   * @param k centered kernel
   * @return y = x*k with y_i = \sum_{j=1}{|K|}{x_{i-j-|K|/2}*k_j}
   */
  def convolution(x:Array[Double],k:Array[Double]): Array[Double] = {
    val xl = pow(2.0,ceil(log(x.length)/log(2.0))+1)
    val xp = x.padTo(x.length+(xl.toInt - x.length)/2, 0.0).reverse.padTo(xl.toInt, 0.0).reverse
    val kp = k.padTo(k.length+(xl.toInt - k.length)/2, 0.0).reverse.padTo(xl.toInt, 0.0).reverse
    val tr = new FastFourierTransformer(DftNormalization.STANDARD)
    val ftx = tr.transform(xp, TransformType.FORWARD)
    val ftk = tr.transform(kp, TransformType.FORWARD)
    val real = MathArrays.ebeSubtract(MathArrays.ebeMultiply(ftx.map { z => z.getReal }, ftk.map { z => z.getReal }), MathArrays.ebeMultiply(ftx.map { z => z.getImaginary }, ftk.map { z => z.getImaginary }))
    val im = MathArrays.ebeAdd(MathArrays.ebeMultiply(ftx.map { z => z.getReal }, ftk.map { z => z.getImaginary }), MathArrays.ebeMultiply(ftx.map { z => z.getImaginary }, ftk.map { z => z.getReal }))
    val trinv = tr.transform(Array.tabulate(real.length) { i => new Complex(real(i), im(i)) }, TransformType.INVERSE).map { z => z.getReal }
    trinv.splitAt(trinv.length - x.length / 2)._2 ++ trinv.splitAt(x.length - x.length / 2)._1
  }

  /**
   * Square convol (for tests)
   *
   * @param x
   * @param k
   * @return
   */
  def directConvol(x:Array[Double],k:Array[Double]):Array[Double] = {
    val kl = k.length
    val xpadded = x.padTo(x.length+kl,0.0).reverse.padTo(x.length+2*kl,0.0).reverse
    Array.tabulate(x.length+k.length){i=>MathArrays.ebeMultiply(k.reverse,xpadded.splitAt(i+1)._2.splitAt(k.length)._1).sum}
  }

  /**
   *  2D convolution
   *  Using bijection [|1,N|]2 ~ [|1,N|]
   *
   * @param x
   * @param k
   */
  def convolution2D(x:Array[Array[Double]],k:Array[Array[Double]]): Array[Array[Double]] = {
    Array.fill(x.length,x(0).length){0}
  }

}
