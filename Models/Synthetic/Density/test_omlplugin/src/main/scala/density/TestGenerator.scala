package density

import scala.util.Random

object TestGenerator extends App {

  def simpleTest= {
    val population = 100
    val diffusion = 0
    val diffusionsteps = 2
    val growthrate = 10
    val alphalocalization = 2.5

    val gen = new PADGeneratorLauncher
    gen.main(50, population, diffusion, diffusionsteps, growthrate, alphalocalization, 0)

    //("R -e persp(x=1:50,y=1:50,z=as.matrix(read.csv(\"tmp_pop.csv\",sep=\";\",header=FALSE)))")!
  }

  def print_static(w : Array[Array[Double]]):Unit = {
    w.foreach(
      row => {
        println(row.mkString(";"));
      }
    )
  }




  def monteCarlo={

    val size=50

    var tot = Array.fill[Double](50, 50) {0.0}

    for(k <- 1 to 50000) {
      println(k)
      val gen = new PrefAttDiffusionGenerator {
        override def size: Int = 50
        override def totalPopulation: Double = 300
        override def diffusion: Double = 0.2
        override def diffusionSteps: Int = 2
        override def growthRate: Double = 10
        override def alphaAtt: Double = 1.2
        override def temp_file: String = "tmp_pop.csv" //"tmp/temp_pop_" + UIR + ".csv"
      }

      // compute
      val world = gen.world(new Random)
      for(i<-0 to (size-1)){
        for(j<-0 to (size-1)){
          tot(i)(j)=tot(i)(j)+world(i)(j).population
        }
      }
    }

    val m = tot.flatten.sum/tot.flatten.length
    print_static(tot.map((a:Array[Double])=>a.map(_/m)))

  }

  simpleTest

  //monteCarlo

  // MONTE CARLO : validation of random pref Attachment.


}
