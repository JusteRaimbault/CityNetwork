/**
 * 
 */
package cybergeo;

import java.util.Date;
import java.util.HashSet;

import main.Main;
import main.corpuses.Corpus;
import main.corpuses.CybergeoCorpus;
import main.corpuses.CybergeoFactory;
import main.corpuses.DefaultCorpus;
import main.corpuses.RISFactory;
import main.reference.Abstract;
import main.reference.Reference;
import main.reference.Title;
import scholar.ScholarAPI;
import sql.CybergeoImport;
import sql.SQLConnection;
import sql.SQLConverter;
import sql.SQLExporter;
import sql.SQLImporter;
import utils.Log;
import utils.RISWriter;
import utils.tor.TorPool;
import utils.tor.TorPoolManager;

/**
 * @author Raimbault Juste <br/> <a href="mailto:juste.raimbault@polytechnique.edu">juste.raimbault@polytechnique.edu</a>
 *
 */
public class Cybergeo {

	
	/**
	 * SQL -> RIS conversion
	 * 
	 * @param outFile
	 */
	public static void exportCybergeoAsRIS(String outFile){
		SQLConnection.setupSQL("Cybergeo");
		CybergeoCorpus cybergeo = (CybergeoCorpus) (new CybergeoFactory("",-1)).getCorpus();
		RISWriter.write(outFile, cybergeo.references,false);
	}
	
	
	/**
	 * Setup initial cybergeo corpus from RIS
	 * 
	 * @param numRefs
	 * @return
	 */
	public static Corpus setup(String bibFile,int numRefs){

		 Main.setup("conf/default.conf");
		 
		 Log.purpose("runtime", "Started at "+(new Date()).toString());
		 
		 try{TorPoolManager.setupTorPoolConnexion();}catch(Exception e){e.printStackTrace();}
		 ScholarAPI.init();
		 
		 //CybergeoImport.setupSQL();
		 
		 //CybergeoCorpus cybergeo = (CybergeoCorpus) (new CybergeoFactory("2010-01-01",2)).getCorpus();
		 return new CybergeoCorpus((new RISFactory(bibFile,numRefs)).getCorpus().references);
			 
	}
	
	
	
	/**
	 * Get and fill schIDS for all cyb refs ; reexports as ris (-> for consistent environment with refs hashed through schID)
	 */
	public static void fillScholarIDS(String inFile,int numRefs,String outFile){
		CybergeoCorpus cybergeo = (CybergeoCorpus) setup(inFile,numRefs);
		cybergeo.fillScholarIDs();
		RISWriter.write(outFile, cybergeo.references,true);
	}
	
	
	public static void testCitedRefConstruction(String bibFile){
		
		 CybergeoCorpus cybergeo = (CybergeoCorpus) setup(bibFile,-1);
		 // test cited refs reconstruction
		 cybergeo.fillCitedRefs();
		 
		 //
		 for(Reference r:cybergeo.references){System.out.println(r.toString()+"\n CITES : ");for(Reference cr:r.biblio.cited){System.out.println(cr.toString());}}
		 
	}
	
	
	public static void testCitingRefs(String bibFile){
		 CybergeoCorpus cybergeo = (CybergeoCorpus) setup(bibFile,-1);
		 System.out.println("Corpus size : "+Reference.references.keySet().size());	
		 cybergeo.fillCitingRefs();
		 cybergeo.gexfExport(System.getenv("CS_HOME")+"/Cybergeo/cybergeo20/Data/processed/networks/test_citingNW_"+(new Date().toString().replaceAll(" ", "-"))+".gexf");
		 
		 int s = 0;
		 for(Reference r:cybergeo.references){
			 if(r.attributes.get("failed_req").compareTo("1")==0){s++;}
		 }
		 System.out.println("Failed : "+(s*1.0/cybergeo.references.size()));
		 
	}
	
	/**
	 * Get the whole 3-level network
	 * 
	 * @param bibFile
	 * @param numrefs
	 */
	public static void fullNetwork(String bibFile,String outfile,int numrefs){
		CybergeoCorpus cybergeo = (CybergeoCorpus) setup(bibFile,numrefs);
		cybergeo.name="cybergeo";
		
		cybergeo.fillCitedRefs();
		
		// must construct by hand set of cited ?
		HashSet<Reference> cited = new HashSet<Reference>();
		for(Reference r:cybergeo.references){
			//Corpus cited = new DefaultCorpus(r.biblio.cited);
			for(Reference c:r.biblio.cited){cited.add(c);}
		}
		Corpus citedCorpus = new DefaultCorpus(cited);
		citedCorpus.name="cited";
		System.out.println("Total cited "+cited.size());
		
		// citing refs for cited (== cybergeo level)
		citedCorpus.fillCitingRefs();
		
		// TODO 2nd level !! do not use all refs - (some title calls should be ghostized ? )
		cybergeo.fillCitingRefs();
		Corpus citingCited = citedCorpus.getCitingCorpus();citingCited.name="citing-cited";
		citingCited.fillCitingRefs();
		System.out.println("Final refs : "+Reference.references.keySet().size());
		
		HashSet<Corpus> all = new HashSet<Corpus>();
		all.add(cybergeo);all.add(citedCorpus);all.add(citedCorpus.getCitingCorpus());
		// export
		(new DefaultCorpus(all,0)).gexfExport(outfile);
	
	}
	
	
	
