/**
 * 
 */
package main.reference;

/**
 * A Ghost Reference may be seen as an 'unverified' Reference, or of which the construction is unfinished.
 * Used to store ref infos without messing with hashconsing.
 * 
 * @author Raimbault Juste <br/> <a href="mailto:juste.raimbault@polytechnique.edu">juste.raimbault@polytechnique.edu</a>
 *
 */
public class GhostReference extends Reference {
	
	//public GhostReference(){}
	
	/**
	 * 
	 * 
	 * @param t
	 */
	public GhostReference(String t){
		super(t);
	}
	
	public GhostReference(String t,String y){
		super(t);
		year=y;
	}
	
}
