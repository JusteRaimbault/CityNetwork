/**
 * 
 */
package utils.connexion.tor;

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
	 * Default tor command
	 */
	public static String torCommand = "tor";

	
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
			try{
				new File(".tor_tmp/torpid"+port).delete();
				File pidfile = new File(".tor_tmp/torpid"+port);
				pidfile.createNewFile();
				//System.out.println(pidfile.getAbsolutePath());
			}catch(Exception e){e.printStackTrace();}
			
			if(new File("conf/torcommand").exists()){//try to read a replacement tor command in conf file
				// TODO command as java task arg ?
				BufferedReader r = new BufferedReader(new FileReader(new File("conf/torcommand")));
				torCommand = r.readLine();r.close();
			}
			
			Process p=Runtime.getRuntime().exec(torCommand+" --SOCKSPort "+port+" --DataDirectory .tor_tmp/data"+port+" --PidFile .tor_tmp/torpid"+port);
			InputStream s = p.getInputStream();
			BufferedReader r = new BufferedReader(new InputStreamReader(s));

			// must run in background
			
			// Really necessary ?
			
			new StreamDisplayer(r).start();
			
			while(true){
				sleep(1000);
				
				//check if the Thread has to be stopped
				if((new File(".tor_tmp/kill"+port)).exists()){running = false;}
				
				if(!running){
					cleanStop();
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
			//opens the lock
			(new File(".tor_tmp/lock")).createNewFile();
			try{
				//delete stopping signal
				try{(new File(".tor_tmp/kill"+port)).delete();}catch(Exception e){}
				
				// kill tor process
				String pid = new BufferedReader(new FileReader(new File(".tor_tmp/torpid"+port))).readLine();
				System.out.println("running: "+running+" ; sending SIGTERM to tor... PID : "+pid);
				Process p=Runtime.getRuntime().exec("kill -SIGTERM "+pid);p.waitFor();
				
				// delete port from communication file ? not needed, done at reading.
				
			}catch(Exception e){e.printStackTrace();}

			//put port again in list of available ports
			TorPool.available_ports.put(new Integer(port), new Integer(port));
			TorPool.used_ports.remove(new Integer(port));
			
			
			Thread.sleep(500);
			
			//launch a new thread to replace this one
			TorPool.newThread();
			
			// no need to remove pidfile, deleted at a clean tor thread stop
			//try{new File(".tor_tmp/.torpid"+port).delete();}catch(Exception e){e.printStackTrace();}
			
			// unlock the pool action
			(new File(".tor_tmp/lock")).delete();
			
		}catch(Exception e){
			e.printStackTrace();
			// delete the lock however in case of an issue
			(new File(".tor_tmp/lock")).delete();
		}
	}
	
	
	
	

	
	
	
	
}
