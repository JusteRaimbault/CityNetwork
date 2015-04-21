/**
 * 
 */
package utils;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.InetSocketAddress;
import java.net.Proxy;
//import java.net.Socket;
import java.net.SocketAddress;
import java.net.URL;
import java.net.URLConnection;

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
			//Socket socket = new Socket(proxy);
			URL url = new URL("http://ipecho.net/plain");
			URLConnection conn = url.openConnection(proxy);
			
			//System.out.println(System.getProperty("socksProxyVersion"));
			
			//InetSocketAddress dest = new InetSocketAddress("ipecho.net/plain", 80);
			//socket.connect(dest);
			
			BufferedReader r = new BufferedReader(new InputStreamReader(conn.getInputStream()));
			String currentLine=r.readLine();
			while(currentLine!= null){System.out.println(currentLine);currentLine=r.readLine();}
		}catch(Exception e){e.printStackTrace();}
		
	}

}
