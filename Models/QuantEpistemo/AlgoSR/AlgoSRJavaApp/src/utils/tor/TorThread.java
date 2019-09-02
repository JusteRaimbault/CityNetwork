/**
 * 
 */
package utils.tor;

import java.io.*;
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
			new File(".tor_tmp/torpid"+port).delete();
			Process p=Runtime.getRuntime().exec("/opt/local/bin/tor --SOCKSPort "+port+" --DataDirectory ~/.tor_tmp/"+port+" --PidFile ~/.tor_tmp/torpid"+port);
			InputStream s = p.getInputStream();
			BufferedReader r = new BufferedReader(new InputStreamReader(s));
			
			while(true){
				sleep(100);
				String l= r.readLine();
				if(l!= null&&TorPool.verbose)System.out.println(l);

				// concurrently write in ports when the up signal is received
				if(l.contains("Bootstrapped 100")){
					appendWithLock(new Integer(port).toString(),".tor_tmp/ports",".tor_tmp/lock");
				}

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
			try{
				String pid = new BufferedReader(new FileReader(new File(".tor_tmp/.torpid"+port))).readLine();
				System.out.println("running: "+running+" ; sending SIGTERM to tor... PID : "+pid);
				Process p=Runtime.getRuntime().exec("kill -SIGTERM "+pid);p.waitFor();
			}catch(Exception e){e.printStackTrace();}

			//put port again in list of available ports
			TorPool.available_ports.put(new Integer(port), new Integer(port));
			TorPool.used_ports.remove(new Integer(port));
			
			
			Thread.sleep(500);
			
			new File("tmp/.torpid"+port).delete();
			
		}catch(Exception e){e.printStackTrace();}
	}


	/**
	 * Append string line to a locked file
	 *
	 * @param s
	 * @param file
	 * @param lock
	 */
	private static void appendWithLock(String s,String file,String lock){
		try{
			boolean locked = true;
			while(locked){
				System.out.println("Waiting for lock on "+lock);
				Thread.sleep(200);
				locked = (new File(lock)).exists();
			}
			File lockfile = new File(".tor_tmp/lock");lockfile.createNewFile();
			BufferedWriter r = new BufferedWriter(new FileWriter(new File(file),true));
			r.write(s);
			r.newLine();
			lockfile.delete();
		}catch(Exception e){e.printStackTrace();}
	}


	

	
	
	
	
}
