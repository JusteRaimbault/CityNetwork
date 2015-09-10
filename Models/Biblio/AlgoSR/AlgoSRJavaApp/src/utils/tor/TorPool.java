/**
 * 
 */
package utils.tor;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.InputStreamReader;
import java.net.URL;
import java.util.LinkedList;
import java.util.concurrent.ConcurrentHashMap;

/**
 * 
 * Function for managing Tor connection pool.
 * 
 * @author Raimbault Juste <br/> <a href="mailto:juste.raimbault@polytechnique.edu">juste.raimbault@polytechnique.edu</a>
 *
 */
public class TorPool {
	
	
	

	/**
	 * currently available threads - no need for concurrency
	 */
	public static final LinkedList<TorThread> torthreads = new LinkedList<TorThread>();
	
	/**
	 * Available ports to open new threads.
	 */
	public static final ConcurrentHashMap<Integer,Integer> available_ports = new ConcurrentHashMap<Integer,Integer>();
	
	/**
	 * Currently used ports
	 */
	public static final ConcurrentHashMap<Integer,Integer> used_ports = new ConcurrentHashMap<Integer,Integer>();
	
	/**
	 * Current Thread
	 */
	public static TorThread currentThread = null;
	
	

	/**
	 * Initialize the pool of tor connexion used to avoid ggl blocking.
	 */
	public static void setupConnectionPool(int nPorts){
		System.setProperty("socksProxyHost", "127.0.0.1");
		initPool(9050, 9050+nPorts, nPorts);
		runPool();
		
		// switch the port to the first working
		switchPort();
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
	
	
	
	

	/**
	 * Switch the current port, by taking thread from the list, testing it and setting it if needed.
	 * RQ : no testing ? -> equivalent, will be tested at first request, thrown if not ok.
	 * Kills the current thread ; replaces it by a new one to keep a constant number of threads.
	 * [0.5 sucess rate, may need many ?]
	 * 
	 */
	public static void switchPort(){
		
		try{
			// current thread may be null when called at initialization.
			if(currentThread != null){
				currentThread.cleanStop();
				// create the new
				TorThread t = new TorThread();
				torthreads.addLast(t);
				t.start();
				
			}
			// pick the first, list never empty
			currentThread = torthreads.pollFirst();

			System.out.println("Switching request port to : "+currentThread.port);

			System.setProperty("socksProxyPort",new Integer(currentThread.port).toString());

			// display ip : should be deleted for perf reasons
			BufferedReader r = new BufferedReader(new InputStreamReader(new URL("http://ipecho.net/plain").openConnection().getInputStream()));
			String currentLine=r.readLine();
			while(currentLine!= null){System.out.println(currentLine);currentLine=r.readLine();}

		}catch(Exception e){e.printStackTrace();}
			
	}
	
	
	
	/**
	 * Run the all pool.
	 */
	public static void runPool(){
		try{
		for(TorThread t:torthreads){
			t.start();
		}
		
		// heuristic of required waiting time
		
		/**
		 * 
		 * TODO : surely not linear, as depend - on Java multi Thread mgt ; on tor common conf ?
		 * -> find temporal profile ; implement heuristic.
		 * 
		 */
		
		Thread.sleep(10000*torthreads.size());
		}catch(Exception e){e.printStackTrace();}
	}
	
	
	/**
	 * Stop the all pool.
	 */
	public static void stopPool(){
		for(TorThread t:torthreads){
			t.cleanStop();
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
	 * Forcing stop Torpool through PID files.
	 * 
	 * @param p1 start port
	 * @param p2 end port
	 */
	public static void forceStop(int p1,int p2){
		for(int port=p1;port<=p2;port++){
			try{
			String pid = new BufferedReader(new FileReader(new File("tmp/.torpid"+port))).readLine();
			System.out.println("sending SIGTERM to tor... PID : "+pid);
			Process p=Runtime.getRuntime().exec("kill -SIGTERM "+pid);p.waitFor();
			new File("tmp/.torpid"+port).delete();
			}catch(Exception e){e.printStackTrace();}
		}
		
	}
	
	
	
	

}
