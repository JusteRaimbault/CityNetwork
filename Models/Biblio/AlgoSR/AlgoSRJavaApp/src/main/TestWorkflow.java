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
	public static void simpleWorkflow(String searchQuery,String filePref){
		
		// setup mendeley
		System.out.println("Setting up Mendeley...");
		MendeleyAPI.setupAPI();
		
		// construct 100 references from catalog request
		System.out.println("Catalog request : "+searchQuery);
		HashSet<Reference> refs = MendeleyAPI.catalogRequest(searchQuery,100);
		
		//export them to ris and zip
		RISWriter.write(filePref+".ris", refs);
		Zipper.zip(filePref+".ris");
		
		//Cortext
		CortextAPI.setupAPI();
		CortextAPI.deleteAllCorpuses();
		//upload corpus
		CortextAPI.getKeywords(CortextAPI.extractKeywords(CortextAPI.parseCorpus(CortextAPI.uploadCorpus(filePref+".zip"))),filePref+"_keywords.csv");
		
	}
	
	
	
	public static void iterativeWorkflow(String initialQuery,String resFold,int numIteration){
		String query = initialQuery;
		for(int t=0;t<numIteration;t++){
			simpleWorkflow(query,resFold+"/refs_"+t);
			//get new query through keywords
			
		}
	}
	
	
	
	
	
	/**
	 * @param args
	 */
	public static void main(String[] args) {
		//simpleWorkflow("urban+sprawl+transportation+network","test_2");
		iterativeWorkflow("urban+sprawl+transportation+network","testIterative",4);
	}

}
