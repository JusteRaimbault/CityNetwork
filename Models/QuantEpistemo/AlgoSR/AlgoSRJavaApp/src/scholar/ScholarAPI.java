/**
 * 
 */
package scholar;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.InetSocketAddress;
import java.net.Proxy;
import java.net.Socket;
import java.util.HashSet;
import java.util.regex.Pattern;

import javax.net.ssl.SSLContext;

import main.Main;
import main.corpuses.Corpus;
import main.reference.Abstract;
import main.reference.Reference;
import main.reference.Title;
import mendeley.MendeleyAPI;

import org.apache.commons.lang3.StringUtils;
import org.apache.http.HttpHost;
import org.apache.http.HttpResponse;
import org.apache.http.client.CookieStore;
import org.apache.http.client.methods.CloseableHttpResponse;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.protocol.ClientContext;
import org.apache.http.client.protocol.HttpClientContext;
import org.apache.http.client.utils.URIUtils;
import org.apache.http.config.Registry;
import org.apache.http.config.RegistryBuilder;
import org.apache.http.conn.params.ConnRoutePNames;
import org.apache.http.conn.socket.ConnectionSocketFactory;
import org.apache.http.conn.socket.PlainConnectionSocketFactory;
import org.apache.http.conn.ssl.SSLConnectionSocketFactory;
import org.apache.http.impl.client.BasicCookieStore;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.impl.conn.PoolingHttpClientConnectionManager;
import org.apache.http.params.HttpConnectionParams;
import org.apache.http.params.HttpParams;
import org.apache.http.protocol.BasicHttpContext;
import org.apache.http.protocol.HttpContext;
import org.apache.http.ssl.SSLContexts;
import org.apache.http.util.EntityUtils;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.select.Elements;
import org.apache.commons.httpclient.util.URIUtil;

import utils.Log;
import utils.tor.TorPool;
import utils.tor.TorPoolManager;
import utils.tor.TorThread;

/**
 * @author Raimbault Juste <br/> <a href="mailto:juste.raimbault@polytechnique.edu">juste.raimbault@polytechnique.edu</a>
 *
 */
public class ScholarAPI {


	public static DefaultHttpClient client;
	public static HttpContext context;
	
	public static TorThread tor;
	
	
	
	
	/**
	 * 
	 * TODO
	 * 
	 *   - more robust archi for requests : any request (initial, or citations ?) must go through
	 *   scholarRequest function to ensureConnection ; request and ensureConnection being called only in scholarRequest
	 *   
	 * 
	 */
	
	
	
	/**
	 * Init a scholar client
	 * 
	 * Independent from TorPool initialization ; 
	 * TODO : clarify setup function ¡¡
	 * 
	 * 
	 */
	public static void init(){
		try{
			
			Log.stdout("(Re)-initializing scholar API...");
			
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
			 
			 HttpGet httpGet = new HttpGet("http://scholar.google.com/scholar?q=transfer+theorem");
			 HttpResponse resp = client.execute(httpGet,context);
			 
			 try{Log.stdout("Accepted : "+Jsoup.parse(resp.getEntity().getContent(),"UTF-8","").getElementsByClass("gs_r").size());}catch(Exception e){e.printStackTrace();}
			 
			 //System.out.println("Connected to scholar, persistent through cookies. ");
			 //for(int i=0;i<cookieStore.getCookies().size();i++){System.out.println(cookieStore.getCookies().get(0).toString());}
				
			 EntityUtils.consumeQuietly(resp.getEntity());
			 
			}catch(Exception e){e.printStackTrace();}	
	}
	
	
	
	
	/**
	 * @param references
	 */
	public static void fillIds(HashSet<Reference> references) {

		for(Reference r:references){
			try{
				if(r.scholarID==null||r.scholarID==""){
					Reference rr = getScholarRef(r);
					if(rr!=null){
						r.scholarID=rr.scholarID;
						Log.stdout("Retrieved ID for Ref "+r);
					}
				}
			}catch(Exception e){e.printStackTrace();}
		}

	}

	
	
	
	
