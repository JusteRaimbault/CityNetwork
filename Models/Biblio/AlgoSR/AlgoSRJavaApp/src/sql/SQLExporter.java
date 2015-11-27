/**
 * 
 */
package sql;

import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedList;

import org.apache.commons.lang3.tuple.MutablePair;

import utils.tor.TorPoolManager;
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
	public static void export(Corpus corpus,String databaseName,String primaryTableName,String secondaryTableName,String citationTableName,boolean reconnectTorPool){
		try{
			SQLConnection.setupSQL(databaseName);
			
			HashSet<Reference> primaryRefs = new HashSet<Reference>();
			HashSet<Reference> secondaryRefs = new HashSet<Reference>();
			LinkedList<MutablePair<String,String>> citations = new LinkedList<MutablePair<String,String>>();
			
			for(Reference r:corpus.references){
				primaryRefs.add(r);
				// not generic in levels for now
				for(Reference rc:r.citing){
					System.out.println("citing : "+rc);
					secondaryRefs.add(rc);
					citations.add(new MutablePair<String,String>(rc.scholarID,r.scholarID));}
				for(Reference rcited:r.biblio.cited){
					System.out.println("cited : "+rcited);
					secondaryRefs.add(rcited);citations.add(new MutablePair<String,String>(r.scholarID, rcited.scholarID));
					for(Reference rc1:rcited.citing){
						secondaryRefs.add(rc1);citations.add(new MutablePair<String,String>(rc1.scholarID, rcited.scholarID));
						for(Reference rc2:rc1.citing){secondaryRefs.add(rc2);citations.add(new MutablePair<String,String>(rc2.scholarID, rc1.scholarID));}
					}
				}
				
				// construct sql requests and execute
				//primary
				SQLConnection.executeUpdate(insertSetRequest(primaryRefs,primaryTableName));
				//secondary
				SQLConnection.executeUpdate(insertSetRequest(secondaryRefs,secondaryTableName));
				//citation
				SQLConnection.executeUpdate(insertCitRequest(citations,citationTableName));
			}
			
			if(reconnectTorPool){TorPoolManager.setupTorPoolConnexion();}
			
			
		}catch(Exception e){e.printStackTrace();}
	}
	
	
	/**
	 * insert a set of refs
	 * 
	 * @param r
	 * @param primaryTableName
	 * @return
	 */
	private static String insertSetRequest(HashSet<Reference> r,String table){
		if(r.size()==0){return "";}
		
		String req = "INSERT INTO "+table+" (id,title,year) VALUES ";
		for(Reference rp:r){req+="('"+rp.scholarID+"','"+rp.title.title.replace("'", "’")+"',"+rp.year+"),";}
		req=req.substring(0, req.length()-1)+" ON DUPLICATE KEY UPDATE id = VALUES(id);";

		return(req);
	}

	/**
	 * insert citation links sql request
	 * 
	 * @param cit
	 * @param citationTableName
	 * @return
	 */
	private static String insertCitRequest(LinkedList<MutablePair<String,String>> cit,String citationTableName){
		if(cit.size()==0){return "";}
		
		String req = "INSERT INTO "+citationTableName+" (id,citing,cited) VALUES ";

		for(MutablePair<String,String> pair:cit){req+="('"+pair.left+pair.right+"','"+pair.left+"','"+pair.right+"'),";}
		req=req.substring(0, req.length()-1)+" ON DUPLICATE KEY UPDATE id = VALUES(id);";

		return req;
	}

	
	
}
