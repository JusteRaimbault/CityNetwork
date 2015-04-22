/**
 * 
 */
package utils;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.InetSocketAddress;
import java.net.Proxy;
import java.net.Socket;
import java.net.SocketAddress;
import java.net.URL;
import java.net.URLConnection;

import org.apache.http.HttpHost;
import org.apache.http.HttpResponse;
import org.apache.http.client.CookieStore;
import org.apache.http.client.HttpClient;
import org.apache.http.client.config.RequestConfig;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.protocol.ClientContext;
import org.apache.http.impl.client.BasicCookieStore;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.protocol.BasicHttpContext;
import org.apache.http.protocol.HttpContext;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;

/**
 * @author Raimbault Juste <br/> <a href="mailto:juste.raimbault@polytechnique.edu">juste.raimbault@polytechnique.edu</a>
 *
 */
public class TestSocket {

	/**
	 * @param args
	 */
	public static void main(String[] args) {
		
		try{
			//System.setProperty("socksProxyVersion","4");
			SocketAddress addr = new InetSocketAddress("localhost", 9050);
			Proxy proxy = new Proxy(Proxy.Type.SOCKS, addr);
			//System.out.println(proxy.type());
			Socket socket = new Socket(proxy);
			
			for(int i=0;i<20;i++){
				
				// run a new tor at each loop ?
				// --> test for run a new at each google blocking
				// kill ols tor if exists
				
				
	            Process p=Runtime.getRuntime().exec("/usr/local/bin/tor -f /Users/Juste/.torrc");
	            
	            p.waitFor();
	            BufferedReader reader = new BufferedReader(new InputStreamReader(p.getInputStream()));
	            String line=reader.readLine();

	            while (line != null) {
	                System.out.println(line);
	                line = reader.readLine();
	            }
	            Thread.sleep(5000);
	            
				//URL url = new URL("https://scholar.google.com/scholar?cluster=14017146646478350844");
				URL url = new URL("http://ipecho.net/plain");
				URLConnection conn = url.openConnection(proxy);
			
				// add header
				//user-agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/42.0.2311.90 Safari/537.36
				conn.setRequestProperty("user-agent", "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/42.0.2311.90 Safari/537.36");
			
			
			//HttpClient client = new DefaultHttpClient();

		    //context
		    //HttpContext context = new BasicHttpContext();
		    //add a cookie store to context
		    //CookieStore cookieStore = new BasicCookieStore();
			//context.setAttribute(ClientContext.COOKIE_STORE, cookieStore);
			
			//RequestConfig config = RequestConfig.custom().setProxy(new HttpHost("localhost",9050)).build();
            //HttpGet request = new HttpGet("http://scholar.google.com/scholar?cluster=14017146646478350844");
			//HttpGet request = new HttpGet("http://ipecho.net/plain");
			//request.setConfig(config);
			//HttpResponse response = client.execute(request);
			
			//System.out.println(System.getProperty("socksProxyVersion"));
			
			//InetSocketAddress dest = new InetSocketAddress("ipecho.net/plain", 80);
			//socket.connect(dest);
			
			BufferedReader r = new BufferedReader(new InputStreamReader(conn.getInputStream()));
			String html="";
			String currentLine=r.readLine();
			while(currentLine!= null){html+=currentLine;currentLine=r.readLine();}
			
			
			Document dom = Jsoup.parse(html);
			System.out.println(dom.getElementsByTag("body").first().html());
			
			//Thread.sleep(30000);
			
			//kill tor
			p=Runtime.getRuntime().exec("/bin/cat /Users/Juste/.torpid;/bin/kill -9 `/bin/cat /Users/Juste/.torpid`");p.waitFor();
			
			 reader = new BufferedReader(new InputStreamReader(p.getInputStream()));
             line=reader.readLine();

            while (line != null) {    
                System.out.println(line);
                line = reader.readLine();
            }
			
			
			}
		}catch(Exception e){e.printStackTrace();}
		
	}

}
