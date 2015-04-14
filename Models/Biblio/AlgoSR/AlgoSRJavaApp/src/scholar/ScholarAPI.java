/**
 * 
 */
package scholar;

import java.util.HashSet;
import java.util.regex.Pattern;

import main.Reference;

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

import utils.Log;

/**
 * @author Raimbault Juste <br/> <a href="mailto:juste.raimbault@polytechnique.edu">juste.raimbault@polytechnique.edu</a>
 *
 */
public class ScholarAPI {


	public static DefaultHttpClient client;
	public static HttpContext context;
	
	/**
	 * 
	 * Make a scholar request to be connected through cookies.
	 * 
	 * @param query - is the query necessary ?
	 * 
	 */
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
			 
			 
			 System.out.println("Connected to scholar, persistent through cookies. ");
			 //for(int i=0;i<cookieStore.getCookies().size();i++){System.out.println(cookieStore.getCookies().get(0).toString());}
				
			 EntityUtils.consumeQuietly(resp.getEntity());
			 
				
			}catch(Exception e){e.printStackTrace();}	
	}
	
	
	/**
	 * Get references from a scholar request - citations not filled for more flexibility.
	 * 
	 * @param request
	 * @param maxNumResponses
	 * @return
	 */
	public static HashSet<Reference> scholarRequest(String request,int maxNumResponses){
		HashSet<Reference> refs = new HashSet<Reference>();
		
		try{
			//first request and define vars
			HttpGet httpGet = new HttpGet("http://scholar.google.fr/scholar?q="+request);
			HttpResponse resp = client.execute(httpGet,context);
			org.jsoup.nodes.Document dom = Jsoup.parse(resp.getEntity().getContent(),"UTF-8","");
			
			// a query result is elements of class gs_ri
			Elements e = dom.getElementsByClass("gs_ri");
			
			
		    addPage(refs,e,maxNumResponses);
			int resultsNumber = refs.size();
		    
		    // No need to consume here
		    //EntityUtils.consumeQuietly(resp.getEntity());
		    
			 // try successive requests without sleeping
		     // iterate previous operation with start option in query
		     
			 for(int l=10;l<maxNumResponses;l=l+10){
			     httpGet = new HttpGet("http://scholar.google.fr/scholar?q="+request+"&lookup=0&start="+l);
			     resp = client.execute(httpGet,context);
			     // construct dom
			     dom = Jsoup.parse(resp.getEntity().getContent(),"UTF-8","");
			     e = dom.getElementsByClass("gs_ri");
			     addPage(refs,e,maxNumResponses-resultsNumber);
			     resultsNumber = refs.size();
			 }
		}catch(Exception e){e.printStackTrace();}
		
		return refs;
	}
	
	
	private static void addPage(HashSet<Reference> refs,Elements e,int remResponses){
		int resultsNumber = 0;
		for(Element r:e){
	    	if(resultsNumber<remResponses){
	    		//creates ref
	    		//System.out.println(r.getElementsByClass("gs_rt").text());
	    		
	    		//get citation link
	    		String cluster = r.getElementsByAttributeValueContaining("href", "/scholar?cites=").first().attr("href").split("scholar?")[1].split("cites=")[1].split("&")[0];
	    		//get title using regex matching to eliminate types in brackets
	    		String title = r.getElementsByClass("gs_rt").text().replaceAll("\\[(.*?)\\]","");
	    		//System.out.println(cluster+" - "+title);
	    		refs.add(Reference.construct("", title, "", "", cluster));
	    		resultsNumber++;
	    	}
	    }
	}
	
	
	
	/**
	 * @param args
	 */
	public static void main(String[] args) {
		// test setup
		setup("");
		
		// test request
		HashSet<Reference> refs = scholarRequest("transportation+network",50);
		for(Reference r:refs){System.out.println(r);}
		
	}

}
