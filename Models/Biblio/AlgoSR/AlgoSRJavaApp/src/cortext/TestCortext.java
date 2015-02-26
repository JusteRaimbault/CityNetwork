/**
 * 
 */
package cortext;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.util.HashMap;

import org.apache.http.HttpResponse;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.protocol.BasicHttpContext;

import utils.Connexion;

/**
 * @author Raimbault Juste <br/> <a href="mailto:juste.raimbault@polytechnique.edu">juste.raimbault@polytechnique.edu</a>
 *
 */
public class TestCortext {

	public static void testConnexion() throws Exception{
		// try request before connection
		/*HttpResponse r = Connexion.get("http://manager.cortext.net", (new HashMap<String,String>()), (new DefaultHttpClient()), (new BasicHttpContext()));
		BufferedReader reader = new BufferedReader(new InputStreamReader(r.getEntity().getContent()));
		String currentLine = reader.readLine();System.out.println(currentLine);
		while(currentLine != null){currentLine=reader.readLine();System.out.println(currentLine);}
		 */

		CortextAPI.setupAPI();

		// same after (ie without cookies)
		/*HttpResponse r = Connexion.get("http://manager.cortext.net", (new HashMap<String,String>()), (new DefaultHttpClient()), (new BasicHttpContext()));
		BufferedReader reader = new BufferedReader(new InputStreamReader(r.getEntity().getContent()));
		String currentLine = reader.readLine();System.out.println(currentLine);
		while(currentLine != null){currentLine=reader.readLine();System.out.println(currentLine);}
		 */
		
		// not connected, as expected
		
		//try with cookie
		HttpResponse r = Connexion.get("http://manager.cortext.net/jupload/server/php/index.php", (new HashMap<String,String>()), CortextAPI.client,CortextAPI.context);
		BufferedReader reader = new BufferedReader(new InputStreamReader(r.getEntity().getContent()));
		String currentLine = reader.readLine();System.out.println(currentLine);
		while(currentLine != null){currentLine=reader.readLine();System.out.println(currentLine);}
		
		// YES, works !
		// now tests with uploads etc
		
	}
	
	public static void testUpload(){
		CortextAPI.setupAPI();
		System.out.println(CortextAPI.uploadCorpus("/Users/Juste/Documents/ComplexSystems/CityNetwork/Models/Biblio/AlgoSR/AlgoSRJavaApp/data/corpus/test.zip"));
	}
	
	
	public static void testParsingCorpus(){
		CortextAPI.setupAPI();
		CortextAPI.parseCorpus("31576");
	}
	
	
	public static void testExtractionKeywords(){
		CortextAPI.setupAPI();
		System.out.println(CortextAPI.extractKeywords("31577"));
	}
	
	
	/**
	 * @param args
	 */
	public static void main(String[] args) throws Exception{
		//connexion for single instuctions here
		CortextAPI.setupAPI();
		
		//test "API" connexion
		//testConnexion();
		
		//test file upload
		//
		testUpload();
		//OK finally works.
		//needed to delete headers !
		
		// test corpus parsing
		//testParsingCorpus();
		// ok works.
		
		//last job
		//testExtractionKeywords();
		
		//test job ID retrieving
		
		//System.out.println(CortextAPI.getLastJobId());
		//for(String s:CortextAPI.getCorpusIds()){System.out.print(s+" , ");}
		
		//test delete
		//CortextAPI.deleteAllCorpuses();
		//deletes also jobs, no need to add delete jobs function.
		
	}

}
