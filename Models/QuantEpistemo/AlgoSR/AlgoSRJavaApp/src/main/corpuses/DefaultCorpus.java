/**
 * 
 */
package main.corpuses;

import java.util.HashSet;
import java.util.Set;

import main.reference.Reference;

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
	
	public DefaultCorpus(Reference r){
		references = new HashSet<Reference>();
		references.add(r);
	}
	
	
	/**
	 * Corpus from existing set.
	 * 
	 * @param refs
	 */
	public DefaultCorpus(Set<Reference> refs){
		references = new HashSet<Reference>(refs);
	}
	
	
	/**
	 * Fusion of corpuses
	 * 
	 * @param corpuses
	 */
	public DefaultCorpus(Set<Corpus> corpuses,int t){
		references = new HashSet<Reference>();
		for(Corpus c:corpuses){
			System.out.println(c.references.size());
			for(Reference r:c.references){
				references.add(r);
			}
		}
	}
	
	
}
