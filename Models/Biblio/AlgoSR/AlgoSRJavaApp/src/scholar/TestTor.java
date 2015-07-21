/**
 * 
 */
package scholar;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.URL;
import java.net.URLConnection;

import org.jsoup.nodes.Document;

/**
 * @author Raimbault Juste <br/> <a href="mailto:juste.raimbault@polytechnique.edu">juste.raimbault@polytechnique.edu</a>
 *
 */
public class TestTor {

	public static void testTorPool(){
		TorThread.initPool(9050, 9100, 25);
		
		/*for(TorThread t:TorThread.torthreads.keySet()){
			System.out.println(t.port);
		}*/
		
		//TorThread.runPool();
		//TorThread.stopPool();
		
	}
	
	
	public static void testCircuitsIP(){
		TorThread.initPool(9050, 9100, 25);
		TorThread.runPool();
		System.setProperty("socksProxyHost", "127.0.0.1");
		
		for(Integer p:TorThread.used_ports.keySet()){
			try{
			  System.out.println(p.intValue());
				
		      System.setProperty("socksProxyPort",p.toString());
			 

			  BufferedReader r = new BufferedReader(new InputStreamReader(new URL("http://ipecho.net/plain").openConnection().getInputStream()));
			  String currentLine=r.readLine();
			  while(currentLine!= null){System.out.println(currentLine);currentLine=r.readLine();}
			  
			  
			}catch(Exception e){e.printStackTrace();}
		}
		
		TorThread.stopPool();
	}
	
	
	public static void testScholarAvailability(){
		
		int totalIps = 50;
		int successCount = 0;
		
		TorThread.initPool(9050, 9050+totalIps, totalIps);
		TorThread.runPool();
		System.setProperty("socksProxyHost", "127.0.0.1");
		for(Integer p:TorThread.used_ports.keySet()){
			try{
			  System.out.println("Port : "+p.intValue());
			  System.setProperty("socksProxyPort",p.toString());
			  
			  // check ip
			  System.out.println("IP : ");
			  BufferedReader r = new BufferedReader(new InputStreamReader(new URL("http://ipecho.net/plain").openConnection().getInputStream()));
			  String currentLine=r.readLine();
			  while(currentLine!= null){System.out.println(currentLine);currentLine=r.readLine();};
			  
			  ScholarAPI.init();
			  Document d = ScholarAPI.request("scholar.google.com","scholar?q=urban+network&lookup=0&start=0");
			  try{
				  System.out.println(d.getElementsByClass("gs_rt").first().text());
				  successCount++;
			  }catch(Exception e){System.out.println("Connexion refused by ggl fuckers");}
			  
			  
			}catch(Exception e){e.printStackTrace();}
		}
		
		//TorThread.stopPool();	
		System.out.println("Success Ratio : "+successCount*1.0/(totalIps*1.0));	
		
	}
	
	
	/**
	 * @param args
	 */
	public static void main(String[] args) {
		//testTorPool();
		
		//testCircuitsIP();
		
		testScholarAvailability();
		
	}

}
