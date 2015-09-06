/**
 * 
 */
package utils.tor;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;

/**
 * 
 * Function for managing Tor connection pool.
 * 
 * @author Raimbault Juste <br/> <a href="mailto:juste.raimbault@polytechnique.edu">juste.raimbault@polytechnique.edu</a>
 *
 */
public class TorPool {
	
	
	

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
	
	public static void stopPool(){
		for(TorThread t:TorThread.torthreads){
			t.cleanStop();
		}
	}
	
	
	/**
	 * Switch the current port, by taking thread from the list, testing it and setting it if needed.
	 */
	public static void switchPort(){
		
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
		TorThread.available_ports.clear();
		for(int p=p1;p<p2;p++){
			TorThread.available_ports.put(new Integer(p), new Integer(p));
		}
		
		// create the threads
		for(int k=0;k<nThreads;k++){
			TorThread t = new TorThread();
			TorThread.torthreads.addLast(t);
		}
		
	}
	
	
	public static void runPool(){
		try{
		for(TorThread t:TorThread.torthreads){
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
		
		Thread.sleep(5000*TorThread.torthreads.size());
		}catch(Exception e){e.printStackTrace();}
	}
	
	
	
	
	

}
