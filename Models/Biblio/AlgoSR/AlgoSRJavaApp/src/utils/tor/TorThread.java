/**
 * 
 */
package utils.tor;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.LinkedList;
import java.util.concurrent.ConcurrentHashMap;

/**
 * @author Raimbault Juste <br/> <a href="mailto:juste.raimbault@polytechnique.edu">juste.raimbault@polytechnique.edu</a>
 *
 */
public class TorThread extends Thread {
	

	
	/**
	 * If the task is running
	 */
	public boolean running;
	
	/**
	 * Port for this thread
	 */
	public int port;
	
	/**
	 * Basic constructor
	 * 
	 * Does not actually launch the tor command, but attributes port and updates tables
	 */
	public TorThread(){
		// pick a port to run the new thread
		// assumed to be totally free if in list of available ports
		port = TorPool.available_ports.keySet().iterator().next().intValue();
		while(TorPool.used_ports.contains(new Integer(port))){
		  port = TorPool.available_ports.keySet().iterator().next().intValue();
		}
		TorPool.used_ports.put(new Integer(port), new Integer(port));
		TorPool.available_ports.remove(new Integer(port));
		running=true;
		System.out.println("Starting new TorThread on port "+port);
	}
    
	
	/**
	 * Run the thread : launch shell command
	 */
	public void run(){
		try{
			new File("tmp/.torpid"+port).delete();
			Process p=Runtime.getRuntime().exec("/opt/local/bin/tor --SOCKSPort "+port+" --DataDirectory ~/.tor_tmp_"+port+" --PidFile tmp/.torpid"+port);
			InputStream s = p.getInputStream();
			BufferedReader r = new BufferedReader(new InputStreamReader(s));

			// must run in background
			while(true){
				sleep(100);
				String l= r.readLine();
				if(l!= null)System.out.println(l);
				if(!running){
					break;
				}
			}
		}catch(Exception e){
			e.printStackTrace();
		}
	}
	
	
	/**
	 * Clean stop of the thread.
	 */
	public void cleanStop(){
		try{
			running=false;
			String pid = new BufferedReader(new FileReader(new File("tmp/.torpid"+port))).readLine();
			System.out.println("running: "+running+" ; sending SIGTERM to tor... PID : "+pid);
			Process p=Runtime.getRuntime().exec("kill -SIGTERM "+pid);p.waitFor();
			
			new File("tmp/.torpid"+port).delete();
			
			//put port again in list of available ports
			TorPool.available_ports.put(new Integer(port), new Integer(port));
			TorPool.used_ports.remove(new Integer(port));
			
		}catch(Exception e){e.printStackTrace();}
	}
	
	
	
	

	
	
	
	
}
