package interaction

import scala.util.Random

trait Model {

  def run(implicit rng: Random): Double

}
