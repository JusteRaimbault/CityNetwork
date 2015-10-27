/**
 * 
 */
package mendeley;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.InputStreamReader;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;

import javax.json.Json;
import javax.json.JsonArray;
import javax.json.JsonObject;
import javax.json.JsonReader;
import javax.json.JsonValue;

import org.apache.http.Header;
import org.apache.http.HttpResponse;
import org.apache.http.auth.AuthScope;
import org.apache.http.auth.UsernamePasswordCredentials;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.protocol.BasicHttpContext;
import org.apache.http.protocol.HttpContext;

import utils.Connexion;
import main.Reference;

/**
 * @author Raimbault Juste <br/> <a href="mailto:juste.raimbault@polytechnique.edu">juste.raimbault@polytechnique.edu</a>
 *
 */
public class MendeleyAPI{

	/**
	 * Http client
	 */
	public static DefaultHttpClient client;
	
	/**
	 * Http context
	 */
	public static HttpContext context;
	
	
	public static boolean isSetup = false;
	
	
	/**
	 * Initialize API requests, by setting client and context.
	 */
	@SuppressWarnings("resource")
	public static void setupAPI(){
		try{
		//System.out.println("Setting Mendeley API...");
			
		// simple client and context, no need for cookies
		//credentials and client
	    // path to appID and appSecret have to be absolute if called by jar anywhere
		//TODO eventually fix that by providing conf file storing paths
		//String appid = (new BufferedReader(new FileReader("/Users/Juste/Documents/ComplexSystems/CityNetwork/Models/Biblio/AlgoSR/AlgoSRJavaApp/data/appID"))).readLine();
		// Replaced by global variable appid
		//String appsecret = (new BufferedReader(new FileReader("/Users/Juste/Documents/ComplexSystems/CityNetwork/Models/Biblio/AlgoSR/AlgoSRJavaApp/data/appSecret"))).readLine();
		//idem
		//System.out.println(appid+" : "+appsecret);
		client = new DefaultHttpClient();
		client.getCredentialsProvider().setCredentials(AuthScope.ANY,new UsernamePasswordCredentials(main.Main.mendeleyAppId, main.Main.mendeleyAppSecret));

		//context
		context = new BasicHttpContext();
		
		isSetup=true;
		
		}catch(Exception e){e.printStackTrace();}
	}
	
	public static String getAccessToken(){
		try{
			//auth is a basic post request
			HashMap<String,String> header = new HashMap<String,String>();
			header.put("Content-Type", "application/x-www-form-urlencoded");
			
			// url
			String url = "https://api.mendeley.com/oauth/token";
			
			//post data
			HashMap<String,String> data = new HashMap<String,String>();
			data.put("grant_type", "client_credentials");
			data.put("scope", "all");
			
			HttpResponse res = Connexion.post(url,header,data,client,context);
			
			//String resp = (new BufferedReader(new InputStreamReader(res.getEntity().getContent())).readLine());
			// do not need to convert to string, as json reader can directly read string
			
			//parse json string
			JsonReader jsonReader = Json.createReader(res.getEntity().getContent());
			JsonObject object = jsonReader.readObject();
			jsonReader.close();
			
			return object.getString("access_token");
		}
		catch (Exception e) {e.printStackTrace();return null;}
	}
	
	
	
	public static HashSet<Reference> catalogRequest(String query,int numResponse){
		
		try{
			
			//get an access token
			String accessToken = getAccessToken();
			
			//simple get request
			String url = "https://api.mendeley.com/search/catalog?query="+query+"&limit="+(Integer.toString(numResponse));
			HashMap<String,String> header = new HashMap<String,String>();
			header.put("Accept", "application/vnd.mendeley-document.1+json");	
			header.put("Authorization", "Bearer "+accessToken);
			HttpResponse res = Connexion.get(url,header,client,context);
			
			//System.out.println(new BufferedReader(new InputStreamReader(res.getEntity().getContent())).readLine());
			//rq : catalog request limited to 100 responses
			// Check headers to see if next page available ?
			//for(Header h:res.getAllHeaders()){System.out.println(h.toString());}
			
			
			JsonReader jsonReader = Json.createReader(res.getEntity().getContent());
			JsonArray entries = jsonReader.readArray();
			jsonReader.close();
			
			HashSet<Reference> refs = new HashSet<Reference>();
			
			//iterate on the json object
			
			for(int i=0;i<entries.size();i++){
				JsonObject entry = entries.getJsonObject(i);
				// add reference using construct -- no scholar ID
				refs.add(Reference.construct(entry.getString("id"), entry.getString("title"), entry.getString("abstract"),Integer.toString(entry.getInt("year")),""));
			}			
			return refs;
			
		}catch(Exception e){e.printStackTrace();return null;}
	}
	
	
	/**
	 * Get abstracts for the given set of References
	 */
	public static void getAbstracts(HashSet<Reference> corpus){
		
	}
	
	

}
