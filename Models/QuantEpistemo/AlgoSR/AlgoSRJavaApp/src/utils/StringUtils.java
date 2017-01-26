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
		String res = s.replaceAll("[^\\p{L}\\p{Nd}]+", " ");
		if(res.startsWith(" ")){res=res.substring(1);}
		if(res.endsWith(" ")){res=res.substring(0, res.length()-1);}
		return res;
	}
	
}
