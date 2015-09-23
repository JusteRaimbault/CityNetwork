/**
 * 
 */
package main.corpuses;

import java.util.HashSet;

import scholar.ScholarAPI;
import main.Reference;

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
	}

	
	/**
	 * Construct cited refs of cybergeo corpus
	 */
	public void fillCitedRefs(){
		for(Reference r:references){
			for(String title:r.citedTitles){
				Reference cr = ScholarAPI.getScholarRef(title);
				if(cr!=null){r.cited.add(cr);}
			}
			//recompute citedTitles
			r.citedTitles.clear();
			for(Reference cr:r.cited){r.citedTitles.add(cr.title);}
		}
	}
	
	
}

