/**
 *
 */
package main;

import java.io.File;
import java.io.FileWriter;
import java.util.HashSet;

import main.corpuses.CSVFactory;
import main.corpuses.Corpus;
import main.corpuses.DefaultCorpus;
import main.reference.Reference;
import scholar.ScholarAPI;
import utils.CSVReader;
import utils.tor.TorPoolManager;

/**
 * @author Raimbault Juste <br/> <a href="mailto:juste.raimbault@polytechnique.edu">juste.raimbault@polytechnique.edu</a>
 *
 */
public class KeywordsRequest {


	/**
	*  Construct a corpus from keyword request
	*/
	public static void main(String[] args) {


		if(args.length==3||args.length==4){
			String kwFile=args[0];
			String outFile=args[1];
			int numref = Integer.parseInt(args[2]);
			String addterm = "";if(args.length==4){addterm=args[3];}

			try{TorPoolManager.setupTorPoolConnexion();}catch(Exception e){e.printStackTrace();}
			ScholarAPI.init();

			// existing corpus - not needed, will go through the keywords anyway
			/*Corpus existing = new DefaultCorpus();
			if(new File(outFile).exists()){
				existing = new CSVFactory(outFile).getCorpus();
			}*/

			// parse kws file
			String[][] kwraw = CSVReader.read(kwFile, ",","\"");
			String[] reqs = new String[kwraw.length];
			for(int i=0;i<kwraw.length;i++){
				String currentreq = kwraw[i][1].replace(" ", "+");
				if(addterm.length()>0){currentreq=currentreq+"+"+addterm;}
			    reqs[i] = currentreq ;
			}

			try{(new FileWriter(new File(outFile+"_achieved.txt"))).write(kwFile+'\n');}catch(Exception e){e.printStackTrace();}

			for(String req:reqs){
				HashSet<Reference> currentrefs = ScholarAPI.scholarRequest(req, numref, "direct");
				new DefaultCorpus(Reference.references.keySet()).csvExport(outFile,false);
				// write kws in achieved file
				try{(new FileWriter(new File(outFile+"_achieved.txt"),true)).write(req+"\n");}catch(Exception e){e.printStackTrace();}
			}


		}else{
			System.out.println("usage : java -jar keywordsRequest.jar kwfile outfile numrefs [addterm]");
		}




	}

}
