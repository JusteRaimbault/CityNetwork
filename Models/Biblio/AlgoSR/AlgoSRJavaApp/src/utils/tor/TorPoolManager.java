/**
 * 
 */
package utils.tor;

import java.io.File;

/**
 * Manager communicating with the external TorPool app, via .tor_tmp files (TorPool must be run within same directory for now)
 * 
 * @author Raimbault Juste <br/> <a href="mailto:juste.raimbault@polytechnique.edu">juste.raimbault@polytechnique.edu</a>
 *
 */
public class TorPoolManager {

	
	/**
	 * the port currently used.
	 */
	public static int currentPort;
	
	/**
	 * Checks if a pool is currently running, and setup initial port correspondingly.
	 */
	public static void setupTorPoolConnexion(){
		
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
			//TODO
			
			
		}catch(Exception e){e.printStackTrace();}
	}
	
	
	
}
