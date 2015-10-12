/**
 * 
 */
package utils;

/**
 * @author Raimbault Juste <br/> <a href="mailto:juste.raimbault@polytechnique.edu">juste.raimbault@polytechnique.edu</a>
 *
 */
public class StringUtils {
	
	
	/**
	 * Delete all non character or digits characters in string.
	 * 
	 * @param s
	 * @return
	 */
	public static String deleteSpecialCharacters(String s){
		return s.replaceAll("[^\\p{L}\\p{Nd}]+", " ");
	}
	
}