	/**
	 * Get references from a scholar request - citations not filled for more flexibility.
	 * 
	 * 
	 * @param request : either title, keywords, or ID in citing case
	 * @param maxNumResponses
	 * @param requestType "direct" or "cites"
	 * @return
	 */
	public static HashSet<Reference> scholarRequest(String request,int maxNumResponses,String requestType){
		HashSet<Reference> refs = new HashSet<Reference>();
		
		String query = "";
		
		// encode query here ?
		try{request = URIUtil.encodePath(request);}catch(Exception e){}
		
		switch (requestType){
		   case "direct": query="scholar?q="+request;break;
		   case "exact" : query="scholar?as_q="+request;break;
		   //case "exact" : query="scholar?q=\""+request+"\"";break;
		   case "cites": query="scholar?cites="+request;break;
		}
		
		
		try{
			
			
		    addPage(refs,ensureConnection(query+"&lookup=0&start=0"),maxNumResponses);
			int resultsNumber = refs.size();
		    
			 for(int l=10;l<maxNumResponses;l=l+10){
			     addPage(refs,ensureConnection(query+"&lookup=0&start="+l),maxNumResponses-resultsNumber);
			     if(refs.size()==resultsNumber){break;}
			     resultsNumber = refs.size();
			 }
		}catch(Exception e){e.printStackTrace();}
		
		return refs;
	}
	
	
	/**
	 * Get the ref constructed from scholar ; null if no result.
	 * 
	 * @param title
	 * @return
	 */
	public static Reference getScholarRef(String title,String author,String year){
		
		// first need to format title (html tags eg)
		title = Jsoup.parse(title).text();
		
		Reference res = null;
		// go up to 5 refs in case of an unclustered ref (cf Roger Dion paper !)
		res=matchRef(title,author,year,scholarRequest(title.replace(" ", "+" ),5,"exact"));
		
		//try direct if no result
		if(res==null){
			res=matchRef(title,author,year,scholarRequest(title.replace(" ", "+" ),5,"direct"));
		}	
		
		// try exact pattern with "title"
		if(res==null){
			res=matchRef(title,author,year,scholarRequest("\""+title.replace(" ", "+" )+"\"",5,"direct"));
		}	
	
		return res;
	}
	
	/**
	 * Overload the method : call on title and concatenated authors.
	 * 
	 * @param ref
	 * @return
	 */
	public static Reference getScholarRef(Reference ref){
		String authors = "";for(String a:ref.authors){authors = authors+" "+a;}
		String year = ref.year;
		if(year.contains("-")){year = year.split("-")[0];}
		Reference res = getScholarRef(ref.title.title,authors,year);
		if(res==null){
			ref.attributes.put("failed_req", "1");
		}else{
			ref.attributes.put("failed_req", "0");
		}
		return res;
	}
	
	
	/**
	 * Match a ref to a set, looking at title and if refs have sch ids
	 * 
	 * @param refs
	 * @return
	 */
	public static Reference matchRef(String title,String author,String year,HashSet<Reference> refs){
		Reference res = null;
		for(Reference nr:refs){
			Log.stdout(nr.year+"  --  "+year);
			String t1 = StringUtils.lowerCase(nr.title.title).replaceAll("[^\\p{L}\\p{Nd}]+", "");
			String t2 = StringUtils.lowerCase(title).replaceAll("[^\\p{L}\\p{Nd}]+", "");
			Log.stdout("      "+t1);
			Log.stdout("      "+t2);
			if(StringUtils.getLevenshteinDistance(t1,t2)<3&&nr.scholarID!=""&&year.compareTo(nr.year)==0){
			   res=nr;
			}
		};
		return res;
	}
	
	
	/*
	public static void fillIdAndCitingRefs(Corpus corpus){
		fillIdAndCitingRefs(corpus,"");
	}
	*/
	
	/**
	 * Queries and constructs citing refs for a set of refs, and fills scholar id.
	 * 
	 * Alters refs in place.
	 * 
	 * @param corpus
	 */
	public static void fillIdAndCitingRefs(Corpus corpus){
		try{
			int totalRefs = corpus.references.size();int p=0;
			for(Reference r:corpus.references){
				Log.stdout("Getting cit for ref "+r.toString());

				if(r.citing.size()>1||r.citingFilled){
					Log.stdout("Citing refs already filled : "+r.citing.size()+" refs");
				}
				else{
					try{
						// first get scholar ID
						
						/**
						 * TODO : some refs are only in VO (eg french -> must have both titles and try request on list of titles)
						 * 
						 * TODO : write a generic distance function, binary, taking title and authors, title being compared on
						 * non special characters (-> levenstein on non special ?)
						 * AND with good language title
						 * 
						 */
						
						Reference rr;
						if(r.scholarID==null||r.scholarID==""){rr = getScholarRef(r);}else{rr=r;}
						
						if(rr!=null){
							Log.stdout("ID : "+rr.scholarID);
							r.scholarID=rr.scholarID;//no need as rr and r should be same pointer ?
							HashSet<Reference> citing = scholarRequest(r.scholarID,10000,"cites"); // TODO ; limit of max cit number ?
							for(Reference c:citing){r.citing.add(c);}
						}
						
						r.citingFilled = true;
						
						Log.stdout("Citing refs : "+r.citing.size());
						
					}catch(Exception e){e.printStackTrace();}
				}
				
				Log.purpose("progress","Corpus "+corpus.name+" : citing refs : "+(100.0 * (1.0*p) / (1.0*totalRefs))+ " % ; ref "+r.toString());p++;
				
			}
		}catch(Exception e){e.printStackTrace();}
	}
	
	
	
