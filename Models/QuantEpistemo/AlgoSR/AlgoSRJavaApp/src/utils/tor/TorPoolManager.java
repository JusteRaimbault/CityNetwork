/**
 * 
 */
package utils.tor;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.InputStreamReader;
import java.net.URL;
import java.util.LinkedList;

import utils.Log;

/**
 * Manager communicating with the external TorPool app, via .tor_tmp files (TorPool must be run within same directory for now)
 * 
 * @author Raimbault Juste <br/> <a href="mailto:juste.raimbault@polytechnique.edu">juste.raimbault@polytechnique.edu</a>
 *
 */
public class TorPoolManager {

	/**
	 * TODO : Concurrent access from diverse apps to a single pool ?
	 * Difficult as would need listener on this side...
	 * 
	 */
	
	/**
	 * the port currently used.
	 */
	public static int currentPort=0;
	
	
	public static boolean hasTorPoolConnexion = false;
	
	
	/**
	 * Checks if a pool is currently running, and setup initial port correspondingly.
	 */
	public static void setupTorPoolConnexion() throws Exception {
		
		Log.stdout("Setting up TorPool connection...");
		
		// check if pool is running.
		checkRunningPool();
		
		System.setProperty("socksProxyHost", "127.0.0.1");
		
		
		try{
			//changePortFromFile(new BufferedReader(new FileReader(new File(".tor_tmp/ports"))));
			switchPort();
		}catch(Exception e){e.printStackTrace();}
		
		//showIP();
		
		hasTorPoolConnexion = true;
	}
	
	
	/**
	 * Send a stop signal to the whole pool -> needed ? Yes to avoid having tasks going on running on server e.g.
	 */
	public static void closePool(){
		
	}
	
	
	private static void checkRunningPool() throws Exception{
		if(!new File(".tor_tmp/ports").exists()){throw new Exception("NO RUNNING TOR POOL !"); }
	}
	
	
	/**
	 * Switch the current port to the oldest living TorThread.
	 *   - Reads communication file -
	 */
	public static void switchPort(){
		try{
			//send kill signal via kill file
			// if current port is set
			if(currentPort!=0){
				Log.stdout("Sending kill signal for current tor thread...");
				(new File(".tor_tmp/kill"+currentPort)).createNewFile();
			}
			
			//waiting for lock to read new available port
			/*boolean locked = true;int t=0;
			while(locked){
				Log.stdout("Waiting for lock on .tor_tmp/lock");
				Thread.sleep(200);
				locked = (new File(".tor_tmp/lock")).exists();t++;
			}*/
			
			// make the next step concurrent
			// -> also lock ports file
			// create the lock
			//File lock = new File(".tor_tmp/lock");lock.createNewFile();
			
			// read new port - delete taken port from communication file
			//BufferedReader r = new BufferedReader(new FileReader(new File(".tor_tmp/ports")));
			String portpath = ".tor_tmp/ports";
			String lockfile = ".tor_tmp/lock";

			changePortFromFile(portpath,lockfile);


			/*
			LinkedList<String> queue = new LinkedList<String>();
			String currentLine = r.readLine();
			while(currentLine!=null){
				queue.add(currentLine);currentLine = r.readLine();
			}
			*/

			//now rewrite the port file
			// FIXME change the concurrence architecture -> available ports should be written server-side
			/*
			(new File(".tor_tmp/ports")).delete();
			BufferedWriter w = new BufferedWriter(new FileWriter(new File(".tor_tmp/ports")));
			for(String p:queue){w.write(p);w.newLine();}
			w.close();
			*/

			// release the lock
			//lock.delete();
			
			// show ip to check
			showIP();
			
		}catch(Exception e){e.printStackTrace();}
	}
	
	/**
	 *
	 * @param portpath
	 * @param lockfile
	 */
	private static void changePortFromFile(String portpath,String lockfile){
		//String newPort = "9050";
		String newPort = "";

		// assumes ports with 4 digits
		// and that the file always has a content
		while(newPort.length()<4) {
			try{
				newPort = readLineWithLock(portpath,lockfile);
				if(newPort.length()<4){System.out.println("Waiting for an available tor port");Thread.sleep(1000);}
			}catch(Exception e){e.printStackTrace();}
		}
		
		// set the new port
		System.setProperty("socksProxyPort",newPort);
		currentPort = Integer.parseInt(newPort);
		Log.stdout("Current Port set to "+newPort);
	}

	private static String readLineWithLock(String portpath,String lockfile){
		String res = "";
		try{
			boolean locked = true;int t=0;
			while(locked){
				Log.stdout("Waiting for lock on "+lockfile);
				Thread.sleep(200);
				locked = (new File(lockfile)).exists();t++;
			}
			File lock = new File(".tor_tmp/lock");lock.createNewFile();
			BufferedReader r = new BufferedReader(new FileReader(new File(portpath)));
			res=r.readLine();
			lock.delete();
		}catch(Exception e){e.printStackTrace();}
		return(res);
	}
	
	
	
	
	// Test functions
	
	private static void testRemotePool(){
		try{setupTorPoolConnexion();
		
		showIP();
		
		while(true){
			Thread.sleep(10000);
			Log.stdout("TEST : Switching port... ");
			switchPort();
			showIP();
		}
		}catch(Exception e){e.printStackTrace();}
	}
	
	private static void showIP(){
		try{
		BufferedReader r = new BufferedReader(new InputStreamReader(new URL("http://ipecho.net/plain").openConnection().getInputStream()));
		String currentLine=r.readLine();
		while(currentLine!= null){Log.stdout(currentLine);currentLine=r.readLine();}
		}catch(Exception e){e.printStackTrace();}
	}
	
	
	public static void main(String[] args){
		testRemotePool();
	}
	
	
	
	
	
	
}
