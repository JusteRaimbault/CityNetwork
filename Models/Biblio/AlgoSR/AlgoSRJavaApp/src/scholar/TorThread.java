/**
 * 
 */
package scholar;

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
	 * currently available threads - no need for concurrency
	 */
	public static final LinkedList<TorThread> torthreads = new LinkedList<TorThread>();
	
	/**
	 * Available ports to open new threads.
	 */
	public static final ConcurrentHashMap<Integer,Integer> available_ports = new ConcurrentHashMap<Integer,Integer>();
	
	public static final ConcurrentHashMap<Integer,Integer> used_ports = new ConcurrentHashMap<Integer,Integer>();
	
	
	public boolean running;
	
	/**
	 * Port for this thread
	 */
	public int port;
	
	public TorThread(){
		// pick a port to run the new thread
		// assumed to be totally free if in list of available ports
		port = available_ports.keySet().iterator().next().intValue();
		while(used_ports.contains(new Integer(port))){
		  port = available_ports.keySet().iterator().next().intValue();
		}
		used_ports.put(new Integer(port), new Integer(port));
		available_ports.remove(new Integer(port));
		running=true;
	}
    
	public void run(){
		try{
			new File("/Users/Juste/.torpid"+port).createNewFile();
		Process p=Runtime.getRuntime().exec("/opt/local/bin/tor --SOCKSPort "+port+" --DataDirectory ~/.tor_tmp_"+port+" --PidFile ~/.torpid"+port);
		InputStream s = p.getInputStream();
		BufferedReader r = new BufferedReader(new InputStreamReader(s));
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
	
	public void cleanStop(){
		try{
			running=false;
			String pid = new BufferedReader(new FileReader(new File("/Users/Juste/.torpid_"+port))).readLine();
			System.out.println("running: "+running+" ; sending SIGTERM to tor... PID : "+pid);
			Process p=Runtime.getRuntime().exec("kill -SIGTERM "+pid);p.waitFor();
			
			//put port again in list of available ports
			available_ports.put(new Integer(port), new Integer(port));
			used_ports.remove(new Integer(port));
			
		}catch(Exception e){e.printStackTrace();}
	}
	
	
	/**
	 * Forcing stop Torpool through PID files.
	 * 
	 * @param p1 start port
	 * @param p2 end port
	 */
	public static void forceStop(int p1,int p2){
		for(int port=p1;port<=p2;port++){
			try{
			String pid = new BufferedReader(new FileReader(new File("/Users/Juste/.torpid"+port))).readLine();
			System.out.println("sending SIGTERM to tor... PID : "+pid);
			Process p=Runtime.getRuntime().exec("kill -SIGTERM "+pid);p.waitFor();
			}catch(Exception e){e.printStackTrace();}
		}
		
	}
	
	
	/**
	 * force stop for pid range
	 * (when pid file fails)
	 * 
	 * @param pid1 start pid
	 * @param pid2 end pid
	 */
	public static void forceStopPID(int pid1,int pid2){
		for(int pid=pid1;pid<=pid2;pid++){
			try{
			System.out.println("sending SIGTERM to tor... PID : "+pid);
			Process p=Runtime.getRuntime().exec("kill -SIGTERM "+pid);p.waitFor();
			}catch(Exception e){e.printStackTrace();}
		}
		
	}
	
	
	
	/**
	 * Start a new pool of tor threads given a port range (included) and thread number
	 * 
	 * @param r1
	 * @param r2
	 */
	public static void initPool(int p1,int p2,int nThreads){
		//fill available range table
		available_ports.clear();
		for(int p=p1;p<p2;p++){
			available_ports.put(new Integer(p), new Integer(p));
		}
		
		// create the threads
		for(int k=0;k<nThreads;k++){
			TorThread t = new TorThread();
			torthreads.addLast(t);
		}
		
	}
	
	
	public static void runPool(){
		try{
		for(TorThread t:torthreads){
			//System.out.println(t.port);
			t.start();
		}
		
		// heuristic of required waiting time
		
		/**
		 * 
		 * TODO : surely not linear, as depend - on Java multi Thread mgt ; on tor common conf ?
		 * -> find temporal profile ; implement heuristic.
		 * 
		 */
		
		Thread.sleep(5000*torthreads.size());
		}catch(Exception e){e.printStackTrace();}
	}
	
	public static void stopPool(){
		for(TorThread t:torthreads){
			t.cleanStop();
		}
	}
	
	
	/**
	 * Switch the current port, by taking thread from the list, testing it and setting it if needed.
	 */
	public static void switchPort(){
		
	}
	
	
	
	
}
