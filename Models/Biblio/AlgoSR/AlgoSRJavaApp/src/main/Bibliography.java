/**
 * 
 */
package main;

import java.util.HashSet;

/**
 * Biblio of a Reference
 * 
 * @author Raimbault Juste <br/> <a href="mailto:juste.raimbault@polytechnique.edu">juste.raimbault@polytechnique.edu</a>
 *
 */
public class Bibliography {
	
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
	public Bibliography(HashSet<Reference> c){cited = c;}
	
	/**
	 * Constructor given a parser ?
	 * 
	 * @param raw
	 */
	public Bibliography(String raw){}
	
}
