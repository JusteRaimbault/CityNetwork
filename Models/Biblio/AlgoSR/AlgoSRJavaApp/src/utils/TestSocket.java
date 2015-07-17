/**
 * 
 */
package utils;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.InetSocketAddress;
import java.net.Proxy;
import java.net.Socket;
import java.net.SocketAddress;
import java.net.URL;
import java.net.URLConnection;

import javax.net.SocketFactory;

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

import com.subgraph.orchid.Tor;
import com.subgraph.orchid.TorClient;
//import com.subgraph.orchid.sockets.OrchidSocketFactory;

import com.subgraph.orchid.socks.Socks4Request;

/**
 * @author Raimbault Juste <br/> <a href="mailto:juste.raimbault@polytechnique.edu">juste.raimbault@polytechnique.edu</a>
 *
 */
public class TestSocket {

	public static void test1(){

		try{
			//System.setProperty("socksProxyVersion","4A");
			SocketAddress addr = new InetSocketAddress("localhost", 9052);
			Proxy proxy = new Proxy(Proxy.Type.SOCKS, addr);
			//System.out.println(proxy.type());
			Socket socket = new Socket(proxy);
			
			for(int i=0;i<20;i++){
				
				// run a new tor at each loop ?
				// --> test for run a new at each google blocking
				// kill ols tor if exists
				//Process p=null;
				/*try
		        {           
					
					
		            Runtime rt = Runtime.getRuntime();
		            System.out.println("Running new tor...");
		            p=Runtime.getRuntime().exec("/usr/local/bin/tor -f /Users/Juste/.torrc");
		            int exitVal = p.exitValue();
		            System.out.println("Process exitValue: " + exitVal);
		        } catch (Throwable t){t.printStackTrace();
		          }
	            */
	            
	            /*p.waitFor();
	            BufferedReader reader = new BufferedReader(new InputStreamReader(p.getInputStream()));
	            String line=reader.readLine();

	            while (line != null) {
	                System.out.println(line);
	                line = reader.readLine();
	            }*/
				
				//System.out.println("sleep 10sec");
	            //Thread.sleep(10000);
	            
				//URL url = new URL("https://scholar.google.com/scholar?cluster=14017146646478350844");
				URL url = new URL("http://ipecho.net/plain");
				URLConnection conn = url.openConnection(proxy);
				conn.setReadTimeout(10000);conn.setReadTimeout(10000);
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
				System.out.println("killing old tor");
				//Process p=Runtime.getRuntime().exec("/bin/kill -9 `/bin/cat /Users/Juste/.torpid`");
			/*
				BufferedReader reader = new BufferedReader(new InputStreamReader(p.getInputStream()));
				String line=reader.readLine();

				while (line != null) {    
					System.out.println(line);
					line = reader.readLine();
				}
			*/
				//p.destroy();
			
				}
			}catch(Exception e){e.printStackTrace();}
	}
	
	
	/**
	 * Test for Orchid java client
	 */
	public static void testOrchid(){
		
		
		for(int i=0;i<5;i++){
		try{
		//Socks4Request request = new Socks4Request(null, OrchidSocketFactory.getDefault().createSocket("localhost",9050));
			//use the same client ? NO
			TorClient torclient = new TorClient();
			
			torclient.start();
			//torclient.waitUntilReady();
			torclient.enableSocksListener(9050);
			//torclient.enableDashboard();
			
		
		//Socket socket = torclient.getSocketFactory().createSocket("http://ipecho.net/plain", 80);
		//System.out.println(socket.toString());
		//socket.connect( new InetSocketAddress("localhost", 9050));
		//InputStream in = socket.getInputStream();
		//SocketFactory.getDefault().createSocket().bind( new InetSocketAddress("localhost", 9050));
		SocketAddress addr = new InetSocketAddress("localhost", 9050);
		Proxy proxy = new Proxy(Proxy.Type.SOCKS, addr);
		Socket socket = new Socket(proxy);
		URL url = new URL("http://ipecho.net/plain");
		URLConnection conn = url.openConnection(proxy);
		conn.setReadTimeout(30000);
		conn.setRequestProperty("user-agent", "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/42.0.2311.90 Safari/537.36");
		InputStream in = conn.getInputStream();
		BufferedReader r = new BufferedReader(new InputStreamReader(in));
		String html="";
		String currentLine=r.readLine();
		while(currentLine!= null){System.out.println(currentLine);html+=currentLine;currentLine=r.readLine();}
		r.close();
		//in.close();
		//socket.close();
		System.out.println("reader closed");
		//Document dom = Jsoup.parse(html);
		//System.out.println(dom.getElementsByTag("body").first().html());
		//Thread.currentThread().stop();
		//tor.getCircuitManager().openDirectoryCircuit().
		
		//torclient.stop();
		
		}catch(Exception e){e.printStackTrace();}
		finally{
			//tor.stop();
		}
		}
	}
	
	
	