	/**
	 * Switch TOR port to ensure scholar connection (google blocking).
	 *
	 * @param request
	 * @return
	 */
	private static Document ensureConnection(String request) {
		Document dom = new Document("<html><head></head><body></body></html>");
		try{dom=request("scholar.google.com",request);}
		catch(Exception e){e.printStackTrace();}
		Log.stdout("Request : "+request);
		try{Log.stdout(dom.getElementsByClass("gs_rt").first().text());}catch(Exception e){}
		try{Log.stdout(dom.getElementsByClass("gs_alrt").first().text());}catch(Exception e){}
		
		try{
			//if(dom.getElementById("gs_res_bdy")==null){
				//System.out.println(dom.html());
				while(dom==null||dom.getElementById("gs_res_bdy")==null){
					// swith TOR port
					Log.stdout("Current IP blocked by ggl fuckers ; switching currentTorThread.");
				    
				    // TODO : write ip in file for systematic stats of blocked adress (may have patterns in google-fuckers blocking policy)
				    
				    //TorPool.switchPort(true);
				    // use TorPoolManager instead
				    TorPoolManager.switchPort();
				    
					// reinit scholar API
					init();
					//update the request
					dom = request("scholar.google.com",request);
					try{Log.stdout(dom.getElementsByClass("gs_rt").first().text());}catch(Exception e){}
					try{Log.stdout(dom.getElementsByClass("gs_alrt").first().text());}catch(Exception e){}
				}
			//}
		}catch(Exception e){e.printStackTrace();}
		return dom;
	}
	
	
	/**
	 * Local function parsing a scholar response.
	 * 
	 * @param refs
	 * @param dom
	 * @param remResponses
	 */
	private static void addPage(HashSet<Reference> refs,Document dom,int remResponses){
		int resultsNumber = 0;
		Elements e = dom.getElementsByClass("gs_ri");
		for(Element r:e){
	    	if(resultsNumber<remResponses){
	    		String id = getCluster(r);
	    		if(id!=null&&id.length()>0){
	    		  refs.add(Reference.construct("", getTitle(r), new Abstract(), getYear(r), id));
	    		  resultsNumber++;
	    		}
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
	 * Get title given the element.
	 * 
	 * @param e
	 * @return
	 */
	private static Title getTitle(Element e){
		try{
		  return new Title(e.getElementsByClass("gs_rt").text().replaceAll("\\[(.*?)\\]",""));
		}catch(Exception ex){ex.printStackTrace();return Title.EMPTY;}
	}
	
	
	/**
	 * Get year
	 * 
	 * @param e
	 * @return
	 */
	private static String getYear(Element e){
		try{
			String t = e.getElementsByClass("gs_a").first().text();
			String y = "";
			for(int i=0;i<t.length()-4;i++){
				if(t.substring(i, i+4).matches("\\d\\d\\d\\d")){y=t.substring(i, i+4);};
			}
			return y;
		}catch(Exception ex){ex.printStackTrace();return "";}
	}

	
	/**
	 * Simple HTTP Get request to host, url.
	 * 
	 * @param host
	 * @param url
	 * @return org.jsoup.nodes.Document dom
	 */
	public static Document request(String host,String url){	
		Document res = null;
		try {
			
			//String encodedURL = URIUtil.encodeWithinPath("http://"+host+"/"+url);
			// needs to be done before.
			
			String encodedURL = "http://"+host+"/"+url;
			
			Log.stdout("Request : "+encodedURL);
			
		    HttpResponse response = client.execute(new HttpGet(encodedURL));
		    try {
		    	//res= Jsoup.parse(response.getEntity().getContent(),"UTF-8","");
		    	res= Jsoup.parse(EntityUtils.toString(response.getEntity(),"UTF-8"));
		    	EntityUtils.consume(response.getEntity());
		    }catch(Exception e){e.printStackTrace();}
		} catch(Exception e){e.printStackTrace();}
		return res;
	}


	
	
	

}
