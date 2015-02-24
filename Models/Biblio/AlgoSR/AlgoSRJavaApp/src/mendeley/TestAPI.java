/**
 * 
 */
package mendeley;

import java.io.IOException;
import java.util.HashMap;

import org.apache.http.HttpResponse;
import org.apache.http.protocol.BasicHttpContext;
import org.apache.http.protocol.HttpContext;

import utils.Connexion;

/**
 * @author Raimbault Juste <br/> <a href="mailto:juste.raimbault@polytechnique.edu">juste.raimbault@polytechnique.edu</a>
 *
 */
public class TestAPI {

	public static void testAuth(){
		//auth is a basic post request
		HashMap<String,String> header = new HashMap<String,String>();
		header.put("Content-Type", "application/x-www-form-urlencoded");
		
		// url
		String url = "https://api.mendeley.com/oauth/token";
		
		//post data
		HashMap<String,String> data = new HashMap<String,String>();
		data.put("grant_type", "client_credentials");
		data.put("scope", "all");
		
		//context
		HttpContext context = new BasicHttpContext();
		
		HttpResponse res = Connexion.post(url,header,data,context);
		
		try {
			System.out.println(res.getEntity().getContent());
		} catch (Exception e) {e.printStackTrace();}
	}
	
	/**
	 * @param args
	 */
	public static void main(String[] args) {
		
		// test token request
		testAuth();

	}

}
