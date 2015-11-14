/**
 * 
 */
package sql;

import java.util.HashMap;
import java.util.HashSet;

import main.corpuses.Corpus;
import main.reference.Reference;

/**
 * @author Raimbault Juste <br/> <a href="mailto:juste.raimbault@polytechnique.edu">juste.raimbault@polytechnique.edu</a>
 *
 */
public class SQLExporter {
	
	
	/**
	 * Exports a corpus given the following schema
	 *   (specific to cybergeo corpus for the cited part ? not necessarily, as long as cited is filled)
	 *   root ref by root ref :
	 *   - citing refs, recursively
	 *   - cited refs ; citing cited recursively
	 * 
	 * @param corpus
	 */
	public static void export(Corpus corpus,String databaseName,String primaryTableName,String secondaryTableName,String citationTableName){
		try{
			SQLConnection.setupSQL(databaseName);
			
			HashSet<Reference> primaryRefs = new HashSet<Reference>();
			HashSet<Reference> secondaryRefs = new HashSet<Reference>();
			HashMap<String,String> citations = new HashMap<String,String>();
			
			for(Reference r:corpus.references){
				primaryRefs.add(r);
				// not generic in levels for now
				for(Reference rc:r.citing){secondaryRefs.add(rc);citations.put(rc.scholarID,r.scholarID);}
				for(Reference rcited:r.biblio.cited){
					secondaryRefs.add(rcited);citations.put(r.scholarID, rcited.scholarID);
					for(Reference rc1:rcited.citing){
						secondaryRefs.add(rc1);citations.put(rc1.scholarID, rcited.scholarID);
						for(Reference rc2:rc1.citing){secondaryRefs.add(rc2);citations.put(rc2.scholarID, rc1.scholarID);}
					}
				}
				
				// construct sql requests and execute
				String req = insertSetRequest(primaryRefs,primaryTableName);
				
				
			}
		}catch(Exception e){e.printStackTrace();}
	}
	
	
	private static String insertSetRequest(HashSet<Reference> r,String primaryTableName){
		String req = "INSERT INTO "+primaryTableName+" (id,title,year) VALUES (";
		for(Reference rp:r){req+="("+rp.scholarID+","+rp.title.title+","+rp.year+"),";}
		req=req.substring(0, req.length()-1)+");";
		return(req);
	}
	
	
	
	
}
