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
import main.Reference;
import mendeley.MendeleyAPI;

import org.apache.http.HttpHost;
import org.apache.http.HttpResponse;
import org.apache.http.client.CookieStore;
import org.apache.http.client.methods.CloseableHttpResponse;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.protocol.ClientContext;
import org.apache.http.client.protocol.HttpClientContext;
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

import utils.Log;
import utils.tor.TorPool;
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
			
			System.out.println("(Re)-initializing scholar API...");
			
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
			 HttpResponse resp = client.execute(httpGet,context);
			 
			 //System.out.println("Connected to scholar, persistent through cookies. ");
			 //for(int i=0;i<cookieStore.getCookies().size();i++){System.out.println(cookieStore.getCookies().get(0).toString());}
				
			 EntityUtils.consumeQuietly(resp.getEntity());
			 
			}catch(Exception e){e.printStackTrace();}	
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
		
		switch (requestType){
		   case "direct": query="scholar?q="+request;break;
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

				if(r.citing.size()>0){
					System.out.println("Citing refs already filled !");
				}
				else{
					// first get scholar ID
					Reference rr = null;
					for(Reference nr:scholarRequest(r.title.replace(" ", "+"),1,"direct")){rr=nr;};
									
					System.out.println("ID : "+rr.scholarID);
					r.scholarID=rr.scholarID;
					
					HashSet<Reference> citing = scholarRequest(r.scholarID,10000,"cites");
					for(Reference c:citing){r.citing.add(c);}
					
					System.out.println("Citing refs : "+r.citing.size());
				}
			}
		}catch(Exception e){e.printStackTrace();}
	}
	
	
	
	/**
	 * Switch TOR port to ensure scholar connection (google blocking).
	 * 
	 * @param d
	 * @param r
	 * @return
	 */
	private static Document ensureConnection(String request) {
		Document dom = request("scholar.google.com",request);
		System.out.println("Request : "+request);
		try{System.out.println(dom.getElementsByClass("gs_rt").first().text());}catch(Exception e){}
		try{System.out.println(dom.getElementsByClass("gs_alrt").first().text());}catch(Exception e){}
		
		try{
			if(dom.getElementById("gs_res_bdy")==null){
				//System.out.println(dom.html());
				while(dom.getElementById("gs_res_bdy")==null){
					// swith TOR port
				    System.out.println("Current IP blocked by ggl fuckers ; switching currentTorThread.");
				    TorPool.switchPort(true);
				    
					// reinit scholar API
					init();
					//update the request
					dom = request("scholar.google.com",request);
					try{System.out.println(dom.getElementsByClass("gs_rt").first().text());}catch(Exception e){}
					try{System.out.println(dom.getElementsByClass("gs_alrt").first().text());}catch(Exception e){}
				}
			}
		}catch(Exception e){e.printStackTrace();}
		return dom;
	}
	
	
	/**
	 * Local function parsing a scholar response.
	 * 
	 * @param refs
	 * @param Document dom
	 * @param remResponses
	 */
	private static void addPage(HashSet<Reference> refs,Document dom,int remResponses){
		int resultsNumber = 0;
		Elements e = dom.getElementsByClass("gs_ri");
		for(Element r:e){
	    	if(resultsNumber<remResponses){
	    		refs.add(Reference.construct("", getTitle(r), "", getYear(r), getCluster(r)));
	    		resultsNumber++;
	    	}
	    }
	}
	
	/**
	 * Get cluster from an element
	 * 
	 * @param org.jsoup.nodes.Element e
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
	private static String getTitle(Element e){
		try{
		  return e.getElementsByClass("gs_rt").text().replaceAll("\\[(.*?)\\]","");
		}catch(Exception ex){ex.printStackTrace();return "";}
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
	 * @param String host
	 * @param String url
	 * @return org.jsoup.nodes.Document dom
	 */
	public static Document request(String host,String url){	
		Document res = null;
		try {
		    HttpResponse response = client.execute(new HttpGet("http://"+host+"/"+url));
		    try {
		    	res= Jsoup.parse(response.getEntity().getContent(),"UTF-8","");
		    	EntityUtils.consume(response.getEntity());
		    }catch(Exception e){e.printStackTrace();}
		} catch(Exception e){e.printStackTrace();}
		return res;
	}
	
	
	/**
	 * Tests.
	 * 
	 * @param args
	 * @throws Exception 
	 */
	public static void main(String[] args) throws Exception {
		
		
		
		/*
		// test regex --> dirty
		String t="abc - 1998 - azerty";
		for(int i=0;i<t.length()-4;i++){
		  System.out.println(t.substring(i, i+4).matches("\\d\\d\\d\\d"));
		}
		*/
		
		
		/*
		init();
		//tor.running=false;
		//tor=new TorThread();tor.start();
		//Thread.sleep(1000);
		for(int i=0;i<5;i=i+10){
		//tor=new TorThread();tor.start();
		Thread.sleep(5000);
		Document d = request("scholar.google.com","scholar?q=urban+network&lookup=0&start="+i);
		System.out.println(d.html());
		System.out.println(d.getElementsByClass("gs_rt").first().html());
		//tor.running=false;
		//Thread.sleep(1000);
		}
		
		*/
		
		// test setup
		//setup("");
		
		// test request
		//HashSet<Reference> refs = scholarRequest("Co-evolution+of+density+and+topology+in+a+simple+model+of+city+formation",1);
		//for(Reference r:refs){System.out.println(r);}
		//fillIdAndCitingRefs(refs);
		//for(Reference r:refs){System.out.println(r);for(Reference c:r.citing){System.out.println(c);}}
		
		// test to fill a mendeley ref
		/*Main.setup("/Users/Juste/Documents/ComplexSystems/CityNetwork/Models/Biblio/AlgoSR/AlgoSRJavaApp/conf/default.conf");
		
		MendeleyAPI.setupAPI();
		HashSet<Reference> refs = MendeleyAPI.catalogRequest("transportation+network", 1);
		fillIdAndCitingRefs(refs);
		for(Reference r:refs){System.out.println(r);for(Reference c:r.citing){System.out.println(c);}}*/
		/*
		Registry<ConnectionSocketFactory> reg = RegistryBuilder.<ConnectionSocketFactory>create()
		        .register("http", PlainConnectionSocketFactory.INSTANCE)
		        .register("https", new MyConnectionSocketFactory(SSLContexts.createSystemDefault()))
		        .build();
		PoolingHttpClientConnectionManager cm = new PoolingHttpClientConnectionManager(reg);
		CloseableHttpClient httpclient = HttpClients.custom()
		        .setConnectionManager(cm)
		        .build();
		try {
		    InetSocketAddress socksaddr = new InetSocketAddress("127.0.0.1", 9050);
		    HttpClientContext context = HttpClientContext.create();
		    context.setAttribute("socks.address", socksaddr);

		    HttpHost target = new HttpHost("scholar.google.com", 80, "http");
		    HttpGet request = new HttpGet("/");

		    System.out.println("Executing request " + request + " to " + target + " via SOCKS proxy " + socksaddr);
		    CloseableHttpResponse response = httpclient.execute(target, request);
		    try {
		        System.out.println("----------------------------------------");
		        System.out.println(response.getStatusLine());
		        EntityUtils.consume(response.getEntity());
		    } finally {
		        response.close();
		    }
		} catch(Exception e){e.printStackTrace();} 
		finally {
		    //httpclient.close();
		}
	*/
		
		
	}
	
	
	
	static class MyConnectionSocketFactory extends SSLConnectionSocketFactory {

	    public MyConnectionSocketFactory(final SSLContext sslContext) {
	        super(sslContext);
	    }

	    @Override
	    public Socket createSocket(final HttpContext context) throws IOException {
	        InetSocketAddress socksaddr = new InetSocketAddress("localhost",9050); //context.getAttribute("socks.address");
	        Proxy proxy = new Proxy(Proxy.Type.SOCKS, socksaddr);
	        
	        return new Socket(proxy);
	    }

	}
	
	
	
	

}
