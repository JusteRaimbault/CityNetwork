/**
 * 
 */
package mendeley;

import java.io.File;
import java.util.HashSet;

import org.apache.commons.lang3.StringUtils;

import sql.SQLExporter;
import utils.Log;
import utils.RISReader;
import main.corpuses.CSVFactory;
import main.corpuses.Corpus;
import main.corpuses.DefaultCorpus;
import main.reference.Reference;

/**
 * @author Raimbault Juste <br/> <a href="mailto:juste.raimbault@polytechnique.edu">juste.raimbault@polytechnique.edu</a>
 *
 */
public class AbstractSetRetriever {

	/**
	 * 
	 * Fills abstracts from a csv reference file ; and outfile
	 * 
	 * @param args
	 * 
	 * args[0] : infile
	 * args[1] : outfile
	 * 
	 */
	public static void main(String[] args) {
		
		if(args.length != 2){System.out.println("Usage : ... infile outfile");}
		else{

			String refFile = args[0];
			String outFile = args[1];

			main.Main.setup();
			MendeleyAPI.setupAPI();

			Corpus initial = new DefaultCorpus();
			if(refFile.endsWith(".ris")){
				RISReader.read(refFile,-1);
				initial = new DefaultCorpus(Reference.references.keySet());
			}
			if(refFile.endsWith(".csv")){
				initial = new CSVFactory(refFile).getCorpus();
			}
			
			//load out file to get refs already retrieved in a previous run
			Corpus existing = new DefaultCorpus();
			if(new File(outFile).exists()){
				existing = new CSVFactory(outFile).getCorpus();
			}
			
			
			Corpus finalCorpus = new DefaultCorpus();
			
			for(Reference r : initial){
				
				Log.stdout(r.toString());
				if(!existing.references.contains(r)){
					Reference detailed = MendeleyAPI.getReference(r.title.title,r.year,r.scholarID);
					if(detailed!=null){
						finalCorpus.references.add(detailed);
						// export the current corpus
						finalCorpus.csvExport(outFile,true);
					}
				}
			}
			
			// export final corpus csv
			finalCorpus.csvExport(outFile,true);
			
		}
		
	}

}
