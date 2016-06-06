/**
 * 
 */
package main.corpuses;

import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedList;

import scholar.ScholarAPI;
import utils.CSVWriter;
import utils.GEXFWriter;
import main.reference.Reference;

/**
 * A corpus is a set of references
 * 
 * @author Raimbault Juste <br/> <a href="mailto:juste.raimbault@polytechnique.edu">juste.raimbault@polytechnique.edu</a>
 *
 */
public abstract class Corpus implements Iterable<Reference> {
	
	/**
	 * References in the corpus
	 */
	public HashSet<Reference> references;

	/**
	 * Name of the corpus
	 */
	public String name;
	
	
	public Corpus fillScholarIDs(){
		ScholarAPI.fillIds(references);
		return this;
	}
	
	
	/**
	 * Get citing refs.
	 * 
	 * @return this corpus
	 */
	public Corpus fillCitingRefs(){
		ScholarAPI.fillIdAndCitingRefs(this);
		return this;
	}
	
	
	/**
	 * Get the corpus of refs citing - assumes citing refs have been filled,
	 * only construct a wrapper around a new hashSet.
	 * 
	 * @return
	 */
	public Corpus getCitingCorpus(){
		HashSet<Reference> citing = new HashSet<Reference>();
		for(Reference r:references){
			for(Reference c:r.citing){
				citing.add(c);
			}
		}
		return new DefaultCorpus(citing);
	}
	
	public Corpus getCitedCorpus(){
		HashSet<Reference> cited = new HashSet<Reference>();
		for(Reference r:references){
			for(Reference rc:r.biblio.cited){
				cited.add(rc);
			}
		}
		return new DefaultCorpus(cited);
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
	
	
	/**
	 * Export to csv
	 * 
	 * @param file
	 */
	public void csvExport(String prefix){
		LinkedList<String[]> datanodes = new LinkedList<String[]>();
		LinkedList<String[]> dataedges = new LinkedList<String[]>();
		for(Reference r:references){
			String[] row = {r.title.title,r.scholarID,r.year};
			datanodes.add(row);
			for(Reference rc:r.citing){String[] edge = {rc.scholarID,r.scholarID};dataedges.add(edge);}	
		}
		CSVWriter.write(prefix+".csv", datanodes, ";", "\"");
		CSVWriter.write(prefix+"_links.csv", dataedges, ";", "\"");
	}
	
	
	
	/**
	 * Iterable type.
	 */
	public Iterator<Reference> iterator(){
		return references.iterator();
	}
	
	
}
