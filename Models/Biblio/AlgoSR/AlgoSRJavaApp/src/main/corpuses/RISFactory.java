/**
 * 
 */
package main.corpuses;

import java.util.HashMap;

import utils.RISReader;

/**
 * @author Raimbault Juste <br/> <a href="mailto:juste.raimbault@polytechnique.edu">juste.raimbault@polytechnique.edu</a>
 *
 */
public class RISFactory implements CorpusFactory {

	/**
	 * path to bib file
	 */
	private String bibFile;
	
	/**
	 * user defined number of refs
	 *  -1 : all
	 */
	private int corpusSize;
	
	
	public RISFactory(String f){
		HashMap<String,String> o = new HashMap<String,String>();
		o.put("bib-file", f);
		this.setup(o);
	}
	
	public RISFactory(String f,int s){
		HashMap<String,String> o = new HashMap<String,String>();
		o.put("bib-file", f);o.put("corpus-size", new Integer(s).toString());
		this.setup(o);
	}
	
	/**
	 * keys : bib-file
	 *  
	 *  (non-Javadoc)
	 * @see main.corpuses.CorpusFactory#setup(java.util.HashMap)
	 */
	@Override
	public void setup(HashMap<String, String> options) {
		if(options.containsKey("bib-file")){bibFile=options.get("bib-file");}
		if(options.containsKey("corpus-size")){
			corpusSize=Integer.parseInt(options.get("corpus-size"));
		}else{corpusSize = -1;}
	}

	/* (non-Javadoc)
	 * @see main.corpuses.CorpusFactory#getCorpus()
	 */
	@Override
	public Corpus getCorpus() {
		return new DefaultCorpus(RISReader.read(bibFile,corpusSize));
	}

}
