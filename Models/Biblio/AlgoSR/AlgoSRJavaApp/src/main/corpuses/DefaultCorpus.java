/**
 * 
 */
package main.corpuses;

import java.util.HashSet;
import java.util.Set;

import main.Reference;

/**
 * @author Raimbault Juste <br/> <a href="mailto:juste.raimbault@polytechnique.edu">juste.raimbault@polytechnique.edu</a>
 *
 */
public class DefaultCorpus extends Corpus {

	/**
	 * Empty corpus
	 */
	public DefaultCorpus(){
		references = new HashSet<Reference>();
	}
	
	
	/**
	 * Corpus from existing set.
	 * 
	 * @param refs
	 */
	public DefaultCorpus(Set<Reference> refs){
		references = new HashSet<Reference>(refs);
	}
	
}
