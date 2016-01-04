/**
 * 
 */
package main.reference;

import java.util.Collection;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Set;

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
		biblio=new Bibliography();
		attributes = new HashMap<String,String>();
	}
	
	/**
	 * Ghost constructor
	 */
	public Reference(String t){
		title=new Title(t);
	}
	
	/**
	 * Ghost constructor with ID.
	 * 
	 * @param t title
	 * @param schid scholar id as String
	 */
	public Reference(String t,String schid){
		title=new Title(t);
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
		Reference ref = new Reference(t.title,schID);
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
	
	public static Reference construct(String schID){
		return construct("",new Title(""),new Abstract(),"",schID);
	}
	
	
	/**
	 * Construst from ghost.
	 */
	public static Reference construct(GhostReference ghost,String schID){
		// null ghost is catch by nullPointerException -- ¡¡ DIRTY !!
		Reference materializedRef = null;
		try{
			materializedRef = construct(ghost.id,ghost.title,ghost.resume,ghost.year,schID);
			// copy keywords and authors
			materializedRef.setKeywords(ghost.keywords);
			materializedRef.setAuthors(ghost.authors);
		}catch(Exception e){}
		return materializedRef;
	}
	
	/**
	 * Materialize a ghost ref.
	 * 
	 * @param ghost
	 * @return
	 */
	public static Reference materialize(GhostReference ghost){
		return construct(ghost,"");
	}
	
	public static Reference materialize(GhostReference ghost,String schID){
		return construct(ghost,schID);
	}
	
	/**
	 * Set keywords from an existing collection.
	 * 
	 * @param a
	 */
	public void setAuthors(Collection<String> a){
		// current set of authors assumed existing ; but creates it of called from ghost ref e.g.
		if(authors==null){authors=new HashSet<String>();}
		for(String s:a){authors.add(s);}
	}
	
	/**
	 * Set keywords from an existing set.
	 * 
	 * @param a
	 */
	public void setKeywords(Collection<String> k){
		// current set of authors assumed existing ; but creates it of called from ghost ref e.g.
		if(keywords==null){keywords=new HashSet<String>();}
		for(String s:k){keywords.add(s);}
	}
	
	/**
	 * Authors as string.
	 * @return
	 */
	public String getAuthorString(){
		String res="";
		for(String a:authors){res=res+";"+a;}
		return(res.substring(0, res.length()-1));
	}
	
	/**
	 * Keywords as string.
	 * 
	 * @return
	 */
	public String getKeywordString(){
		String res="";
		for(String a:authors){res=res+";"+a;}
		return(res.substring(0, res.length()-1));
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
		
		if(scholarID!=null&&scholarID!=""){
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
			if(r.scholarID!=null&&r.scholarID!=""&&scholarID!=null&&scholarID!=""){
				return r.scholarID.equals(scholarID);
			}
			else{
				return (StringUtils.getLevenshteinDistance(StringUtils.lowerCase(r.title.title),StringUtils.lowerCase(title.title))<4);			
			}
		}
	}
	
	
	/**
	 * Override to string
	 */
	public String toString(){
		return "Ref "+id+" - schID : "+scholarID+" - t : "+title+" - year : "+year+" - authors : "+getAuthorString()+" - keywords : "+getKeywordString();
	}
	
}
