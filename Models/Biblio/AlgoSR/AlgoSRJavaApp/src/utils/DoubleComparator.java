/**
 * 
 */
package utils;

import java.util.Comparator;

/**
 * @author Raimbault Juste <br/> <a href="mailto:juste.raimbault@polytechnique.edu">juste.raimbault@polytechnique.edu</a>
 *
 */
public class DoubleComparator implements Comparator<Double> {

	/* (non-Javadoc)
	 * @see java.util.Comparator#compare(java.lang.Object, java.lang.Object)
	 */
	@Override
	public int compare(Double d1, Double d2) {
		if(d1.doubleValue()<d2.doubleValue()){return 1;}else{return 0;}
	}

}
