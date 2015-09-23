/**
 * 
 */
package test.cybergeo;

import main.Main;
import main.Reference;
import main.corpuses.Corpus;
import main.corpuses.CybergeoCorpus;
import main.corpuses.CybergeoFactory;
import scholar.ScholarAPI;
import sql.CybergeoImport;
import utils.tor.TorPool;

/**
 * @author Raimbault Juste <br/> <a href="mailto:juste.raimbault@polytechnique.edu">juste.raimbault@polytechnique.edu</a>
 *
 */
public class TestCybergeo {

	
	
	public static void testCitedRefConstruction(){
		
		//issue with tor stopping when appli stopped
		 TorPool.forceStopPID(1239,1263);
		
		 Main.setup("conf/default.conf");
		 TorPool.setupConnectionPool(25,false);
		 ScholarAPI.init();
		 CybergeoImport.setupSQL();
		 
		 CybergeoCorpus cybergeo = (CybergeoCorpus) (new CybergeoFactory("2010-01-01",2)).getCorpus();
		 
		 // test cited refs reconstruction
		 cybergeo.fillCitedRefs();
		 
		 //
		 for(Reference r:cybergeo.references){System.out.println(r.toString()+"\n CITES : ");for(Reference cr:r.cited){System.out.println(cr.toString());}}
		 
	}
	
	
	
	/**
	 * @param args
	 */
	public static void main(String[] args) {
		testCitedRefConstruction();
	}

}
