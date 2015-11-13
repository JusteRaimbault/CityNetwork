/**
 * 
 */
package main.reference;

import java.util.HashMap;
import java.util.HashSet;

import mendeley.MendeleyAPI;

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
	 * Google scholar UUID (cluster)
	 */
	public String scholarID;
	
	/**
	 * Title
	 */
	public Title title;
	
	/**
	 * Authors
	 * Useful ?
	 */
	public HashSet<String> authors;
	
	/**
	 * Abstract. (abstract is a java keyword)
	 */
	public Abstract resume;
	
	/**
	 * Keywords
	 */
	public HashSet<String> keywords;
	
	/**
	 * publication year
	 */
	public String year;

	/**
	 * Refs citing this ref
	 */
	public HashSet<Reference> citing;
	
	/**
	 * Bibliography
	 */
	public Bibliography biblio;
	
	
	/**
	 * Free attributes, stored under the form <key,value>
	 */
	public HashMap<String,String> attributes;
	
	
	
	/**
	 * Constructor
	 * 
	 * Authors and keywords have to be populated after (more simple ?)
	 * 
	 * @param t title
	 * @param r abstract
	 */
	public Reference(String i,Title t,Abstract r,String y,String schID){
		id=i;
		title=t;
		resume=r;
		year=y;scholarID=schID;
		authors = new HashSet<String>();
		keywords = new HashSet<String>();
		citing=new HashSet<Reference>();
		biblio=new Bibliography(new HashSet<Reference>());
		attributes = new HashMap<String,String>();
	}
	
	/**
	 * Ghost constructor
	 */
	public Reference(String t){
		title=new Title(t);
	}
	
	/**
	 * DEPRECATED
	 * 
	 * Specific scholar constructor, returns 'ghost' references.
	 * 
	 * --DEP
	 * --Note that if full fill option is activated, will also fill global ref table as a catalog request is done.
	 * --Else this constructor retrieves "ghost" references, in the sense of not hard-coded in static table (hash-counsed reference)
	 * 
	 * 
	 * @param t title
	 * @param schid scholar id as String
	 * 
	 * -- DEPRECATED @param retrieveAllInfos : option to request mendeley to have a full ref. - activated or not depending on performance wanted
	 * -- ARCHITECTURAL ISSUE --
	 */
	public Reference(String t,String schid){//,boolean retrieveAllInfos){
		title=new Title(t);
		
		/*
		if(retrieveAllInfos){
			HashSet<Reference> mendeleyReq = MendeleyAPI.catalogRequest(t.replace(" ", "+"), 1);
			Reference mendRef = (Reference) mendeleyReq.toArray()[0];
			id=mendRef.id;
		}
		*/
		
		scholarID=schid;
		
	}
	
	
	
	/**
	 * Static constructor used to construct objects only one time.
	 * 
	 * @param i : id
	 * @param t : title
	 * @param r : resume
	 * @param y : year
	 * @param schID : scholar ID
	 * @return the Reference object, ensuring overall unicity through HashConsing
	 */
	public static Reference construct(String i,Title t,Abstract r,String y,String schID){
		Reference ref = new Reference(t.title);
		if(references.containsKey(ref)){
			Reference existingRef = references.get(ref);
			//override existing records if not empty fields provided --> the function can be used as a table updater --
			//ref in table has thus always the latest requested values. NO ?		
			if(i.length()>0){existingRef.id=i;}
			if(r.resume.length()>0){existingRef.resume=r;}
			if(y.length()>0){existingRef.year=y;}
			if(schID.length()>0){existingRef.scholarID=schID;}
			
			return existingRef;
		}else{
			Reference newRef = new Reference(i,t,r,y,schID);
			//put in map
			references.put(newRef, newRef);
			return newRef;
		}
	}
	
	/**
	 * Override hashcode to take account of only ID.
	 */
	public int hashCode(){
		/**
		 * dirty, has to go through all table to find through Levenstein close ref
		 * that way hashconsing may be (is surely) suboptimal -> in O(n^2)
		 * 
		 * If scholarID is set, use it -> O(n) thanks to O(1) for hashcode computation
		 */
		
		if(scholarID!=null||scholarID!=""){
			return scholarID.hashCode();
		}else{
			for(Reference r:references.keySet()){if(r.equals(this)){return r.title.title.hashCode();}}
			return this.title.hashCode();
		}
	}
	
	/**
	 * Idem with equals
	 */
	public boolean equals(Object o){
		if(!(o instanceof Reference)){return false;}
		else{
			Reference r = (Reference) o;
			if((r.scholarID!=null||r.scholarID!="")&&(scholarID!=null||scholarID!="")){return r.scholarID.equals(scholarID);}
			else{
				return (StringUtils.getLevenshteinDistance(StringUtils.lowerCase(r.title.title),StringUtils.lowerCase(title.title))<4);			
			}
		}
	}
	
	
	/**
	 * Override to string
	 */
	public String toString(){
		return "Ref "+id+" - schID : "+scholarID+" - t : "+title+" - year : "+year;
	}
	
}
