/**
 * 
 */
package cortext;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.HashMap;

import org.apache.http.Header;
import org.apache.http.HttpResponse;
import org.apache.http.auth.AuthScope;
import org.apache.http.auth.UsernamePasswordCredentials;
import org.apache.http.client.CookieStore;
import org.apache.http.client.protocol.ClientContext;
import org.apache.http.impl.client.BasicCookieStore;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.protocol.BasicHttpContext;
import org.apache.http.protocol.HttpContext;
import org.apache.http.util.EntityUtils;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.select.Elements;

import utils.Connexion;
import utils.Log;

/**
 * @author Raimbault Juste <br/> <a href="mailto:juste.raimbault@polytechnique.edu">juste.raimbault@polytechnique.edu</a>
 *
 */
public class CortextAPI {


	/**
	 * Http client.
	 * 
	 * Client and context are different from Mendeley API, better separate (cookies, etc)
	 */
	public static DefaultHttpClient client;
	
	/**
	 * Http context
	 */
	public static HttpContext context;
	
	
	/**
	 * Initialize API requests, by setting client and context and connecting to Cortext (should get cookies that keep connection alive)
	 */
	@SuppressWarnings("resource")
	public static void setupAPI(){
		try{
			//System.out.println("Setting up cortext API...");
			
			String user = (new BufferedReader(new FileReader("/Users/Juste/Documents/ComplexSystems/CityNetwork/Models/Biblio/AlgoSR/AlgoSRJavaApp/data/cortextUser"))).readLine();
			String password = (new BufferedReader(new FileReader("/Users/Juste/Documents/ComplexSystems/CityNetwork/Models/Biblio/AlgoSR/AlgoSRJavaApp/data/cortextPassword"))).readLine();
		
		    client = new DefaultHttpClient();

		    //context
		    context = new BasicHttpContext();
		    //add a cookie store to context
		    CookieStore cookieStore = new BasicCookieStore();
			context.setAttribute(ClientContext.COOKIE_STORE, cookieStore);
		    //System.out.println(cookieStore.getCookies().size());
			
		    //request to login page to get connected
			//session should been kept alive ?
			HashMap<String,String> headers = new HashMap<String,String>();
			headers.put("Content-Type", "application/x-www-form-urlencoded");
			headers.put("Connection", "keep-alive");
			HashMap<String,String> data = new HashMap<String,String>();
			data.put("signin[username]", user);data.put("signin[password]",password);
			data.put("signin[remember]","on");//necessary to get connexion cookie ?
			HttpResponse resp = Connexion.post("http://manager.cortext.net/login", headers, data, client, context);
			
			EntityUtils.consumeQuietly(resp.getEntity());
			
			//System.out.println(cookieStore.getCookies().size());
			//System.out.println(cookieStore.getCookies().get(0).toString());
			//System.out.println(resp.getStatusLine().toString());
			
			// print response page
			/*BufferedReader r = new BufferedReader(new InputStreamReader(resp.getEntity().getContent()));
			String currentLine = r.readLine();System.out.println(currentLine);
			while(currentLine != null){currentLine=r.readLine();System.out.println(currentLine);}
			*/
			
		}catch(Exception e){e.printStackTrace();}
	}
	
	
	
	
	/**
	 * Upload a corpus to cortext.
	 * 
	 * Given a zipped RIS file, upload and parse it. File creation will be done externally.
	 * 
	 * @param corpusPath path to corpus .zip file.
	 * @return corpus id, needed to query parsing etc
	 */
	@SuppressWarnings("resource")
	public static String uploadCorpus(String corpusPath){
		
		try{
			/**
			 *  file is posted through post to http://manager.cortext.net/jupload/server/php/index.php
			 */
			String projectDir = (new BufferedReader(new FileReader("/Users/Juste/Documents/ComplexSystems/CityNetwork/Models/Biblio/AlgoSR/AlgoSRJavaApp/data/cortextCorpusPath"))).readLine();
			
			HashMap<String,String> data = new HashMap<String,String>();
			data.put("projectDir",projectDir);
			HttpResponse resp = Connexion.postUpload("http://manager.cortext.net/jupload/server/php/index.php", data,corpusPath, client, context);
			//consume resp
			
			//Log.output(new BufferedReader(new InputStreamReader(resp.getEntity().getContent())).readLine());
			//System.out.println(resp.getStatusLine());
			EntityUtils.consumeQuietly(resp.getEntity());
			
			
			//retrieve project page and first element in corpus tab will be the new corpus
			return getLastCreatedCorpusId();
			
		}catch(Exception e){e.printStackTrace();return null;}
		
		
		
	}
	
	
	public static String getLastCreatedCorpusId(){
		try{
			String projectId = (new BufferedReader(new FileReader("/Users/Juste/Documents/ComplexSystems/CityNetwork/Models/Biblio/AlgoSR/AlgoSRJavaApp/data/cortextProjectID"))).readLine();
			String projectPagePath ="http://manager.cortext.net/project/"+projectId;
			Document projectDom = Jsoup.parse(Connexion.get(projectPagePath, (new HashMap<String,String>()), client, context).getEntity().getContent(),"UTF-8",projectPagePath);
			Element e1 =  projectDom.getElementsByAttributeValueStarting("href", "/corpu/download/id/").first();
			if(e1 != null){return e1.attr("href").split("/")[4];}
			else{return null;}
			
		}catch(Exception e){e.printStackTrace();return null;}
	}
	
