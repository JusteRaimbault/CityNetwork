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
	public static int currentPort;
	
	/**
	 * Checks if a pool is currently running, and setup initial port correspondingly.
	 */
	public static void setupTorPoolConnexion() throws Exception {
		
		// check if pool is running.
		checkRunningPool();
		
		System.setProperty("socksProxyHost", "127.0.0.1");
		
		
		try{
			changePortFromFile(new BufferedReader(new FileReader(new File(".tor_tmp/ports"))));
		}catch(Exception e){e.printStackTrace();}
		
		showIP();
	}
	
	
	/**
	 * Send a stop signal to the whole pool -> needed ? Yes to avoid having tasks going on running on server e.g.
	 */
	public static void closePool(){
		
	}
	
	
	private static void checkRunningPool() throws Exception{
		System.out.println("Setting up TorPool connection...");
		if(!new File(".tor_tmp/ports").exists()){throw new Exception("NO RUNNING TOR POOL !"); }
	}
	
	
	/**
	 * Switch the current port to the oldest living TorThread.
	 *   - Reads communication file -
	 */
	public static void switchPort(){
		try{
			//send kill signal via kill file
			System.out.println("Sending kill signal for current tor thread...");
			(new File(".tor_tmp/kill"+currentPort)).createNewFile();
			
			//waiting for lock to read new available port
			boolean locked = true;int t=0;
			while(locked){
				System.out.println("Waiting for lock on .tor_tmp/lock");
				Thread.sleep(100);
				locked = (new File(".tor_tmp/lock")).exists();t++;
			}
			
			// read new port - delete taken port from communication file
			BufferedReader r = new BufferedReader(new FileReader(new File(".tor_tmp/ports")));
			
			changePortFromFile(r);
			
			LinkedList<String> queue = new LinkedList<String>();
			String currentLine = r.readLine();
			while(currentLine!=null){
				queue.add(currentLine);currentLine = r.readLine();
			}
			//now rewrite the port file
			(new File(".tor_tmp/ports")).delete();
			BufferedWriter w = new BufferedWriter(new FileWriter(new File(".tor_tmp/ports")));
			for(String p:queue){w.write(p);w.newLine();}
			w.close();
			
			// show ip to check
			showIP();
			
		}catch(Exception e){e.printStackTrace();}
	}
	
	/**
	 * 
	 * 
	 * @param r
	 */
	private static void changePortFromFile(BufferedReader r){
		String newPort = "9050";
		try{
		   newPort = r.readLine();
		}catch(Exception e){e.printStackTrace();}
		
		// set the new port
		System.setProperty("socksProxyPort",newPort);
		currentPort = Integer.parseInt(newPort);
		System.out.println("Current Port set to "+newPort);
	}
	
	
	
	
	// Test functions
	
	private static void testRemotePool(){
		try{setupTorPoolConnexion();
		
		showIP();
		
		while(true){
			Thread.sleep(10000);
			System.out.println("TEST : Switching port... ");
			switchPort();
			showIP();
		}
		}catch(Exception e){e.printStackTrace();}
	}
	
	private static void showIP(){
		try{
		BufferedReader r = new BufferedReader(new InputStreamReader(new URL("http://ipecho.net/plain").openConnection().getInputStream()));
		String currentLine=r.readLine();
		while(currentLine!= null){System.out.println(currentLine);currentLine=r.readLine();}
		}catch(Exception e){e.printStackTrace();}
	}
	
	
	public static void main(String[] args){
		testRemotePool();
	}
	
	
	
	
	
	
}
