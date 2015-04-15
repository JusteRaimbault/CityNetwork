/**
 * 
 */
package main;

import java.util.HashSet;

import scholar.ScholarAPI;
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
	 * @param args
	 */
	public static void main(String[] args) {
		Main.setup("conf/default.conf");ScholarAPI.setup("");
		
		// test if nw building
		RISReader.read("/Users/Juste/Documents/ComplexSystems/CityNetwork/Models/Biblio/AlgoSR/junk/refs_land+use+transport+interaction_8.ris");
		//clones table to keep original refs
		HashSet<Reference> orig = new HashSet<Reference>(Reference.references.keySet());
		buildCitationNetwork();
		//count effective links
		int links = 0;
		for(Reference r:orig){for(Reference c:r.citing){if(orig.contains(c)){links++;System.out.println(c);}}}
		System.out.println("links : "+links);
	}

}