	public static String getLastJobId(){
		try{
			String projectId = (new BufferedReader(new FileReader("/Users/Juste/Documents/ComplexSystems/CityNetwork/Models/Biblio/AlgoSR/AlgoSRJavaApp/data/cortextProjectID"))).readLine();
			String projectPagePath ="http://manager.cortext.net/project/"+projectId;
			Document projectDom = Jsoup.parse(Connexion.get(projectPagePath, (new HashMap<String,String>()), client, context).getEntity().getContent(),"UTF-8",projectPagePath);
			return projectDom.getElementsByAttributeValueStarting("href", "/job/datasets/").attr("href").split("/")[3];
			
		}catch(Exception e){e.printStackTrace();return null;}
	}
	
	
	public static String[] getCorpusIds(){
		try{
			String projectId = (new BufferedReader(new FileReader("/Users/Juste/Documents/ComplexSystems/CityNetwork/Models/Biblio/AlgoSR/AlgoSRJavaApp/data/cortextProjectID"))).readLine();
			String projectPagePath ="http://manager.cortext.net/project/"+projectId;
			Document projectDom = Jsoup.parse(Connexion.get(projectPagePath, (new HashMap<String,String>()), client, context).getEntity().getContent(),"UTF-8",projectPagePath);
			Elements els = projectDom.getElementsByAttributeValueStarting("href", "/corpu/download/id/");
			String[] res = new String[els.size()];int i=0;
			for(Element e:els){
				res[i]=e.attr("href").split("/")[4];i++;
			}
			return res;
		}catch(Exception e){e.printStackTrace();return null;}
		
	}
	
	
	
	/**
	 * Delete one given corpus.
	 * curl
	 *  'sf_method=delete'
	 * 
	 * @param corpusId
	 */
	public static void deleteCorpus(String corpusId){		 
		 HashMap<String,String> data = new HashMap<String,String>();data.put("sf_method", "delete");
		 HttpResponse resp = Connexion.post("http://manager.cortext.net/corpu/delete/id/"+corpusId, (new HashMap<String,String>()),data, client, context);
		 //consume the entity entirely
		 EntityUtils.consumeQuietly(resp.getEntity());
	}
	
	
	
