/**
 * 
 */
package scholar;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.concurrent.ConcurrentHashMap;

/**
 * @author Raimbault Juste <br/> <a href="mailto:juste.raimbault@polytechnique.edu">juste.raimbault@polytechnique.edu</a>
 *
 */
public class TorThread extends Thread {
	

	/**
	 * currently available threads
	 */
	public static final ConcurrentHashMap<TorThread,TorThread> torthreads = new ConcurrentHashMap<TorThread,TorThread>();
	
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
			torthreads.put(t,t);
		}
		
	}
	
	
	public static void runPool(){
		try{
		for(TorThread t:torthreads.keySet()){
			//System.out.println(t.port);
			t.start();
		}
		Thread.sleep(600000);
		}catch(Exception e){e.printStackTrace();}
	}
	
	public static void stopPool(){
		for(TorThread t:torthreads.keySet()){
			t.cleanStop();
		}
	}
	
	
	
	
}
