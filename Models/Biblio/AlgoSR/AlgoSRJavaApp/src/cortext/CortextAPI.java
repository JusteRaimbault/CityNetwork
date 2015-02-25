/**
 * 
 */
package cortext;

import java.io.BufferedReader;
import java.io.FileReader;
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

import utils.Connexion;

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
			String user = (new BufferedReader(new FileReader("data/cortextUser"))).readLine();
			String password = (new BufferedReader(new FileReader("data/cortextPassword"))).readLine();
		
		    client = new DefaultHttpClient();

		    //context
		    context = new BasicHttpContext();
		    //add a cookie store to context
		    CookieStore cookieStore = new BasicCookieStore();
			context.setAttribute(ClientContext.COOKIE_STORE, cookieStore);
		    System.out.println(cookieStore.getCookies().size());
			
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
	 */
	@SuppressWarnings("resource")
	public static void uploadCorpus(String corpusPath){
		
		try{
			/**
			 *  file is posted through post to http://manager.cortext.net/jupload/server/php/index.php
			 */
			String projectDir = (new BufferedReader(new FileReader("data/cortextCorpusPath"))).readLine();
			
			HashMap<String,String> data = new HashMap<String,String>();
			data.put("projectDir",projectDir);
			HttpResponse resp = Connexion.postUpload("http://manager.cortext.net/jupload/server/php/index.php", data,corpusPath, client, context);
			
			System.out.println(new BufferedReader(new InputStreamReader(resp.getEntity().getContent())).readLine());
			//System.out.println(resp.getStatusLine());
		}catch(Exception e){e.printStackTrace();}
	}
	
	
}