	/**
	 * 
	 */
	public static void deleteAllCorpuses(){
		//retrieve all corpus ids, call deleteCorpus on it
		for(String s:getCorpusIds()){
			Log.output("Deleting corpus "+s+"...");
			deleteCorpus(s);
		}
	}
	
	
	
	
	/**
	 * Execute request
	 * 
	 * curl 'http://manager.cortext.net/job' 
	 * HEADERS
	 * --data
	 *     job[id]=
	 *     job[script_path]=
	 *     job[result_path]=
	 *     job[log_path]=
	 *     job[upload_path]=
	 *     job[state]=
	 *     job[user_id]=$USER_ID
	 *     job[project_id]=$PROJECT_ID
	 *     corpusorigin=dataset
	 *     corpustype=ris (scopus)
	 *     formatting=tab separated
	 *     yearfield=
	 *     separator=***
	 *     yearfieldjson=
	 *     weights_tablename_json=
	 *     weights_tablename=
	 *     output_type=reseaulu
	 *     reinit_db=yes
	 *     job[label]=
	 *     job[corpu_id]=CORPUSID === INPUT
	 *     job[script_id]=8
	 * 
	 * @param corpusName
	 * @return id of parsed corpus as db file.
	 */
	public static String parseCorpus(String corpusID){
		try{
			String previousCorpusId = getLastCreatedCorpusId();
			
		HashMap<String,String> headers = new HashMap<String,String>();
		HashMap<String,String> data = new HashMap<String,String>();
		data.put("job[id]", "");data.put("job[script_path]", "");data.put("job[result_path]", "");data.put("job[log_path]", "");data.put("job[upload_path]", "");data.put("job[state]", "");
		data.put("job[user_id]", (new BufferedReader(new FileReader("/Users/Juste/Documents/ComplexSystems/CityNetwork/Models/Biblio/AlgoSR/AlgoSRJavaApp/data/cortextUserID"))).readLine());
		data.put("job[project_id]", (new BufferedReader(new FileReader("/Users/Juste/Documents/ComplexSystems/CityNetwork/Models/Biblio/AlgoSR/AlgoSRJavaApp/data/cortextProjectID"))).readLine());
		data.put("corpusorigin", "dataset");data.put("corpustype", "ris (scopus)");
		data.put("formatting","tab separated");data.put("yearfield","");data.put("separator", "***");data.put("yearfieldjson", "");
		data.put("weights_tablename_json", "");data.put("weights_tablename", "");
		data.put("output_type", "reseaulu");data.put("reinit_db", "yes");data.put("job[label]", "");
		data.put("job[corpu_id]", corpusID);
		data.put("job[script_id]", "8");
		//do not need response
		HttpResponse resp = Connexion.post("http://manager.cortext.net/job", headers, data, client, context);
		
		EntityUtils.consumeQuietly(resp.getEntity());
		String currentCorpusId = getLastCreatedCorpusId();
		Log.output("previous corpus : "+previousCorpusId+" - current : "+currentCorpusId);
		while(previousCorpusId.equals(currentCorpusId)){
			//sleep a little
			Log.output("Waiting for job to finish, sleep 5s...");
			Thread.sleep(5000);
			currentCorpusId = getLastCreatedCorpusId();
		}
		return currentCorpusId;
		
		}catch(Exception e){e.printStackTrace();return null;}
	}
	
	
	
