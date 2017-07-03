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
	public static Corpus sqlImport(String database,String principalTableName,String secondaryTableName,String citationTableName,int numRefs,boolean reconnectTorPool){
		HashSet<Reference> refs = new HashSet<Reference>();
		
		try{
			SQLConnection.setupSQL(database);

			// primary refs
			String primaryQuery = "SELECT * FROM "+principalTableName;
			if(numRefs!=-1){primaryQuery=primaryQuery+" LIMIT "+numRefs;}
			primaryQuery=primaryQuery+";";
			ResultSet resprim = SQLConnection.executeQuery(primaryQuery);
			int primRefs = 0;
			while(resprim.next()){
				Reference r = Reference.construct("",new Title(resprim.getString(2)),new Abstract(),resprim.getString(3), resprim.getString(1));
				refs.add(r);
				System.out.println(r);
				primRefs++;
			}
			//set prim attribute
			for(Reference r:refs){r.attributes.put("primary", "1");}
			
			//secondary refs
			
			ResultSet ressec = SQLConnection.executeQuery("SELECT * FROM "+secondaryTableName+";");		
			while(ressec.next()){
				Reference r = Reference.construct("",new Title(ressec.getString(2)),new Abstract(),ressec.getString(3), ressec.getString(1));
				refs.add(r);
				System.out.println(r);
			}
			
			// add citations -> refs already constructed, construct method gives refs
			ResultSet rescit = SQLConnection.executeQuery("SELECT * FROM "+citationTableName+";");	
			while(rescit.next()){
				Reference citing = Reference.construct(rescit.getString(1));
				Reference cited = Reference.construct(rescit.getString(2));
				System.out.println(citing.scholarID+" - "+cited.scholarID);
				cited.citing.add(citing);
				citing.biblio.cited.add(cited);
			}
			
			if(reconnectTorPool){TorPoolManager.setupTorPoolConnexion();}
		}catch(Exception e){e.printStackTrace();}

		return new DefaultCorpus(refs);
	}
	
	
	public static Corpus sqlImportPrimary(String database,String table,String status,int numRefs,boolean reconnectTorPool){
		HashSet<Reference> refs = new HashSet<Reference>();
		try{
			SQLConnection.setupSQL(database);
			String query = "SELECT "+table+".id,title,year,status FROM "+table+" JOIN status ON status.id=cybergeo.id";
			if(status.length()>0){query=query+" WHERE status="+status;}
			if(numRefs != -1){query=query+" LIMIT "+numRefs;}
			query = query + ";";
			ResultSet resprim = SQLConnection.executeQuery(query);		
			while(resprim.next()){refs.add(Reference.construct("",new Title(resprim.getString(2)),new Abstract(),resprim.getString(3), resprim.getString(1)));}
			if(reconnectTorPool){TorPoolManager.setupTorPoolConnexion();}
		}catch(Exception e){e.printStackTrace();}
		
		return new DefaultCorpus(refs) ;
	}
	
	
	public static HashSet<String> sqlSingleColumn(String database,String table, String column,boolean reconnectTorPool){
		HashSet<String> res = new HashSet<String>();
		try{
			SQLConnection.setupSQL(database);
			String query = "SELECT "+column+" FROM "+table+";";
			ResultSet resq = SQLConnection.executeQuery(query);		
			while(resq.next()){res.add(resq.getString(1));}
			if(reconnectTorPool){TorPoolManager.setupTorPoolConnexion();}
		}catch(Exception e){e.printStackTrace();}
		
		return res;
	}
	
	
	
	
	
}
