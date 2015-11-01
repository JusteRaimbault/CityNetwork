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

	
	public static void exportCybergeoAsRIS(String outFile){
		CybergeoImport.setupSQL();
		CybergeoCorpus cybergeo = (CybergeoCorpus) (new CybergeoFactory("",-1)).getCorpus();
		RISWriter.write(outFile, cybergeo.references);
	}
	
	
	public static Corpus setupTest(int numRefs){

		 Main.setup("conf/default.conf");
		 try{TorPoolManager.setupTorPoolConnexion();}catch(Exception e){e.printStackTrace();}
		 ScholarAPI.init();
		 
		 //CybergeoImport.setupSQL();
		 
		 //CybergeoCorpus cybergeo = (CybergeoCorpus) (new CybergeoFactory("2010-01-01",2)).getCorpus();
		 return new CybergeoCorpus((new RISFactory(System.getenv("CS_HOME")+"/Cybergeo/cybergeo20/Data/bib/fullbase_withRefs_origTitles.ris",numRefs)).getCorpus().references);
			 
	}
	
	
	public static void testCitedRefConstruction(){
		
		 CybergeoCorpus cybergeo = (CybergeoCorpus) setupTest(-1);
		 // test cited refs reconstruction
		 cybergeo.fillCitedRefs();
		 
		 //
		 for(Reference r:cybergeo.references){System.out.println(r.toString()+"\n CITES : ");for(Reference cr:r.biblio.cited){System.out.println(cr.toString());}}
		 
	}
	
	
	public static void testCitingRefs(){
		 CybergeoCorpus cybergeo = (CybergeoCorpus) setupTest(-1);
		 System.out.println("Corpus size : "+Reference.references.keySet().size());	
		 cybergeo.getCitingRefs();
		 cybergeo.gexfExport(System.getenv("CS_HOME")+"/Cybergeo/cybergeo20/Data/processed/networks/test_citingNW_"+(new Date().toString().replaceAll(" ", "-"))+".gexf");
		 
		 int s = 0;
		 for(Reference r:cybergeo.references){
			 if(r.attributes.get("failed_req").compareTo("1")==0){s++;}
		 }
		 System.out.println("Failed : "+(s*1.0/cybergeo.references.size()));
		 
	}
	
	public static void fullNetwork(){
		CybergeoCorpus cybergeo = (CybergeoCorpus) setupTest(-1);
		
		cybergeo.fillCitedRefs();
		
		// must construct by hand set of cited ?
		HashSet<Reference> cited = new HashSet<Reference>();
		for(Reference r:cybergeo.references){
			for(Reference c:r.biblio.cited){cited.add(c);}
		}
		System.out.println("Total cited "+cited.size());
		(new DefaultCorpus(cited)).getCitingRefs();
		
		// 2nd level
		(new DefaultCorpus(Reference.references.keySet())).getCitingRefs();
		System.out.println("Final refs : "+Reference.references.keySet().size());
		
		// export
		(new DefaultCorpus(Reference.references.keySet())).gexfExport(System.getenv("CS_HOME")+"/Cybergeo/cybergeo20/Data/processed/networks/fullNW_"+(new Date().toString().replaceAll(" ", "-"))+".gexf");
	
	}
	
	
	/**
	 * @param args
	 */
	public static void main(String[] args) {
		//exportCybergeoAsRIS(System.getenv("CS_HOME")+"/Cybergeo/cybergeo20/Data/bib/fullbase_rawRefs_origTitles.ris");
		
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
		
		fullNetwork();
	}

}
