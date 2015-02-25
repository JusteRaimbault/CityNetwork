/**
 * 
 */
package cortext;

import java.io.BufferedReader;
import java.io.FileReader;

import org.apache.http.auth.AuthScope;
import org.apache.http.auth.UsernamePasswordCredentials;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.protocol.BasicHttpContext;
import org.apache.http.protocol.HttpContext;

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
		//System.out.println(appid+" : "+appsecret);
		client = new DefaultHttpClient();
		client.getCredentialsProvider().setCredentials(AuthScope.ANY,new UsernamePasswordCredentials(appid, appsecret));

		//context
		context = new BasicHttpContext();
		
		}catch(Exception e){e.printStackTrace();}
	}
	
	
}
