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
			HashSet<Reference> verifiedCited=new HashSet<Reference>();
			for(Reference ghost:r.biblio.cited){
				System.out.println("     Cited : "+ghost.title.title);
				Reference cr = ScholarAPI.getScholarRef(ghost.title.title,"",ghost.year);
				if(cr!=null){
					verifiedCited.add(cr);
					cr.citing.add(r);
				}
			}
			
			// dirty dirty
			r.biblio.cited = verifiedCited;
			
			/**
			 * TODO : write a generic constructor from ref title, combining mendeley and scholar requests to have most info possible ?
			 */
			
			//recompute citedTitles : may slightly differ after scholar request
			r.biblio.citedTitles.clear();
			for(Reference cr:r.biblio.cited){r.biblio.citedTitles.add(cr.title.title);}
		}
	}
	
	
}

