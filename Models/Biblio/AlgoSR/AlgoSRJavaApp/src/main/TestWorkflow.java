/**
 * 
 */
package main;

import java.util.HashSet;

import utils.RISWriter;
import utils.Zipper;
import cortext.CortextAPI;
import mendeley.MendeleyAPI;

/**
 * Class to test coupling Mendeley/cortext.
 * 
 * @author Raimbault Juste <br/> <a href="mailto:juste.raimbault@polytechnique.edu">juste.raimbault@polytechnique.edu</a>
 *
 */
public class TestWorkflow {

	/**
	 * Simple workflow from a search query.
	 * 
	 * @param searchQuery
	 */
	public static void simpleWorkflow(String searchQuery){
		
	
		// setup mendeley
		System.out.println("Setting up Mendeley...");
		MendeleyAPI.setupAPI();
		
		// construct 100 references from catalog request
		System.out.println("Catalog request : "+searchQuery);
		HashSet<Reference> refs = MendeleyAPI.catalogRequest(searchQuery,100);
		
		//export them to ris and zip
		RISWriter.write("data/testSimpleWorkflow/refs.ris", refs);
		Zipper.zip("data/testSimpleWorkflow/refs.ris");
		
		//Cortext
		CortextAPI.setupAPI();
		//upload corpus
		CortextAPI.getKeywords(CortextAPI.extractKeywords(CortextAPI.parseCorpus(CortextAPI.uploadCorpus("data/testSimpleWorkflow/refs.zip"))),"data/testSimpleWorkflow/keywords.csv");
		
	}
	
	
	/**
	 * @param args
	 */
	public static void main(String[] args) {
		simpleWorkflow("urban+system");
	}

}
