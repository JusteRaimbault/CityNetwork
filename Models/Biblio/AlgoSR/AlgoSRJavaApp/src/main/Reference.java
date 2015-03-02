/**
 * 
 */
package main;

import java.util.HashMap;
import java.util.HashSet;

import org.apache.commons.lang3.StringUtils;

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
	 * publication year
	 */
	public String year;

	
	/**
	 * Constructor
	 * 
	 * Authors and keywords have to be populated after (more simple ?)
	 * 
	 * @param t title
	 * @param r abstract
	 */
	public Reference(String i,String t,String r,String y){
		id=i;
		title=t;resume=r;year=y;
		authors = new HashSet<String>();keywords = new HashSet<String>();
	}
	
	/**
	 * Ghost constructor
	 */
	public Reference(String t){
		title=t;
	}
	
	/**
	 * Static constructor used to construct objects only one time.
	 * 
	 * @param i
	 * @return
	 */
	public static Reference construct(String i,String t,String r,String y){
		Reference ref = new Reference(t);
		if(references.containsKey(ref)){
			return references.get(ref);
		}else{
			Reference newRef = new Reference(i,t,r,y);
			//put in map
			references.put(newRef, newRef);
			return newRef;
		}
	}
	
	/**
	 * Override hashcode to take account of only ID.
	 */
	public int hashCode(){
		//dirty, has to go through all table to find through Levenstein close ref
		// that way hashconsing may be (is surely) suboptimal
		// -> in O(n^2)
		for(Reference r:references.keySet()){if(r.equals(this)){return r.title.hashCode();}}
		return this.title.hashCode();
	}
	
	/**
	 * Idem with equals
	 */
	public boolean equals(Object o){
		return (o instanceof Reference)&&(StringUtils.getLevenshteinDistance(StringUtils.lowerCase(((Reference)o).title),StringUtils.lowerCase(this.title))<4);
	}
	
	
	/**
	 * Override to string
	 */
	public String toString(){
		return "Ref "+id+" - "+title;
	}
	
}
