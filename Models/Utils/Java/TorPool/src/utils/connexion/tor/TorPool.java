/**
 * 
 */
package utils.connexion.tor;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
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
	 * Are TOR threads verbose ?
	 */
	public static boolean verbose;
	
	public static final int initialThreadSleepingTime = 2000;
	
	

	/**
	 * Initialize the pool of tor connexion used to avoid ggl blocking.
	 */
	/*public static void setupConnectionPool(int nPorts,boolean v){
		verbose=v;
		System.setProperty("socksProxyHost", "127.0.0.1");
		initPool(9050, 9050+nPorts, nPorts);
		runPool();
		
		// switch the port to the first working
		switchPort(false);
	}
	*/
	
	
	
	/**
	 * Start a new pool of tor threads given a port range (included) and thread number
	 * 
	 * @param r1
	 * @param r2
	 */
	public static void initPool(int p1,int p2,int nThreads){
		
		System.setProperty("socksProxyHost", "127.0.0.1");
		
		//create .tor_tmp dir if does not exists
		(new File(".tor_tmp")).mkdir();
		
		// remove old ports file
		(new File(".tor_tmp/ports")).delete();
		
		// verbose running
		verbose = true;
		
		//fill available range table
		available_ports.clear();
		for(int p=p1;p<p2;p++){
			available_ports.put(new Integer(p), new Integer(p));
		}
		
		// create the threads
		for(int k=0;k<nThreads;k++){
			TorThread t = new TorThread();
			torthreads.addLast(t);
			registerThread(t);
		}
		
	}
	
	
	
	

	/**
	 * Switch the current port, by taking thread from the list, testing it and setting it if needed.
	 * RQ : no testing ? -> equivalent, will be tested at first request, thrown if not ok.
	 * Kills the current thread ; replaces it by a new one to keep a constant number of threads.
	 * [0.5 sucess rate, may need many ?]
	 * 
	 */
	/*public static void switchPort(boolean createNew){
		
		try{
			// current thread may be null when called at initialization.
			if(currentThread != null){
				currentThread.cleanStop();
				// create the new
				if(createNew){
					TorThread t = new TorThread();
					torthreads.addLast(t);
					t.start();
					Thread.sleep(initialThreadSleepingTime);
				}	
				
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
	*/
	
	
	/**
	 * Start a new thread.
	 * 
	 */
	public static void newThread(){
		try{
			TorThread t = new TorThread();
			torthreads.addLast(t);
			registerThread(t);
			t.start();
			Thread.sleep(initialThreadSleepingTime);
		}catch(Exception e){e.printStackTrace();}
	}
	
	
	/**
	 * Register a thread in the communication file.
	 * 
	 * @param t
	 */
	public static void registerThread(TorThread t){
		//The TorPool is assumed to be used with TorPoolManager class, hence no pb on locking/concurrency on port file
		try{
			BufferedWriter w = new BufferedWriter(new FileWriter(new File(".tor_tmp/ports"),true));
			w.write(new Integer(t.port).toString());w.newLine();
			w.close();
		}catch(Exception e){System.out.println("Error while registring TorThread : ");e.printStackTrace();}
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
		 * PB : depends also on connexion ; memory ; etc
		 * 
		 */
		
		int sleepingTime = initialThreadSleepingTime*torthreads.size();
		for(int t=0;t<torthreads.size();t++){Thread.sleep(initialThreadSleepingTime);System.out.println("Sleeping : rem. "+(sleepingTime-t*initialThreadSleepingTime)/1000+"sec");}
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
	/*
	public static void forceStopPID(int pid1,int pid2){
		for(int pid=pid1;pid<=pid2;pid++){
			try{
			System.out.println("sending SIGTERM to tor... PID : "+pid);
			Process p=Runtime.getRuntime().exec("kill -SIGTERM "+pid);p.waitFor();
			}catch(Exception e){e.printStackTrace();}
		}
		
	}
*/	


	/**
	 * Forcing stop Torpool through PID files.
	 * 
	 * @param p1 start port
	 * @param p2 end port
	 */
	/*public static void forceStop(int p1,int p2){
		for(int port=p1;port<=p2;port++){
			try{
			String pid = new BufferedReader(new FileReader(new File("tmp/.torpid"+port))).readLine();
			System.out.println("sending SIGTERM to tor... PID : "+pid);
			Process p=Runtime.getRuntime().exec("kill -SIGTERM "+pid);p.waitFor();
			new File("tmp/.torpid"+port).delete();
			}catch(Exception e){e.printStackTrace();}
		}
		
	}
	*/
	
	/**
	 * Pool launcher, to be used from the command line.
	 * 
	 * @param args
	 *    args[0] : number of threads. ports are starting from 9050 by default [TODO : specifying port number / check if running tor]
	 */
	public static void main(String[] args){
		if(args.length != 1){System.out.println("Usage : args[0] = number of threads");}
		else{
			try{
				
				// configure application shutdown
				// TODO : Does not work with interrupted signal !
				Runtime.getRuntime().addShutdownHook(new Thread() {
			        @Override
			            public void run() {
			                System.out.println("Exiting cleanly...");
			                stopPool();
			            }  
			    });
				
				
				int threadNumber = Integer.parseInt(args[0]);
				initPool(9050, 9050+threadNumber, threadNumber);
			    runPool();
				
			}
			catch(Exception e){e.printStackTrace();}
		}
	}
	
	

}
