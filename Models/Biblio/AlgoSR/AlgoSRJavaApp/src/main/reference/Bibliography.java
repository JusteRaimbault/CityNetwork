/**
 * 
 */
package main.reference;

import java.util.HashSet;

/**
 * Biblio of a Reference
 * 
 * @author Raimbault Juste <br/> <a href="mailto:juste.raimbault@polytechnique.edu">juste.raimbault@polytechnique.edu</a>
 *
 */
public class Bibliography {
	
	/**
	 * The empty biblio.
	 */
	public static final Bibliography EMPTY = new Bibliography(new HashSet<Reference>());
	
	/**
	 * Cited references.
	 */
	public HashSet<Reference> cited;
	
	
	/**
	 * Titles of cited refs, used for intermediate construction of the citation network
	 */
	public HashSet<String> citedTitles;
	
	
	/**
	 * Raw content of a biblio, only uncompletly parsed (from cybergeo, or raw text ?)
	 */
	public HashSet<String> citedRaw;
	
	/**
	 * Direct constructor
	 * 
	 * @param c
	 */
	public Bibliography(HashSet<Reference> c){
		cited = c;
		citedTitles = new HashSet<String>();
		for(Reference r:c){citedTitles.add(r.title.title);}
		// no raw
		citedRaw = new HashSet<String>();
	}
	
	
	public Bibliography(){
		cited = new HashSet<Reference>();
		citedTitles = new HashSet<String>();
		citedRaw = new HashSet<String>();
	}
	
	/**
	 * Full contructor
	 * 
	 * @param raw
	 */
	public Bibliography(HashSet<Reference> c,HashSet<String> ti,HashSet<String> raw){
		cited=c;citedTitles=ti;citedRaw=raw;
	}
	
	/**
	 * unparsed biblio
	 * 
	 * @param c
	 * @param ti
	 * @param raw
	 */
	public Bibliography(HashSet<String> ti,HashSet<String> raw){
		citedTitles=ti;citedRaw=raw;
		// fill cited with ghost refs
		cited = new HashSet<Reference>();
		for(String t:citedTitles){cited.add(new GhostReference(t,""));}
	}
	
	
}
