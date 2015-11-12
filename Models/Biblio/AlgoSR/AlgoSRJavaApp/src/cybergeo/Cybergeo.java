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
import main.reference.Reference;
import scholar.ScholarAPI;
import sql.CybergeoImport;
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
		CybergeoImport.setupSQL();
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
	
	public static void fullNetwork(String bibFile,int numrefs){
		CybergeoCorpus cybergeo = (CybergeoCorpus) setup(bibFile,numrefs);
		
		cybergeo.fillCitedRefs();
		
		// must construct by hand set of cited ?
		HashSet<Reference> cited = new HashSet<Reference>();
		for(Reference r:cybergeo.references){
			for(Reference c:r.biblio.cited){cited.add(c);}
		}
		Corpus citedCorpus = new DefaultCorpus(cited);
		System.out.println("Total cited "+cited.size());
		
		// citing refs for cited (== cybergeo level)
		citedCorpus.fillCitingRefs();
		
		// TODO 2nd level !! do not use all refs - (some title calls should be ghostized ? )
		cybergeo.fillCitingRefs();
		citedCorpus.getCitingCorpus().fillCitingRefs();
		System.out.println("Final refs : "+Reference.references.keySet().size());
		
		HashSet<Corpus> all = new HashSet<Corpus>();
		all.add(cybergeo);all.add(citedCorpus);all.add(citedCorpus.getCitingCorpus());
		// export
		(new DefaultCorpus(all,0)).gexfExport(System.getenv("CS_HOME")+"/Cybergeo/cybergeo20/Data/processed/networks/testfull_4refs_"+(new Date().toString().replaceAll(" ", "-"))+".gexf");
	
	}
	
	
	/**
	 * @param args
	 */
	public static void main(String[] args) {
		
		String bibFile = System.getenv("CS_HOME")+"/Cybergeo/cybergeo20/Data/bib/fullbase_refsAsBib.ris";
		
		//exportCybergeoAsRIS(System.getenv("CS_HOME")+"/Cybergeo/cybergeo20/Data/bib/fullbase_refsAsBib.ris");
		
		fillScholarIDS(bibFile,-1,System.getenv("CS_HOME")+"/Cybergeo/cybergeo20/Data/bib/fullbase_refsAsBib_ids.ris");
		
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
		
		
		//fullNetwork(Integer.parseInt(args[0]));
		//fullNetwork(3);
	}

}
