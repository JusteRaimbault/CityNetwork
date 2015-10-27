/**
 * 
 */
package main.corpuses;

import java.util.HashSet;

import scholar.ScholarAPI;
import utils.GEXFWriter;
import main.Reference;

/**
 * A corpus is a set of references
 * 
 * @author Raimbault Juste <br/> <a href="mailto:juste.raimbault@polytechnique.edu">juste.raimbault@polytechnique.edu</a>
 *
 */
public abstract class Corpus {
	
	public HashSet<Reference> references;

	
	/**
	 * Get citing refs.
	 * 
	 * @return this corpus
	 */
	public Corpus getCitingRefs(){
		ScholarAPI.fillIdAndCitingRefs(references);
		return this;
	}
	
	
	/**
	 * Get abstracts using Mendeley api.
	 * 
	 * @return
	 */
	public Corpus getAbstracts(){
		
		return this;
	}
	
	
	/**
	 * Write this corpus to gexf file
	 */
	public void gexfExport(String file){
		GEXFWriter.writeCitationNetwork(file,references);
	}
	
}
