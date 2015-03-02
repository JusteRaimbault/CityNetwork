package main;

import java.io.File;
import java.util.Arrays;
import java.util.HashSet;

import mendeley.MendeleyAPI;
import utils.Log;
import utils.RISWriter;
import utils.SortUtils;
import utils.Zipper;
import utils.CSVReader;
import cortext.CortextAPI;

/**
 * @author Raimbault Juste <br/> <a href="mailto:juste.raimbault@polytechnique.edu">juste.raimbault@polytechnique.edu</a>
 *
 */
public class Main {

	
	/**
	 * One iteration of request and extraction parts of the algo, given query.
	 * 
	 * @param searchQuery
	 * @param filePref
	 */
	public static void iteration(String searchQuery,String filePref){

		// setup mendeley
		Log.output("Setting up Mendeley...");
		MendeleyAPI.setupAPI();
		
		// construct 100 references from catalog request
		Log.output("Catalog request : "+searchQuery);
		MendeleyAPI.catalogRequest(searchQuery,100);
		Log.output(Reference.references.keySet().size()+" refs in table");
		
		//export them to ris and zip
		Log.output("Writing to ris and zipping...");
		RISWriter.write(filePref+".ris", Reference.references.keySet());
		Zipper.zip(filePref+".ris");
		
		//Cortext
		Log.newLine(1);
		Log.output("Setting up Cortext");
		CortextAPI.setupAPI();
		CortextAPI.deleteAllCorpuses();
		//upload corpus and get keywords
		CortextAPI.getKeywords(CortextAPI.extractKeywords(CortextAPI.parseCorpus(CortextAPI.uploadCorpus(filePref+".zip"))),filePref+"_keywords.csv");
		
	}
	
	
	
	public static void run(String initialQuery,String resFold,int numIteration,int kwLimit){
		//log to file
		Log.initLog();
		
		//initial query
		String query = initialQuery;
		
		for(int t=0;t<numIteration;t++){
			//get query and extract keywords
			Log.newLine(1);Log.output("Iteration "+t);
			
			int currentRefNumber = Reference.references.size();
			iteration(query,resFold+"/refs_"+t);
			if(Reference.references.size()==currentRefNumber){
				Log.output("Convergence criteria : no new ref reached - "+Reference.references.size()+" refs.");
				Log.output("Stopping algorithm");
				break;
			}
			
			//read kw from file, construct new query
			String[][] kwFile = CSVReader.read(resFold+"/refs_"+t+"_keywords.csv","\t");
			
			
			
			//sort kw on occurences, keep most frequent.
			double[] cValues = new double[kwFile.length-1];
			String[] stems = new String[kwFile.length-1];
			for(int i=1;i<kwFile.length;i++){cValues[i-1]=Double.parseDouble(kwFile[i][7].replace(",", "."));stems[i-1]=kwFile[i][0].replace(" ", "+");}
			int[] perm = SortUtils.sortDesc(cValues);
			//for(int i=0;i<perm.length;i++){System.out.print(cValues[perm[i]]+" ; ");}System.out.println();//DEBUG sorting
			
			//construct new request
			query="";
			
			for(int k=0;k<kwLimit;k++){
				//System.out.println(cValues[perm[k]]);
				//System.out.println(stems[perm[k]]);
				String sep = "";
				if(k>0){sep="+";}
				query=query+sep+stems[perm[k]];
			}
			
			Log.output("New query is : "+query);
			
			//memorize stats
			// num of refs ; num kws ; C-values (of all ?)
			
			
		}
		
		//write stats to result file
		
	}
	
	
	
	/**
	 * @param args
	 */
	public static void main(String[] args) {
		
		/**
		 * First Results and Tests on algo :
		 *     - many duplicates, have to work more precisely on hashcode for Reference class : OK. (increases complexity but still ok)
		 *     
		 * 	   - stationarity is really unstable ? if a keyword is dominant in a large set of refs, will converge very rapidly ?
		 * 			--> TODO study sensitivity to initial query.
		 * 
		 * 	   - TODO : sensitivity to request constraint ? --> requires a scholar API, not yet.
		 * 
		 * 	   - 
		 */
		
		try{
		   //run("city+development+transportation+network","data/testRun",10,10);
			// for tests : store results in runs folder in results.
			String folder="/Users/Juste/Documents/ComplexSystems/CityNetwork/Results/Biblio/AlgoSR/runs/run_0";
			(new File(folder)).mkdir();
			run("urban+geography+transportation+planning",folder,10,5);
		}catch(Exception e){e.printStackTrace();Log.exception(e.getStackTrace());}
	}

}
