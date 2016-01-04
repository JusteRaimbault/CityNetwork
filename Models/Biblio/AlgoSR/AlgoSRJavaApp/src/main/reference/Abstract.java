/**
 * 
 */
package main.reference;

/**
 * @author Raimbault Juste <br/> <a href="mailto:juste.raimbault@polytechnique.edu">juste.raimbault@polytechnique.edu</a>
 *
 */
public class Abstract {
	
	public static final Abstract EMPTY = new Abstract("");
	
	public String resume;
	
	/**
	 * if translated
	 */
	public String en_resume;
	
	public Abstract(String r){
		if(r!=null){resume=r;}
	}
	
	public Abstract(String r,String e){resume=r;en_resume=e;}

	/**
	 * 
	 */
	public Abstract() {
		resume = "";en_resume="";
	}
	
}
