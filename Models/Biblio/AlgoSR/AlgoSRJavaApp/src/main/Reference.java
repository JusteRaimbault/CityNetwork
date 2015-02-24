/**
 * 
 */
package main;

import java.util.HashMap;
import java.util.HashSet;

/**
 * Class representing references.
 * 
 * @author Raimbault Juste <br/> <a href="mailto:juste.raimbault@polytechnique.edu">juste.raimbault@polytechnique.edu</a>
 *
 */
public class Reference {
	
	/**
	 * Static set of all references.
	 */
	public static final HashMap<Reference,Reference> references = new HashMap<Reference,Reference>();
	
	
	/**
	 * Dynamic fields
	 * 
	 */
	
	/**
	 * UUID retrieved from mendeley.
	 */
	public String id;
	
	/**
	 * Title
	 */
	public String title;
	
	/**
	 * Authors
	 * Useful ?
	 */
	public HashSet<String> authors;
	
	/**
	 * Abstract. (abstract is a java keyword)
	 */
	public String resume;
	
	/**
	 * Keywords
	 */
	public HashSet<String> keywords;
	
	/**
	 * Constructor
	 * 
	 * Authors and keywords have to be populated after (more simple ?)
	 * 
	 * @param t title
	 * @param r abstract
	 */
	public Reference(String i,String t,String r){
		id=i;
		title=t;resume=r;
		authors = new HashSet<String>();keywords = new HashSet<String>();
	}
	
	/**
	 * Ghost constructor
	 */
	public Reference(String i){
		id=i;
	}
	
	/**
	 * Static constructor used to construct objects only one time.
	 * 
	 * @param i
	 * @return
	 */
	public static Reference construct(String i,String t,String r){
		Reference ref = new Reference(i);
		if(references.containsKey(ref)){
			return references.get(ref);
		}else{
			Reference newRef = new Reference(i,t,r);
			//put in map
			references.put(newRef, newRef);
			return newRef;
		}
	}
	
	/**
	 * Override hashcode to take account of only ID.
	 */
	public int hashCode(){
		return this.id.hashCode();
	}
	
	/**
	 * Override to string
	 */
	public String toString(){
		return "Ref "+id+" - "+title;
	}
	
}
