/**
 * 
 */
package main;

import java.io.File;
import java.util.HashSet;
import java.util.LinkedList;

import scholar.ScholarAPI;
import utils.CSVWriter;
import utils.RISReader;

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
	public static void buildCitationNetwork(){
		ScholarAPI.fillIdAndCitingRefs(new HashSet<Reference>(Reference.references.keySet()));
	}
	
	
	/**
	 * For different reference files, load each and constructs citation network.
	 * Outputs "clustering coefs" in file.
	 */
	public static void buildGeneralizedNetwork(String prefix,String[] keywords,String outFile,int maxIt){
		// setup
		Main.setup("conf/default.conf");
		ScholarAPI.setup("");
		
		//initialize orig tables and load initial references
		LinkedList<HashSet<Reference>> originals = new LinkedList<HashSet<Reference>>();
		for(int i=0;i<keywords.length;i++){originals.addLast(new HashSet<Reference>(RISReader.read(getLastIteration(prefix,keywords[i],maxIt))));}
	
		// build the cit nw
		buildCitationNetwork();
		
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
		CSVWriter.write(outFile, interClusterLinks, ";");
		
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
	 * @param args
	 */
	public static void main(String[] args) {
		String[] keywords = {"land+use+transport+interaction","city+system+network","network+urban+modeling","population+density+transport","transportation+network+urban+growth","urban+morphogenesis+network"};
		buildGeneralizedNetwork("/Users/Juste/Documents/ComplexSystems/CityNetwork/Models/Biblio/AlgoSR/junk/refs_",keywords,"nw.csv",20);
		/*Main.setup("conf/default.conf");ScholarAPI.setup("");
		
		// test if nw building
		RISReader.read("/Users/Juste/Documents/ComplexSystems/CityNetwork/Models/Biblio/AlgoSR/junk/refs_land+use+transport+interaction_8.ris");
		//clones table to keep original refs
		HashSet<Reference> orig = new HashSet<Reference>(Reference.references.keySet());
		buildCitationNetwork();
		//count effective links
		int links = 0;
		for(Reference r:orig){for(Reference c:r.citing){if(orig.contains(c)){links++;System.out.println(c);}}}
		System.out.println("links : "+links);*/
	}

}