	public static void testExternalThread(){
		try{
			try{
			@SuppressWarnings("resource")
			String pid = new BufferedReader(new FileReader(new File("/Users/Juste/.torpid"))).readLine();
			System.out.println(pid);
			Process p=Runtime.getRuntime().exec("kill -SIGTERM "+pid);
			InputStream s = p.getInputStream();
			BufferedReader r = new BufferedReader(new InputStreamReader(s));
			System.out.println(r.readLine());
			p.waitFor();
			}catch(Exception e){e.printStackTrace();System.out.println("SOCKET Clean");}
			
			TorThread t = new TorThread();
			t.start();
			Thread.sleep(5000);
			int i = 0;
			while(true){
				Thread.sleep(100);
				
				
				SocketAddress addr = new InetSocketAddress("localhost", 9050);
				Proxy proxy = new Proxy(Proxy.Type.SOCKS, addr);
				Socket socket = new Socket(proxy);
				
				
				
				URL url = new URL("http://scholar.google.com/scholar?q=transfer+theorem&lookup=0&start="+i);
				URLConnection conn = url.openConnection(proxy);
				conn.setReadTimeout(30000);
				conn.setRequestProperty("user-agent", "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/42.0.2311.90 Safari/537.36");
				InputStream in = conn.getInputStream();
				BufferedReader r = new BufferedReader(new InputStreamReader(in));
				String html="";
				String currentLine=r.readLine();
				while(currentLine!= null){System.out.println(currentLine);html+=currentLine;currentLine=r.readLine();}
				r.close();
				
				i=i+10;
				
				
				if(i%50 == 0){
					try{
					String pid = new BufferedReader(new FileReader(new File("/Users/Juste/.torpid"))).readLine();
					Process p=Runtime.getRuntime().exec("kill -SIGTERM "+pid);p.waitFor();
					}catch(Exception e){}
					
					t.running=false;
					Thread.sleep(500);
					System.out.println("running new tor...");
					t = new TorThread();t.start();
					System.out.println("waiting...");
					Thread.sleep(5000);
				}
			}
			
			
		}catch(Exception e){
			e.printStackTrace();
		}
	}
	
	
	private static class TorThread extends Thread {
		
		boolean running;
		
		private TorThread(){running=true;}
	    
		public void run(){
			try{
			Process p=Runtime.getRuntime().exec("/opt/local/bin/tor -f /Users/Juste/.torrc");
			InputStream s = p.getInputStream();
			BufferedReader r = new BufferedReader(new InputStreamReader(s));
			while(true){
				Thread.sleep(100);
				System.out.println(r.readLine());
				if(!running){
					p.destroy();p.waitFor();
				}
			}
			}catch(Exception e){
				e.printStackTrace();
			}
		}
		
	}
	
	
	
	/**
	 * @param args
	 */
	public static void main(String[] args) {
		
		// test1();
		
		//testOrchid();
		
		testExternalThread();
		
	}

}
