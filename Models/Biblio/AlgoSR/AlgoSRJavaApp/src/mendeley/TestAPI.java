/**
 * 
 */
package mendeley;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.HashMap;

import javax.json.Json;
import javax.json.JsonObject;
import javax.json.JsonReader;

import org.apache.http.HttpResponse;
import org.apache.http.auth.AuthScope;
import org.apache.http.auth.Credentials;
import org.apache.http.auth.UsernamePasswordCredentials;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.protocol.BasicHttpContext;
import org.apache.http.protocol.HttpContext;

import utils.Connexion;

/**
 * @author Raimbault Juste <br/> <a href="mailto:juste.raimbault@polytechnique.edu">juste.raimbault@polytechnique.edu</a>
 *
 */
public class TestAPI {

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
			
			//credentials and client
			String appid = (new BufferedReader(new FileReader("data/appID"))).readLine();
			String appsecret = (new BufferedReader(new FileReader("data/appSecret"))).readLine();
			System.out.println(appid+" : "+appsecret);
			DefaultHttpClient client = new DefaultHttpClient();
			client.getCredentialsProvider().setCredentials(AuthScope.ANY,new UsernamePasswordCredentials(appid, appsecret));
			
			
			//context
			HttpContext context = new BasicHttpContext();
			
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
	
	/**
	 * @param args
	 */
	public static void main(String[] args) {
		
		// test token request
		System.out.println(getAccessToken());

	}

}
