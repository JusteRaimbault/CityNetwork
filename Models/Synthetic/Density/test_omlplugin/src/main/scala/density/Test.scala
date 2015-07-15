package density

import org.apache.commons.math3.complex._
import org.apache.commons.math3.util.MathArrays
import org.apache.commons.math3.transform._

import scala.util.Random

object Test extends App {


  def testFFT()={
    val rng = new Random
    // create large array
    val x = Array.fill(1048576){rng.nextDouble()}
    val y = Array.fill(1048576){rng.nextDouble()}

    // direct convolution
    var t = System.currentTimeMillis()
    val convdir = MathArrays.convolve(x,y).splitAt(x.length)._1
    //println(convdir.mkString(";"))
    //println(convdir.splitAt(x.length)._1.mkString(";"))
    println("Ellapsed : "+(System.currentTimeMillis()-t)+" ms\n")


    // using fft
    t = System.currentTimeMillis()
    val tr = new FastFourierTransformer(DftNormalization.STANDARD)
    val ftx=tr.transform(x.padTo(x.length+y.length/2,0.0).reverse.padTo(x.length+y.length,0.0).reverse,TransformType.FORWARD)
    val fty=tr.transform(y.padTo(y.length+x.length/2,0.0).reverse.padTo(y.length+x.length,0.0).reverse,TransformType.FORWARD)
    val real  = MathArrays.ebeSubtract(MathArrays.ebeMultiply(ftx.map{z=>z.getReal},fty.map{z=>z.getReal}),MathArrays.ebeMultiply(ftx.map{z=>z.getImaginary},fty.map{z=>z.getImaginary}))
    val im = MathArrays.ebeAdd(MathArrays.ebeMultiply(ftx.map{z=>z.getReal},fty.map{z=>z.getImaginary}),MathArrays.ebeMultiply(ftx.map{z=>z.getImaginary},fty.map{z=>z.getReal}))
    val conv = tr.transform(Array.tabulate(real.length){i=>new Complex(real(i),im(i))},TransformType.INVERSE).map{z=>z.getReal}.splitAt(y.length)._2

    //println(conv.map{z=>z.getReal}.splitAt(y.length)._2.mkString(";"))
    println("Ellapsed : "+(System.currentTimeMillis()-t)+" ms")

    println(MathArrays.ebeSubtract(convdir,conv).sum)

  }



  testFFT()

}
