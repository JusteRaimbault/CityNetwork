package synthetic.density.generator

import synthetic.density.Cell

import scala.util.Random


trait PrefAttDiffusionGenerator extends Generator {

  /** sum of all capacities */
  def totalPopulation : Double

  /** diffusion parameters */
  def diffusion : Double
  def diffusionSteps : Int

  /** Growth rate */
  def growthRate : Int

  /** Preferential attachment parameter */
  def alphaAtt : Double




  /**
   *
   * @param rng
   * @return
   */
  def world(implicit rng: Random) = {
    var arrayVals = Array.fill[Cell](size, size){new Cell(0)}
    var population :Double = 0

    while(population < totalPopulation) {

      // add new population following pref att rule
      if(population==0){
        //choose random patch
        for(_<- 1 to growthRate){val i = rng.nextInt(size);val j = rng.nextInt(size) ; arrayVals(i)(j).population =  arrayVals(i)(j).population + 1 }
      } else{
        val oldPop = arrayVals.clone()
        val ptot = oldPop.flatten.map((c:Cell)=>math.pow(c.population / population , alphaAtt)).sum

        for(_<- 1 to growthRate){
          var s = 0.0 ; val r = rng.nextDouble() ; var i =0;var j =0
          while(s<r){s=s+(math.pow(oldPop(i)(j).population/population,alphaAtt)/ptot);j=j+1;if(j==size){j=0;i=i+1}}
          if(j==0){j=size-1;i = i - 1}else{j=j-1};
          arrayVals(i)(j).population = arrayVals(i)(j).population + 1
        }
      }

      // diffuse
      for (_ <- 1 to diffusionSteps) {
        arrayVals = diffuse(arrayVals, diffusion)
      }

      // update total population
      population = arrayVals.flatten.map(_.population).sum

    }

    Seq.tabulate(size,size){(i:Int,j:Int)=>new Cell(arrayVals(i)(j).population) }


  }






  /**
   * Diffuse to neighbors proportion alpha of capacities
   * @param a
   */
  def diffuse(a : Array[Array[Cell]],alpha : Double): Array[Array[Cell]] = {
    val newVals = a.clone()
    for (i <- 0 to size - 1; j <- 0 to size - 1) {
      if(i>=1){newVals(i-1)(j).population = newVals(i-1)(j).population + (alpha / 8)*a(i)(j).population ; newVals(i)(j).population = newVals(i)(j).population  - (alpha / 8)*a(i)(j).population }
      if(i<size-1){newVals(i+1)(j).population = newVals(i+1)(j).population + (alpha / 8)*a(i)(j).population ; newVals(i)(j).population = newVals(i)(j).population  - (alpha / 8)*a(i)(j).population }
      if(j>=1){newVals(i)(j-1).population = newVals(i)(j-1).population + (alpha / 8)*a(i)(j).population ; newVals(i)(j).population = newVals(i)(j).population  - (alpha / 8)*a(i)(j).population }
      if(j<size-1){newVals(i)(j+1).population = newVals(i)(j+1).population + (alpha / 8)*a(i)(j).population ; newVals(i)(j).population = newVals(i)(j).population  - (alpha / 8)*a(i)(j).population }
      if(i>=1&&j>=1){newVals(i-1)(j-1).population = newVals(i-1)(j-1).population + (alpha / 8)*a(i)(j).population ; newVals(i)(j).population = newVals(i)(j).population  - (alpha / 8)*a(i)(j).population }
      if(i>=1&&j<size-1){newVals(i-1)(j+1).population = newVals(i-1)(j+1).population + (alpha / 8)*a(i)(j).population ; newVals(i)(j).population = newVals(i)(j).population  - (alpha / 8)*a(i)(j).population }
      if(i<size-1&&j>=1){newVals(i+1)(j-1).population = newVals(i+1)(j-1).population + (alpha / 8)*a(i)(j).population ; newVals(i)(j).population = newVals(i)(j).population  - (alpha / 8)*a(i)(j).population }
      if(i<size-1&&j<size-1){newVals(i+1)(j+1).population = newVals(i+1)(j+1).population + (alpha / 8)*a(i)(j).population ; newVals(i)(j).population = newVals(i)(j).population  - (alpha / 8)*a(i)(j).population }
    }
    newVals
  }



}
