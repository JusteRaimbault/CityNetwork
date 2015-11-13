package main;

import java.io.File;
import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;

import main.reference.Reference;
import mendeley.MendeleyAPI;
import utils.CSVWriter;
import utils.Log;
import utils.RISReader;
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
	 * 
	 * TODO
	 * 
	 *   - idea : interactive shiny app where the algo can be run ; and with which we can interact at each iteration ?
	 *   -> more robustness from expert knowledge on keyword ; but beware may become a bias.
	 *    ; can either choose kept keywords and/or refs at each step ; then rerun from a given step
	 *     -> more modular iteration archi ?
	 * 
	 * 
	 */
	
	
	
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
	 * Set global variables.
	 * 
	 * TODO : refactorization/suppression of cortext requests -> not needed anymore ?
	 * 
	 * @param pathConfFile
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
			HashMap<String,String> confsMap = CSVReader.readMap(pathConfFile, ":");
			if(confsMap.containsKey("appID")){mendeleyAppId = confsMap.get("appID");}
			if(confsMap.containsKey("appSecret")){mendeleyAppSecret=confsMap.get("appSecret");}
			if(confsMap.containsKey("cortextUser")){cortextUser = confsMap.get("cortextUser");}
			if(confsMap.containsKey("cortextPassword")){cortextPassword = confsMap.get("cortextPassword");}
			if(confsMap.containsKey("cortextUserID")){cortextUserID = confsMap.get("cortextUserID");}
			if(confsMap.containsKey("cortextProjectID")){cortextProjectID = confsMap.get("cortextProjectID");}
			if(confsMap.containsKey("cortextCorpusPath")){cortextCorpusPath = confsMap.get("cortextCorpusPath");}
			
			// manage log
			if(confsMap.containsKey("logdir")){Log.initLog(confsMap.get("logdir"));}
			if(confsMap.containsKey("progress-log")){Log.initProg(confsMap.get("progress-log"));}
			
			
		}catch(Exception e){e.printStackTrace();}
	}
	
	
	
	
	/**
	 * Initialize references in that case.
	 * 
	 * (demi-iteration in fact)
	 * 
	 * @param referenceFile RIS ref file
	 * @param filePref prefix for ref,kw files
	 * @return corresponding new query from extracted keywords.
	 */
	public static String setupInitialRefs(String filePref,int kwLimit){
		
		// read file to construct refs if not done before
		// during construction refs are added to global map
		HashSet<Reference> initialRefs = RISReader.read(filePref+".ris",-1);
		
		//zip ref file
		Zipper.zip(filePref+".zip");
		
		CortextAPI.setupAPI();
		CortextAPI.deleteAllCorpuses();
		//upload corpus and get keywords
		CortextAPI.getKeywords(CortextAPI.extractKeywords(CortextAPI.parseCorpus(CortextAPI.uploadCorpus(filePref+".zip"))),filePref+"_keywords.csv");
		
		//read kw file
		String[][] kwFile = CSVReader.read(filePref+"/refs_"+filePref+"_0_keywords.csv","\t");
		
		//construct new request
		String[] stems = new String[kwFile.length-1];
		double[] cValues = new double[kwFile.length-1];
		for(int i=1;i<kwFile.length;i++){cValues[i-1]=Double.parseDouble(kwFile[i][7].replace(",", "."));stems[i-1]=kwFile[i][0].replace(" ", "+");}
		int[] perm = SortUtils.sortDesc(cValues);
		
		String query="";
		
		for(int k=0;k<kwLimit;k++){
			String sep = "";
			if(k>0){sep="+";}
			query=query+sep+stems[perm[k]];
		}
		
		return query;
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
		RISWriter.write(filePref+".ris", Reference.references.keySet(),false);
		Zipper.zip(filePref+".ris");
		
		//Cortext
		Log.newLine(1);
		Log.output("Setting up Cortext");
		CortextAPI.setupAPI();
		CortextAPI.deleteAllCorpuses();
		//upload corpus and get keywords
		CortextAPI.getKeywords(CortextAPI.extractKeywords(CortextAPI.parseCorpus(CortextAPI.uploadCorpus(filePref+".zip"))),filePref+"_keywords.csv");
		
	}
	
	
	/**
	 * Run the algorithm.
	 * 
	 * @param confFile Path to configuration file
	 * @param kwInit if true, initialization through initial set of keywords (as a string) ; else path to initial references file.
	 * @param initialConfiguration : initial catalog query OR path to reference file.
	 * 		  Rq : java is not here that adapted, can not give init function as arg.
	 * @param resFold where result files are written
	 * @param numIteration maximal number of iterations
	 * @param kwLimit keywords number to keep at each iteration.
	 */
	public static void run(String confFile,boolean kwInit,String initialConfiguration,String resFold,int numIteration,int kwLimit){
		//log to file
		//Log.initLog("/Users/Juste/Documents/ComplexSystems/CityNetwork/Models/Biblio/AlgoSR/AlgoSRJavaApp/log");
		//log to a default dir log, from where jar is called
		Log.initLog();
		
		// setup configuration
		setup(confFile);
		
		//initial query
		
		String initialQuery = initialConfiguration;
		
		if(!kwInit){initialQuery = setupInitialRefs(initialConfiguration,kwLimit);}
		
		String query = initialQuery;
		
		// run data
		String[][] keywords = new String[numIteration][kwLimit];
		int[] numRefs = new int[numIteration];
		int[][] occs = new int[numIteration][kwLimit];
		int[][] coOccs = new int[numIteration][100];
		
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
			double[] cOccValues = new double[100];//cooccs for all kw, to have full lexical coherence
			String[] stems = new String[kwFile.length-1];
			for(int i=1;i<kwFile.length;i++){cValues[i-1]=Double.parseDouble(kwFile[i][7].replace(",", "."));stems[i-1]=kwFile[i][0].replace(" ", "+");}
			int[] perm = SortUtils.sortDesc(cValues);
			//for(int i=0;i<perm.length;i++){System.out.print(cValues[perm[i]]+" ; ");}System.out.println();//DEBUG sorting
			
			for(int i=1;i<101;i++){cOccValues[i-1]=Double.parseDouble(kwFile[i][8].replace(",", "."));}
			
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
			for(int k=0;k<100;k++){coOccs[t][k]=(int)cOccValues[k];}
			
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
		String[][] stats = new String[numIteration][(2*kwLimit)+101];
		for(int t=0;t<=iterationMax;t++){
			stats[t][0]=new Integer(numRefs[t]).toString();
			for(int k=1;k<kwLimit+1;k++){stats[t][k]=keywords[t][k-1];stats[t][k+kwLimit]=new Integer(occs[t][k-1]).toString();}
			for(int k=0;k<100;k++){stats[t][k+(2*kwLimit+1)]=new Integer(coOccs[t][k]).toString();}
		}
		for(int t=iterationMax+1;t<numIteration;t++){for(int k=0;k<stats[0].length;k++){stats[t][k]=stats[iterationMax][k];}}
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
		String folder="",query="",confFile="";boolean initkw=true;
		int numIterations = 0,kwLimit=0;
		if(args.length==0){
			// for tests : store results in runs folder in results.
			folder="/Users/Juste/Documents/ComplexSystems/CityNetwork/Results/Biblio/AlgoSR/runs/run_0";
			query = "urban+geography+transportation+planning";
			numIterations = 10;kwLimit = 5;
		}
		else if(args.length>=5){
			initkw = Boolean.parseBoolean(args[1]);
			query = args[0];
			folder=args[2];
			numIterations = Integer.parseInt(args[3]);
			kwLimit = Integer.parseInt(args[4]);
			if(args.length==6){
				confFile = args[5];
			}else{//default conf file
				confFile = "/Users/Juste/Documents/ComplexSystems/CityNetwork/Models/Biblio/AlgoSR/AlgoSRJavaApp/conf/default.conf";
			}
		}
		else{throw new Exception("Error : not enough args.");}
		
		try{
		   //run("city+development+transportation+network","data/testRun",10,10);			
			//create dir if does not exists
			(new File(folder)).mkdir();
			run(confFile,initkw,query,folder,numIterations,kwLimit);
		}catch(Exception e){e.printStackTrace();Log.exception(e.getStackTrace());}
	}

}
