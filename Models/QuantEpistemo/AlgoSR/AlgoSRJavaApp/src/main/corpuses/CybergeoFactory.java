/**
 * 
 */
package main.corpuses;

import java.util.HashMap;
import java.util.HashSet;

import sql.CybergeoImport;
import main.reference.Reference;

/**
 * @author Raimbault Juste <br/> <a href="mailto:juste.raimbault@polytechnique.edu">juste.raimbault@polytechnique.edu</a>
 *
 */
public class CybergeoFactory implements CorpusFactory {

	private String sqlFilter;
	
	public CybergeoFactory(String minDate,int corpusSize){
		HashMap<String,String> o = new HashMap<String,String>();
		if(minDate.length()>0){o.put("min-date", minDate);}
		if(corpusSize>=0){o.put("corpus-size", (new Integer(corpusSize)).toString());}
		this.setup(o);
	}
	
	
	/**
	 * 
	 *  Manual setup.
	 *  
	 *  keys : min-date : 2003-01-01
	 *         corpus-size : int
	 *  
	 *  (non-Javadoc)
	 * @see main.corpuses.CorpusFactory#setup(java.util.HashMap)
	 */
	@Override
	public void setup(HashMap<String, String> options) {
		sqlFilter = "";
		if(options.containsKey("min-date")){sqlFilter+="WHERE  `datepubli` >=  '"+options.get("min-date")+"' ";}
		if(options.containsKey("corpus-size")){sqlFilter+="LIMIT "+options.get("corpus-size");}
	}

	/* (non-Javadoc)
	 * @see main.CorpusFactory#getCorpus()
	 */
	@Override
	public Corpus getCorpus() {
		return new CybergeoCorpus(CybergeoImport.importBase(sqlFilter));
	}

}
