/**
 * 
 */
package sql;

import java.sql.ResultSet;
import java.util.HashSet;

import utils.tor.TorPoolManager;
import main.corpuses.Corpus;
import main.corpuses.DefaultCorpus;
import main.reference.Abstract;
import main.reference.Bibliography;
import main.reference.Reference;
import main.reference.Title;

/**
 * @author Raimbault Juste <br/> <a href="mailto:juste.raimbault@polytechnique.edu">juste.raimbault@polytechnique.edu</a>
 *
 */
public class SQLImporter {
	
	/**
	 * imports a corpus from simple database.
	 * marks principal refs with "principal" attribute
	 * 
	 * @param database
	 * @return
	 */
	public static Corpus sqlImport(String database,String principalTableName,String secondaryTableName,String citationTableName,boolean reconnectTorPool){
		HashSet<Reference> refs = new HashSet<Reference>();
		
		try{
			SQLConnection.setupSQL(database);

			// primary refs
			ResultSet resprim = SQLConnection.executeQuery("SELECT * FROM "+principalTableName+";");		
			while(resprim.next()){refs.add(Reference.construct("",new Title(resprim.getString(1)),new Abstract(),resprim.getString(2), resprim.getString(0)));}
			//set prim attribute
			for(Reference r:refs){r.attributes.put("primary", "1");}
			
			//secondary refs
			ResultSet ressec = SQLConnection.executeQuery("SELECT * FROM "+secondaryTableName+";");		
			while(ressec.next()){refs.add(Reference.construct("",new Title(ressec.getString(1)),new Abstract(),ressec.getString(2), ressec.getString(0)));}
			
			// add citations -> refs already constructed, construct method gives refs
			ResultSet rescit = SQLConnection.executeQuery("SELECT * FROM "+citationTableName+";");	
			while(rescit.next()){
				Reference citing = Reference.construct(rescit.getString(0));
				Reference cited = Reference.construct(rescit.getString(1));
				cited.citing.add(citing);
				citing.biblio.cited.add(cited);
			}
			
			if(reconnectTorPool){TorPoolManager.setupTorPoolConnexion();}
		}catch(Exception e){e.printStackTrace();}

		return new DefaultCorpus(refs);
	}
	
	
	
	
	
	
}
