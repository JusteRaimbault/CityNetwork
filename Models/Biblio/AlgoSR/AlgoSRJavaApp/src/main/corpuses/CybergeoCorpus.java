/**
 * 
 */
package main.corpuses;

import java.util.HashSet;

import scholar.ScholarAPI;
import main.reference.Reference;

/**
 * @author Raimbault Juste <br/> <a href="mailto:juste.raimbault@polytechnique.edu">juste.raimbault@polytechnique.edu</a>
 *
 */
public class CybergeoCorpus extends Corpus {
	
	/**
	 * 
	 * 
	 * @param refs
	 */
	public CybergeoCorpus(HashSet<Reference> refs){
		references = refs;
		
		// add attribute
		for(Reference r:references){
			r.attributes.put("cybergeo", "1");
		}
	}

	
	/**
	 * Construct cited refs of cybergeo corpus
	 */
	public void fillCitedRefs(){
		for(Reference r:references){
			for(String title:r.biblio.citedTitles){
				System.out.println("   cited : "+title);
				Reference cr = ScholarAPI.getScholarRef(title,"","");
				if(cr!=null){r.biblio.cited.add(cr);}
			}
			
			/**
			 * TODO : write a generic constructor from ref title, combining mendeley and scholar requests to have most info possible ?
			 */
			
			//recompute citedTitles : may slightly differ after scholar request
			r.biblio.citedTitles.clear();
			for(Reference cr:r.biblio.cited){r.biblio.citedTitles.add(cr.title.title);}
		}
	}
	
	
}

