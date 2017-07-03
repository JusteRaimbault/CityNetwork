/**
 * 
 */
package utils.tor;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.URL;
import java.net.URLConnection;

import org.jsoup.nodes.Document;

import scholar.ScholarAPI;

/**
 * @author Raimbault Juste <br/> <a href="mailto:juste.raimbault@polytechnique.edu">juste.raimbault@polytechnique.edu</a>
 *
 */
public class TestTor {

	public static void testTorPool(){
		TorPool.initPool(9050, 9100, 25);
		
		/*for(TorThread t:TorThread.torthreads.keySet()){
			System.out.println(t.port);
		}*/
		
		TorPool.runPool();
		TorPool.stopPool();
		
	}
	
	
	public static void testCircuitsIP(){
		TorPool.initPool(9050, 9200, 100);
		TorPool.runPool();
		System.setProperty("socksProxyHost", "127.0.0.1");
		
		for(Integer p:TorPool.used_ports.keySet()){
			try{
			  System.out.println(p.intValue());
				
		      System.setProperty("socksProxyPort",p.toString());
			 

			  BufferedReader r = new BufferedReader(new InputStreamReader(new URL("http://ipecho.net/plain").openConnection().getInputStream()));
			  String currentLine=r.readLine();
			  while(currentLine!= null){System.out.println(currentLine);currentLine=r.readLine();}
			  
			  
			}catch(Exception e){e.printStackTrace();}
		}
		
		TorPool.stopPool();
	}
	
	
	public static void testScholarAvailability(){
		
		int totalIps = 30;
		int successCount = 0;
		
		TorPool.initPool(9050, 9050+totalIps, totalIps);
		TorPool.runPool();
		System.setProperty("socksProxyHost", "127.0.0.1");
		for(Integer p:TorPool.used_ports.keySet()){
			try{
			  System.out.println("Port : "+p.intValue());
			  System.setProperty("socksProxyPort",p.toString());
			  
			  // check ip
			  System.out.println("IP : ");
			  BufferedReader r = new BufferedReader(new InputStreamReader(new URL("http://ipecho.net/plain").openConnection().getInputStream()));
			  String currentLine=r.readLine();
			  while(currentLine!= null){System.out.println(currentLine);currentLine=r.readLine();};
			  
			  ScholarAPI.init();
			  Document d = ScholarAPI.request("scholar.google.com","scholar?q=transfer+theorem+probability&lookup=0&start=0");
			  try{
				  try{System.out.println(d.getElementsByClass("gs_rt").first().html());}catch(Exception e){}
			      try{System.out.println(d.getElementsByClass("gs_alrt").first().html());}catch(Exception e){}
				  System.out.println(d.getElementsByClass("gs_rt").first().text());
				  successCount++;
			  }catch(Exception e){e.printStackTrace();System.out.println("Connexion refused by ggl fuckers");}
			  
			  
			}catch(Exception e){e.printStackTrace();}
		}
		
		//TorThread.stopPool();	
		System.out.println("Success Ratio : "+successCount*1.0/(totalIps*1.0));	
		
		TorPool.stopPool();
		
	}
	
	
	/**
	 * Same test as before but using the port switching function.
	 */
	public static void testScholarAvailibilityPortSwitching(){
		int totalIps = 30;
		int successCount = 0;
		
		TorPool.initPool(9050, 9050+totalIps, totalIps);
		TorPool.runPool();
		System.setProperty("socksProxyHost", "127.0.0.1");
		while(TorPool.used_ports.size()>0){
			System.out.println(TorPool.used_ports.size());
			TorPool.switchPort(false);


			ScholarAPI.init();
			Document d = ScholarAPI.request("scholar.google.com","scholar?q=transfer+theorem+probability&lookup=0&start=0");
			try{
				try{System.out.println(d.getElementsByClass("gs_rt").first().text());}catch(Exception e){}
				try{System.out.println(d.getElementsByClass("gs_alrt").first().text());}catch(Exception e){}
				System.out.println(d.getElementsByClass("gs_rt").first().text());
				successCount++;
			}catch(Exception e){e.printStackTrace();System.out.println("Connexion refused by ggl fuckers");}

		}
        System.out.println("Success Ratio : "+successCount*1.0/(totalIps*1.0));	
		TorPool.stopPool();
	}
	
	
	/**
	 * @param args
	 */
	public static void main(String[] args) {
		//testTorPool();
		
		//testCircuitsIP();
		
		//TorPool.forceStopPID(2117,2213);
		//TorPool.forceStop(9050, 9100);
		
		testScholarAvailibilityPortSwitching();
		
	}

}