	/**
	 * 
	 * curl 'http://manager.cortext.net/job'
	 *   HEADERS
	 * --data
	 *    job[id]=
	 *    job[script_path]=
	 *    job[result_path]=
	 *    job[log_path]=
	 *    job[upload_path]=
	 *    job[state]=
	 *    job[user_id]=$USER_ID
	 *    job[project_id]=$PROJECT_ID
	 *    fields_2_index[]=Abstract
	 *    fields_2_index[]=Keywords
	 *    fields_2_index[]=Title
	 *    C_value_thres=3.
	 *    nb_top=100
	 *    language=en
	 *    no_monogram=yes
	 *    advanced_settings_main=no
	 *    count_method=sentence+level
	 *    specificity_mode=chi2
	 *    method_linguistic=yes
	 *    grammaticalcriterion=noun+phrase
	 *    postagger=treetagger
	 *    lemmatization=yes
	 *    sampling=yes
	 *    sample_size=2000
	 *    auto_index=yes
	 *    indexed_table_name=
	 *    actionable=
	 *    nb_period=1
	 *    time_cut_type=homogeneous
	 *    periods=Standard+Periods
	 *    job[label]=
	 *    job[corpu_id]= CORPUS_ID (input)
	 *    job[script_id]=5
	 * 
	 */
	public static String extractKeywords(String corpusId){
		try{
			//get previous corpus id to know when script finished
			String previousCorpusId = getLastCreatedCorpusId();
			
			HashMap<String,String> headers = new HashMap<String,String>();
			HashMap<String,String> data = new HashMap<String,String>();
			data.put("job[id]", "");data.put("job[script_path]", "");data.put("job[result_path]", "");data.put("job[log_path]", "");data.put("job[upload_path]", "");data.put("job[state]", "");
			data.put("job[user_id]", (new BufferedReader(new FileReader("/Users/Juste/Documents/ComplexSystems/CityNetwork/Models/Biblio/AlgoSR/AlgoSRJavaApp/data/cortextUserID"))).readLine());
			data.put("job[project_id]", (new BufferedReader(new FileReader("/Users/Juste/Documents/ComplexSystems/CityNetwork/Models/Biblio/AlgoSR/AlgoSRJavaApp/data/cortextProjectID"))).readLine());
			data.put("fields_2_index[Abstract]","");
			//data.put("fields_2_index[Keywords]","");
			data.put("fields_2_index[Title]","");
			//data.put("fields_2_index", "[\"Abstract\", \"Keywords\", \"Title\"]");
			data.put("C_value_thres", "3.");data.put("nb_top", "100");data.put("language","en");data.put("no_monogram", "yes");data.put("advanced_settings_main", "no");
			data.put("count_method","sentence+level");data.put("specificity_mode","chi2");data.put("method_linguistic","yes");data.put("grammaticalcriterion","noun+phrase");
			data.put("postagger","treetagger");data.put("lemmatization","yes");data.put("sampling","yes");data.put("sample_size","2000");
			data.put("auto_index","yes");data.put("indexed_table_name","");data.put("actionable","");data.put("nb_period","1");
			data.put("time_cut_type","homogeneous");data.put("periods","Standard+Periods");data.put("job[label]","");
			data.put("job[corpu_id]", corpusId);
			data.put("job[script_id]", "5");
			//do not need response
			HttpResponse resp = Connexion.post("http://manager.cortext.net/job", headers, data, client, context);
			
			EntityUtils.consumeQuietly(resp.getEntity());
			String currentCorpusId = getLastCreatedCorpusId();
			Log.output("previous corpus : "+previousCorpusId+" - current : "+currentCorpusId);
			while(previousCorpusId.equals(currentCorpusId)){
				//sleep a little
				Log.output("Waiting for job to finish, sleep 5s...");
				Thread.sleep(5000);
				currentCorpusId = getLastCreatedCorpusId();
			}
			
			return currentCorpusId;
			
		}catch(Exception e){e.printStackTrace();return null;}
	}
	
	
	/**
	 * Download keyword list and saves it to given file.
	 * 
	 * Simple get.
	 * 
	 * @param corpusId
	 */
	public static void getKeywords(String corpusId,String csvFilePath){
		try{
			FileWriter writer = new FileWriter(new File(csvFilePath));
			InputStream in = Connexion.get("http://manager.cortext.net/corpu/download/id/"+corpusId, (new HashMap<String,String>()), client, context).getEntity().getContent();
		    int currentByte = in.read();
		    while(currentByte != -1){
		    	writer.write(currentByte);currentByte=in.read();
		    }
			writer.close();
		}catch(Exception e){e.printStackTrace();}
	}
	
	
	
}
