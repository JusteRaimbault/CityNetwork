package main;

import java.io.File;
import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;

import mendeley.MendeleyAPI;
import utils.CSVWriter;
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
	 * Absolute path to file containing different API access ids and codes
	 * File must ABSOLUTELY be protected (although readable by application), e.g. if in git repository, imperatively has to be put in .gitignore
	 */
	public static String mendeleyAppId;
	public static String mendeleyAppSecret;
	public static String cortextUser;
	public static String cortextUserID;
	public static String cortextProjectID;
	public static String cortextCorpusPath;
	public static String cortextPassword;
	
	/**
	 * Set global variables
	 */
	public static void setup(String pathConfFile){
		//read conf file of the form
		/**
		 * appId:id
		 * appSecret:''
		 * ...
		 * 
		 */
		try{
			String[][] confs = CSVReader.read(pathConfFile, ":");
			//for(int i=0;i<confs.length;i++){for(int j=0;j<confs[i].length;j++){System.out.print(confs[i][j] + " - ");}System.out.println();}
			HashMap<String,String> confsMap = new HashMap<String,String>();
			for(int r=0;r<confs.length;r++){
				confsMap.put(confs[r][0], confs[r][1]);
			}
			mendeleyAppId = confsMap.get("appID");mendeleyAppSecret=confsMap.get("appSecret");
			cortextUser = confsMap.get("cortextUser");cortextPassword = confsMap.get("cortextPassword");
			cortextUserID = confsMap.get("cortextUserID");cortextProjectID = confsMap.get("cortextProjectID");
			cortextCorpusPath = confsMap.get("cortextCorpusPath");
		}catch(Exception e){e.printStackTrace();}
	}
	
	
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
	
	
	
	public static void run(String confFile,String initialQuery,String resFold,int numIteration,int kwLimit){
		//log to file
		//Log.initLog("/Users/Juste/Documents/ComplexSystems/CityNetwork/Models/Biblio/AlgoSR/AlgoSRJavaApp/log");
		//log to a default dir log, from where jar is called
		Log.initLog();
		
		// setup configuration
		setup(confFile);
		
		//initial query
		String query = initialQuery;
		
		// run data
		String[][] keywords = new String[numIteration][kwLimit];
		int[] numRefs = new int[numIteration];
		int[][] occs = new int[numIteration][kwLimit];
		
		int iterationMax = numIteration-1;
		for(int t=0;t<numIteration;t++){
			//get query and extract keywords
			Log.newLine(1);Log.output("Iteration "+t);Log.output("===================");
			
			int currentRefNumber = Reference.references.size();
			iteration(query,resFold+"/refs_"+initialQuery+"_"+t);
			
			//read kw from file, construct new query
			String[][] kwFile = CSVReader.read(resFold+"/refs_"+initialQuery+"_"+t+"_keywords.csv","\t");
			
			
			
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
				keywords[t][k] = stems[perm[k]];
				occs[t][k] =  (int)cValues[perm[k]];
			}
			
			Log.output("New query is : "+query);
			
			//memorize stats
			// num of refs ; num kws ; C-values (of all ?)
			numRefs[t] = Reference.references.size();
						
			for(int k=0;k<kwLimit;k++){Log.output(keywords[t][k]+" : "+occs[t][k],"debug");}
			
			// check stopping condition AFTER storing kws
			if(Reference.references.size()==currentRefNumber){
				Log.output("Convergence criteria : no new ref reached - "+Reference.references.size()+" refs.");
				Log.output("Stopping algorithm");
				iterationMax = t;
				break;
			}
			
			
		}
		
		//write stats to result file
		String[][] stats = new String[numIteration][(2*kwLimit)+1];
		for(int t=0;t<=iterationMax;t++){
			stats[t][0]=new Integer(numRefs[t]).toString();
			for(int k=1;k<kwLimit+1;k++){stats[t][k]=keywords[t][k-1];stats[t][k+kwLimit]=new Integer(occs[t][k-1]).toString();}
			
		}
		for(int t=iterationMax+1;t<numIteration;t++){for(int k=0;k<(2*kwLimit+1);k++){stats[t][k]=stats[iterationMax][k];}}
		CSVWriter.write(resFold+"/stats.csv", stats, ";");
	}
	
	
	
	/**
	 * @param args
	 *   * no args : query and folder provided in function
	 *   * args.length == 2 : args[0] = query ; args[1] = folder ;
	 *      args[2] = num iterations ; args[3] = kw limit
	 *   
	 * 
	 */
	public static void main(String[] args) throws Exception {
		
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
		String folder="",query="",confFile="";
		int numIterations = 0,kwLimit=0;
		if(args.length==0){
			// for tests : store results in runs folder in results.
			folder="/Users/Juste/Documents/ComplexSystems/CityNetwork/Results/Biblio/AlgoSR/runs/run_0";
			query = "urban+geography+transportation+planning";
			numIterations = 10;kwLimit = 5;
		}
		else if(args.length>=4){
			query = args[0];
			folder=args[1];
			numIterations = Integer.parseInt(args[2]);
			kwLimit = Integer.parseInt(args[3]);
			if(args.length==5){
				confFile = args[4];
			}else{//default conf file
				confFile = "/Users/Juste/Documents/ComplexSystems/CityNetwork/Models/Biblio/AlgoSR/AlgoSRJavaApp/conf/default.conf";
			}
		}
		else{throw new Exception("Error : not enough args.");}
		
		try{
		   //run("city+development+transportation+network","data/testRun",10,10);			
			//create dir if does not exists
			(new File(folder)).mkdir();
			run(confFile,query,folder,numIterations,kwLimit);
		}catch(Exception e){e.printStackTrace();Log.exception(e.getStackTrace());}
	}

}
