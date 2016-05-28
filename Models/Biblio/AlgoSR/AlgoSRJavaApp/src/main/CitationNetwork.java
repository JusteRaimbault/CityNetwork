/**
 * 
 */
package main;

import java.io.File;
import java.util.HashSet;
import java.util.LinkedList;
import java.util.Set;

import main.corpuses.CSVFactory;
import main.corpuses.Corpus;
import main.corpuses.DefaultCorpus;
import main.reference.Reference;
import mendeley.MendeleyAPI;
import scholar.ScholarAPI;
import sql.CybergeoImport;
import sql.SQLConnection;
import utils.CSVWriter;
import utils.GEXFWriter;
import utils.RISReader;
import utils.tor.TorPool;
import utils.tor.TorPoolManager;

/**
 * 
 * Class to extract partial citation network from existing ref files
 * 
 * @author Raimbault Juste <br/> <a href="mailto:juste.raimbault@polytechnique.edu">juste.raimbault@polytechnique.edu</a>
 *
 */
public class CitationNetwork {
	
	
	/**
	 * Build first order network : foreach ref, find citing refs
	 */
	public static void buildCitationNetwork(String outFile,Corpus existing){
		for(Reference r:Reference.references.keySet()){
			if(!existing.references.contains(r)){
			  ScholarAPI.fillIdAndCitingRefs(new DefaultCorpus(r));
			  // export
			  new DefaultCorpus(Reference.references.keySet()).csvExport(outFile);
			}
		}
	}
	
	
	/**
	 * For different reference files, load each and constructs citation network.
	 * Outputs "clustering coefs" in file.
	 */
	public static void buildGeneralizedNetwork(String prefix,String[] keywords,String outPrefix,int maxIt){
		// setup
		Main.setup("conf/default.conf");
		
		TorPool.setupConnectionPool(50,false);
		
		ScholarAPI.init();
		
		//initialize orig tables and load initial references
		System.out.println("Reconstructing References from file");
		LinkedList<HashSet<Reference>> originals = new LinkedList<HashSet<Reference>>();
		for(int i=0;i<keywords.length;i++){originals.addLast(new HashSet<Reference>(RISReader.read(getLastIteration(prefix,keywords[i],maxIt),-1)));}
	
		// build the cit nw
		buildCitationNetwork("",new DefaultCorpus());
		
		// fill cluster link table
		// for each orig, look at all orig, number of citing
		//mat of strings to be easily exported to csv
		String[][] interClusterLinks = new String[keywords.length+1][keywords.length];
		//first line is header
		for(int j=0;j<keywords.length;j++){interClusterLinks[0][j]=keywords[j];}
		// fill mat - beware : not symmetrical
		for(int i=0;i<keywords.length;i++){
			for(int j=0;j<keywords.length;j++){
				int cit=0;
				for(Reference r:originals.get(i)){for(Reference c:r.citing){if(originals.get(j).contains(c)){cit++;}}}
				interClusterLinks[i+1][j]=(new Integer(cit)).toString();
			}
		}
		
		// output in csv file
		CSVWriter.write(outPrefix+".csv", interClusterLinks, ";","");
		
		// output in GEXF to be used by graph processing softwares
		GEXFWriter.writeCitationNetwork(outPrefix+".gexf", Reference.references.keySet());
		
		
		
	}
	
	
	/**
	 * Find last bib file.
	 * Structure assumed : prefix+kw+"_"+num+".ris" ; all files with same prefix.
	 * 
	 * @param prefix
	 * @param kw
	 * @param maxIt
	 * @return
	 */
	private static String getLastIteration(String prefix,String kw,int maxIt){
		int num = 0;
		File f = new File(prefix+kw+"_"+num+".ris");
		while(f.exists()&&num<=maxIt){
			f = new File(prefix+kw+"_"+num+".ris");
			num++;
		}
		return prefix+kw+"_"+(num-2)+".ris";
	}
	
	
	/**
	 * Given a RIS ref file, builds its corresponding citation network.
	 */
	public static void buildCitationNetworkFromRefFile(String refFile,String outFile,int depth,String citedFolder){
        
		Main.setup("conf/default.conf");
        try{TorPoolManager.setupTorPoolConnexion();}catch(Exception e){e.printStackTrace();}
		ScholarAPI.init();
		
		System.out.println("Reconstructing References from file "+refFile);
		
		Corpus initial = new DefaultCorpus();
		
		if(refFile.endsWith(".ris")){
			RISReader.read(refFile,-1);
			initial = new DefaultCorpus(Reference.references.keySet());
		}
		if(refFile.endsWith(".csv")){
			if(citedFolder.length()==0){
			   initial = new CSVFactory(refFile).getCorpus();
			}else{
			   initial = new CSVFactory(refFile,-1,citedFolder).getCorpus();
			}
		}
		
		//load out file to get refs already retrieved in a previous run
		Corpus existing = new DefaultCorpus();
		if(new File(outFile).exists()){
			existing = new CSVFactory(outFile).getCorpus();
		}
		
		//System.out.println("Initial Refs : ");for(Reference r:Reference.references.keySet()){System.out.println(r.toString());}
		
		for(int d=1;d<=depth;d++){
		  System.out.println("Getting Citation Network, depth "+d);
		  buildCitationNetwork(outFile,existing);
		}
		
		/*
		System.out.println("Getting Abstracts...");
		MendeleyAPI.setupAPI();
		for(Reference r:Reference.references.keySet()){
			System.out.println(r.title.replace(" ", "+"));
			//MendeleyAPI.catalogRequest(r.title.replace(" ", "+"), 1);
		}
		*/
		
		//GEXFWriter.writeCitationNetwork(outFile, Reference.references.keySet());
		
		//TorPool.stopPool();
	}
	
	
	/**
	 * Build the network 
	 */
	public static void buildCitationNetworkFromSQL(String outFile){
		
		Main.setup("conf/default.conf");
		TorPool.setupConnectionPool(50,false);
		ScholarAPI.init();
		
		//import database
		System.out.println("Setting up from sql...");
		SQLConnection.setupSQL("Cybergeo");
		Set<Reference> initialRefs = CybergeoImport.importBase("WHERE  `datepubli` >=  '2003-01-01' AND  `resume` !=  '' AND  `titre` != ''");
		System.out.println("References :  : "+Reference.references.size());
		
		
		// construct network
		buildCitationNetwork("",new DefaultCorpus());
		
        GEXFWriter.writeCitationNetwork(outFile, Reference.references.keySet());
		
		TorPool.stopPool();
		
	}
	
	
	
	
	/**
	 * @param args
	 */
	public static void main(String[] args) {
		
		
		//TorPool.forceStopPID(1971, 2020);
		
		//buildCitationNetworkFromSQL("res/citation/cybergeo.gexf");
		
		//buildCitationNetworkFromRefFile("/Users/Juste/Documents/ComplexSystems/Cybergeo/Data/processed/2003_fullbase_rawTitle.ris","res/citation/cybergeo_depth2.gexf",2);
		
		//buildCitationNetworkFromRefFile("/Users/Juste/Documents/ComplexSystems/Cybergeo/Data/processed/2003_frenchTitles_fullbase.ris","res/citation/cybergeo.gexf");
		
		/*
		//String[] keywords = {"land+use+transport+interaction","city+system+network","network+urban+modeling","population+density+transport","transportation+network+urban+growth","urban+morphogenesis+network"};
		
		String[] keywords = {"land+use+transport+interaction"};
		
		buildGeneralizedNetwork(
				"/Users/Juste/Documents/ComplexSystems/CityNetwork/Models/Biblio/AlgoSR/cit/refs_",
				keywords,
				"res/citation/citations",
				20);
				
		*/
	}

}
