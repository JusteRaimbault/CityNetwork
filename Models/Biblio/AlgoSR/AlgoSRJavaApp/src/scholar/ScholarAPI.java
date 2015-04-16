/**
 * 
 */
package scholar;

import java.util.HashSet;
import java.util.regex.Pattern;

import main.Main;
import main.Reference;
import mendeley.MendeleyAPI;

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
import org.jsoup.nodes.Document;
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
	
	/**
	 * Queries and constructs citing refs for a set of refs, and fills scholar id.
	 * 
	 * Alters refs in place.
	 * 
	 * @param refs
	 */
	public static void fillIdAndCitingRefs(HashSet<Reference> refs){
		try{
			for(Reference r:refs){
				System.out.println("Getting cit for ref "+r.toString());
				// first get scholar ID
				//System.out.println(r.scholarID);
				scholarRequest(r.title.replace(" ", "+"),1);
				//System.out.println(r.scholarID);
				// while still results on cluster page, iterate
				Document dom=Jsoup.parse(client.execute(new HttpGet("http://scholar.google.fr/scholar?cites="+r.scholarID),context).getEntity().getContent(),"UTF-8","");
						
				//check if first response is empty
				//if(e.size()==0){System.out.println(dom.html());}
				
				// need to handle google blocking
				//System.out.println(dom.getElementsByClass("gs_hatr").size());
				
				dom=ensureConnection(dom,r);
				
				Elements e = dom.getElementsByClass("gs_ri");
				
				
				for(Element c:e){
			    	String cluster = getCluster(c);
		    		String title = c.getElementsByClass("gs_rt").text().replaceAll("\\[(.*?)\\]","");
		    		r.citing.add(Reference.construct("", title, "", "", cluster));
			    }
				int l=10;
				while(e.size()>0){
					dom = Jsoup.parse(client.execute(new HttpGet("http://scholar.google.fr/scholar?cites="+r.scholarID+"&start="+l),context).getEntity().getContent(),"UTF-8","");
					e = dom.getElementsByClass("gs_ri");
					for(Element c:e){
				    	String cluster = getCluster(c);
			    		String title = c.getElementsByClass("gs_rt").text().replaceAll("\\[(.*?)\\]","");
			    		r.citing.add(Reference.construct("", title, "", "", cluster));
				    }
				    //System.out.println(l);
					l=l+10;
				}
				System.out.println("Citing refs : "+r.citing.size());
			}
		}catch(Exception e){e.printStackTrace();}
	}
	
	
	
	/**
	 * Sleeps to ensure scholar connection (google blocking).
	 * 
	 * @param d
	 * @param r
	 * @return
	 */
	private static Document ensureConnection(Document d,Reference r) {
		Document dom=d;
		try{
			if(dom.getElementsByClass("gs_hatr").size()==0){
				while(dom.getElementsByClass("gs_hatr").size()==0){
				    System.out.println("Waiting for fucking google to stop blocking... sleep 5sec");
				    Thread.sleep(5000);
				    setup("");
				    //note : interfer with other APIs --> may be useful to separate them for a more stable archi.
				    dom=Jsoup.parse(client.execute(new HttpGet("http://scholar.google.fr/scholar?cites="+r.scholarID),context).getEntity().getContent(),"UTF-8","");
				}
			}
		}catch(Exception e){e.printStackTrace();}
		return dom;
	}
	
	
	/**
	 * Local function parsing a scholar response.
	 * @param refs
	 * @param e
	 * @param remResponses
	 */
	private static void addPage(HashSet<Reference> refs,Elements e,int remResponses){
		int resultsNumber = 0;
		for(Element r:e){
	    	if(resultsNumber<remResponses){
	    		//creates ref
	    		//System.out.println(r.getElementsByClass("gs_rt").text());
	    		
	    		//get citation link
	    		String cluster = getCluster(r);
	    		//get title using regex matching to eliminate types in brackets
	    		String title = r.getElementsByClass("gs_rt").text().replaceAll("\\[(.*?)\\]","");
	    		//System.out.println(cluster+" - "+title);
	    		refs.add(Reference.construct("", title, "", "", cluster));
	    		resultsNumber++;
	    	}
	    }
	}
	
	/**
	 * Get cluster from an element
	 * 
	 * @param e
	 */
	private static String getCluster(Element e){
		String cluster = "";
		try{
		   cluster = e.getElementsByAttributeValueContaining("href", "/scholar?cites=").first().attr("href").split("scholar?")[1].split("cites=")[1].split("&")[0];
		}catch(NullPointerException nu){
			
			//null pointer -> not cited, try "versions" link to get cluster
			try{cluster = e.getElementsByAttributeValueContaining("href", "/scholar?cluster=").first().attr("href").split("scholar?")[1].split("cluster=")[1].split("&")[0];}
			catch(Exception nu2){}
		}
		return cluster;
	}
	
	
	/**
	 * @param args
	 */
	public static void main(String[] args) {
		// test setup
		setup("");
		
		// test request
		//HashSet<Reference> refs = scholarRequest("Co-evolution+of+density+and+topology+in+a+simple+model+of+city+formation",1);
		//for(Reference r:refs){System.out.println(r);}
		//fillIdAndCitingRefs(refs);
		//for(Reference r:refs){System.out.println(r);for(Reference c:r.citing){System.out.println(c);}}
		
		// test to fill a mendeley ref
		Main.setup("/Users/Juste/Documents/ComplexSystems/CityNetwork/Models/Biblio/AlgoSR/AlgoSRJavaApp/conf/default.conf");
		
		MendeleyAPI.setupAPI();
		HashSet<Reference> refs = MendeleyAPI.catalogRequest("transportation+network", 1);
		fillIdAndCitingRefs(refs);
		for(Reference r:refs){System.out.println(r);for(Reference c:r.citing){System.out.println(c);}}
	}

}
