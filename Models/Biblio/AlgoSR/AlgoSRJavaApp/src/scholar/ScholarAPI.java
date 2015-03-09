/**
 * 
 */
package scholar;

import org.apache.http.HttpResponse;
import org.apache.http.client.CookieStore;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.protocol.ClientContext;
import org.apache.http.impl.client.BasicCookieStore;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.params.HttpConnectionParams;
import org.apache.http.params.HttpParams;
import org.apache.http.protocol.BasicHttpContext;
import org.apache.http.protocol.HttpContext;
import org.apache.http.util.EntityUtils;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Element;
import org.jsoup.select.Elements;

/**
 * @author Raimbault Juste <br/> <a href="mailto:juste.raimbault@polytechnique.edu">juste.raimbault@polytechnique.edu</a>
 *
 */
public class ScholarAPI {


	public static DefaultHttpClient client;
	public static HttpContext context;
	
	
	public static void setup(String query){
		try{
			
		    client = new DefaultHttpClient();

		    //context
		    context = new BasicHttpContext();
		    //add a cookie store to context
		    CookieStore cookieStore = new BasicCookieStore();
			context.setAttribute(ClientContext.COOKIE_STORE, cookieStore);
		    //System.out.println(cookieStore.getCookies().size());
			
			//set timeout
			 HttpParams params = client.getParams();
			 HttpConnectionParams.setConnectionTimeout(params, 10000);
			 HttpConnectionParams.setSoTimeout(params, 10000);
			 
			 HttpGet httpGet = new HttpGet("http://scholar.google.com");
			 //for(String k:headers.keySet()){httpGet.setHeader(k, headers.get(k));}
			 HttpResponse resp = client.execute(httpGet,context);
			 
			 
			 System.out.println("Connected to scholar, persistent through cookies : ");
			 for(int i=0;i<cookieStore.getCookies().size();i++){System.out.println(cookieStore.getCookies().get(0).toString());}
				
			 EntityUtils.consumeQuietly(resp.getEntity());
			 
			 // try successive requests without sleeping
			 for(int l=10;l<100;l=l+10){
			 
			 httpGet = new HttpGet("http://scholar.google.fr/scholar?q="+query+"&lookup=0&start="+l);
			 //for(String k:headers.keySet()){httpGet.setHeader(k, headers.get(k));}
			 resp = client.execute(httpGet,context);
			 
			 org.jsoup.nodes.Document dom = Jsoup.parse(resp.getEntity().getContent(),"UTF-8","");
			 Elements e = dom.getElementsByClass("gs_rt");
			 for(Element r:e){System.out.println(r.text());};
				// print response page
			/*	BufferedReader r = new BufferedReader(new InputStreamReader(resp.getEntity().getContent()));
				String currentLine = r.readLine();System.out.println(currentLine);
				while(currentLine != null){currentLine=r.readLine();System.out.println(currentLine);}
				*/
			 }
				
			}catch(Exception e){e.printStackTrace();}	
	}
	
	
	
	
	
	/**
	 * @param args
	 */
	public static void main(String[] args) {
		// test setup
		setup("transfer+theorem+probability");

	}

}