	public static void testSQLExport(){
		String bibFile = System.getenv("CS_HOME")+"/Cybergeo/cybergeo20/Data/bib/fullbase_refsAsBib_ids.ris";
		CybergeoCorpus base = (CybergeoCorpus) setup(bibFile,1);
		//for(Reference r:base.references){r.biblio.cited.add(Reference.construct("", new Title("dummy ref"), new Abstract("abstract"), "2015", "1234532345675"));}
		/*
		base.fillCitedRefs();
		SQLExporter.export(base, "cybtest", "cybergeo", "refs", "links",true);
		*/
		
		//base = (CybergeoCorpus) setup(bibFile,1);
		base.fillCitingRefs();
		base.fillCitedRefs();// NOTE : a cybergeocorpus has ghostrefs by default -> issue ?
		SQLExporter.export(base, "cybtest", "cybergeo", "refs", "links","status",true);
		
	}
	
	/**
	 * constructs full network, progressively inserting it in sql.
	 * assumed database structure : cybergeo : (id,title,year), refs : (id,title,year), links :(citing,cited)
	 */
	public static void fullNetworkSQLExport(String bibFile,String database,int numrefs){
		
		CybergeoCorpus cybergeo = (CybergeoCorpus) setup(bibFile,numrefs);
		cybergeo.name="cybergeo";
		Corpus completed = SQLImporter.sqlImportPrimary(database, "cybergeo", "1",true);
		
		// iterate on single refs, export to sql at each
		for(Reference cybref:cybergeo.references){
			if(!checkStatus(cybref,completed)){
				CybergeoCorpus c = new CybergeoCorpus(cybref);
				c.fillCitedRefs();
				Corpus citedCorpus = c.getCitedCorpus();
				citedCorpus.name="cited";
				citedCorpus.fillCitingRefs();
				c.fillCitingRefs();
				Corpus citingCited = citedCorpus.getCitingCorpus();
				citingCited.name="citing-cited";

				// do not fill 2nd level - takes too much time, incomplete database for now.
				//citingCited.fillCitingRefs();

				SQLExporter.export(c, database,"cybergeo","refs", "links","status", true);
			}
		}
		
		Log.purpose("runtime", "Finished at "+(new Date()).toString());
		
	}
	
	private static boolean checkStatus(Reference r,Corpus c){
		return c.references.contains(r);
	}
	
	/**
	 * get refs which have not been completed yet and completes citing refs.
	 *   Note : status table ? -> completed on first run, then ok.
	 *   Assumes status table is operational.
	 * @param database
	 */
	public static void completeNetworkSQLExport(String database){
		
	}
	
	/**
	 * from primary corpus -> get cited, citing cited.
	 * 
	 * @param database
	 */
	public static void updateStatusTable(String database){
		Corpus all = SQLImporter.sqlImport(database, "cybergeo", "refs", "links", false);
		Corpus primary = SQLImporter.sqlImportPrimary(database, "cybergeo","1",false);
		
		for(Reference prim:primary){
			for(Reference cited:prim.biblio.cited){
				for(Reference citingcited:cited.citing){
					updateStatus(citingcited);
				}
			}
		}
	}
	
	private static void updateStatus(Reference r){
		SQLConnection.executeUpdate("INSERT INTO status ");
	}
	
	
	
	
	
	/**
	 * @param args
	 */
	public static void main(String[] args) {
		Main.setup();
		
		//exportCybergeoAsRIS(System.getenv("CS_HOME")+"/Cybergeo/cybergeo20/Data/bib/fullbase_refsAsBib.ris");
		
		//fillScholarIDS(bibFile,-1,System.getenv("CS_HOME")+"/Cybergeo/cybergeo20/Data/bib/fullbase_refsAsBib_ids.ris");
		
		// check ris export
		//CybergeoCorpus cybergeo = new CybergeoCorpus((new RISFactory(System.getenv("CS_HOME")+"/Cybergeo/cybergeo20/Data/bib/fullbase.ris",10)).getCorpus().references);
		/*
		for(Reference r:cybergeo.references){
			System.out.println(r.toString());
			//System.out.println(r.toString()+"\n CITES : ");for(Reference cr:r.cited){System.out.println(cr.toString());}
		}
		*/
		
		//testCitedRefConstruction();
		
		//testCitingRefs();
		
		/*Main.setup();
		try{TorPoolManager.setupTorPoolConnexion();}catch(Exception e){}
		SQLConnection.setupSQL("cybtest");
		*/
		
		
		//fullNetwork(Integer.parseInt(args[0]));
		
		
		String bibFile = System.getenv("CS_HOME")+"/Cybergeo/cybergeo20/Data/bib/fullbase_refsAsBib_ids.ris";
		//String outfile = System.getenv("CS_HOME")+"/Cybergeo/cybergeo20/Data/processed/networks/testfull_1refs_"+(new Date().toString().replaceAll(" ", "-"))+".gexf"; 
		
		//fullNetwork(bibFile,outfile,1);
	

		//testSQLExport();
		
		fullNetworkSQLExport(bibFile,"cyb_test1",13);
		
		// full nw
		//fullNetworkSQLExport(bibFile,"cybergeo",-1);
		
		//SQLConverter.sqlToGexf("test_cyb1","res/sql/testSqlToGexf.gexf");
		
	}

}
