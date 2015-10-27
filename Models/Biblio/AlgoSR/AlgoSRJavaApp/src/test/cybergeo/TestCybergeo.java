/**
 * 
 */
package test.cybergeo;

import main.Main;
import main.Reference;
import main.corpuses.Corpus;
import main.corpuses.CybergeoCorpus;
import main.corpuses.CybergeoFactory;
import main.corpuses.RISFactory;
import scholar.ScholarAPI;
import sql.CybergeoImport;
import utils.RISWriter;
import utils.tor.TorPool;
import utils.tor.TorPoolManager;

/**
 * @author Raimbault Juste <br/> <a href="mailto:juste.raimbault@polytechnique.edu">juste.raimbault@polytechnique.edu</a>
 *
 */
public class TestCybergeo {

	
	public static void exportCybergeoAsRIS(){
		CybergeoImport.setupSQL();
		CybergeoCorpus cybergeo = (CybergeoCorpus) (new CybergeoFactory("",-1)).getCorpus();
		RISWriter.write(System.getenv("CS_HOME")+"/Cybergeo/cybergeo20/Data/bib/fullbase_withRefs.ris", cybergeo.references);
	}
	
	
	public static Corpus setupTest(){

		 Main.setup("conf/default.conf");
		 try{TorPoolManager.setupTorPoolConnexion();}catch(Exception e){e.printStackTrace();}
		 ScholarAPI.init();
		 
		 //CybergeoImport.setupSQL();
		 
		 //CybergeoCorpus cybergeo = (CybergeoCorpus) (new CybergeoFactory("2010-01-01",2)).getCorpus();
		 return new CybergeoCorpus((new RISFactory(System.getenv("CS_HOME")+"/Cybergeo/cybergeo20/Data/bib/fullbase_withRefs.ris",-1)).getCorpus().references);
			 
	}
	
	
	public static void testCitedRefConstruction(){
		
		 CybergeoCorpus cybergeo = (CybergeoCorpus) setupTest();
		 // test cited refs reconstruction
		 cybergeo.fillCitedRefs();
		 
		 //
		 for(Reference r:cybergeo.references){System.out.println(r.toString()+"\n CITES : ");for(Reference cr:r.citing){System.out.println(cr.toString());}}
		 
	}
	
	
	public static void testCitingRefs(){
		 CybergeoCorpus cybergeo = (CybergeoCorpus) setupTest();
		 System.out.println("Corpus size : "+Reference.references.keySet().size());	
		 cybergeo.getCitingRefs();
		 cybergeo.gexfExport(System.getenv("CS_HOME")+"/Cybergeo/Data/processed/networks/test_citingNW.gexf");
	}
	
	
	
	/**
	 * @param args
	 */
	public static void main(String[] args) {
		//exportCybergeoAsRIS();
		
		// check ris export
		//CybergeoCorpus cybergeo = new CybergeoCorpus((new RISFactory(System.getenv("CS_HOME")+"/Cybergeo/cybergeo20/Data/bib/fullbase.ris",10)).getCorpus().references);
		/*
		for(Reference r:cybergeo.references){
			System.out.println(r.toString());
			//System.out.println(r.toString()+"\n CITES : ");for(Reference cr:r.cited){System.out.println(cr.toString());}
		}
		*/
		
		//testCitedRefConstruction();
		
		testCitingRefs();
		
	}

}
