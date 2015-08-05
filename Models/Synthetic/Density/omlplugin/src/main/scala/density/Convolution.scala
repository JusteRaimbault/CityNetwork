package density


object Convolution {

  /**
   * Generic convol for double Arrays (in O(nlog(n)), using FFT)
   *
   * @param x
   * @param k
   * @return x*k (length of x)
   */
  def convolution(x:Array[Double],k:Array[Double]): Array[Double] = {

    Array.fill(x.length){0}
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
