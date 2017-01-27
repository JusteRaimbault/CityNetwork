/**
 * 
 */
package main.corpuses;

import java.util.HashMap;

import main.reference.Abstract;
import main.reference.Reference;
import main.reference.Title;
import utils.CSVReader;

/**
 * @author Raimbault Juste <br/> <a href="mailto:juste.raimbault@polytechnique.edu">juste.raimbault@polytechnique.edu</a>
 *
 */
public class CSVFactory implements CorpusFactory {

	private String bibfile;
	
	private int numRefs;
	
	private String citedFolder;
	
	public CSVFactory(String file){
		bibfile=file;numRefs=-1;citedFolder="";
	}
	
	public CSVFactory(String file,int refs){
		bibfile=file;numRefs=refs;citedFolder="";
	}
	
	public CSVFactory(String file,int refs,String cited){
		bibfile=file;numRefs=refs;citedFolder=cited;
	}
	
	/* (non-Javadoc)
	 * @see main.corpuses.CorpusFactory#setup(java.util.HashMap)
	 */
	@Override
	public void setup(HashMap<String, String> options) {
		if(options.keySet().contains("bib-file")){
			bibfile=options.get("bib-file");
		}
	}

	/* (non-Javadoc)
	 * @see main.corpuses.CorpusFactory#getCorpus()
	 */
	@Override
	public Corpus getCorpus() {
		// assumes a simple csv file : title,ID
		Corpus res = new DefaultCorpus();
		String[][] refs = CSVReader.read(bibfile, ";","\"");
		if(refs[0].length>1){
			if(numRefs==-1){numRefs=refs.length;}
			for(int i = 0;i<numRefs;i++){
				String id = refs[i][1];
				if(id!="NA"){
					Reference r = Reference.construct("",new Title(refs[i][0]),new Abstract(), "",id);
					res.references.add(r);
					if(citedFolder!=""){//if must construct cited corpus
						r.biblio.cited = (new CSVFactory(citedFolder+(new Integer(i+1)).toString(),-1)).getCorpus().references;
					}
				}
			}
		}
		return res;
	}

}
