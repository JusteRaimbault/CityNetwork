/**
 * 
 */
package utils;


import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.util.Date;



/**
 * 
 * Class managing log file.
 * Writes in external log file if the option has been selected.
 * 
 * @author Raimbault Juste <br/> <a href="mailto:juste.raimbault@polytechnique.edu">juste.raimbault@polytechnique.edu</a>
 *
 */
public class Log {
	
	/** BufferedWriter to write */
	private static File f;
	
	
	/**
	 * Inits the log file.
	 * 
	 * <p>Names the log file with the currentDate</p>
	 * 
	 */
	@SuppressWarnings("deprecation")
	public static void initLog(){
		try{
			Date d = new Date();
			
			//creates log directory if doesn't exists
			File dir = new File("log");dir.mkdir();
			
			//open output buffer
			f = new File("log/"+d.toGMTString().replace(' ', '_').replace('/', ':')+".txt");
			f.setWritable(true,false);
			
		}
		catch(Exception e){System.out.println("initLog error : "+e.toString());}
	}
	
	
	/**
	 * 
	 * Outprints a success message in the logFile
	 * 
	 * @param successMessage - the text of the success message
	 * 
	 */
	public static void success(String successMessage){
		String out = successMessage+"... OK";
		try{
			BufferedWriter w = new BufferedWriter(new FileWriter(f,true));
			w.write(out);w.newLine();w.close();}
		catch(Exception e){System.out.println(out);}
	}
	
	
	
	/**
	 * 
	 * Outprints a fail message in the logFile
	 * 
	 * @param failMessage - the text of the fail message
	 * 
	 */
	public static void fail(String failMessage){
		String out = failMessage+"... FAIL";
		try{
			BufferedWriter w = new BufferedWriter(new FileWriter(f,true));
			w.write(out);w.newLine();w.close();}
		catch(Exception e){System.out.println(out);}
	}
	
	/***
	 * 
	 * Outprints a given message in the log file
	 * 
	 * @param message
	 */
	public static void output(String message){
		try{
			BufferedWriter w = new BufferedWriter(new FileWriter(f,true));
			w.write(message);w.newLine();w.close();}
		catch(Exception e){System.out.println(message);}
	}
	
	
	
	/**
	 * Jumps a line in log.
	 */
	public static void newLine(int n){
		try{
			BufferedWriter w = new BufferedWriter(new FileWriter(f,true));
			for(int i=0;i<n;i++)w.newLine();w.close();}
		catch(Exception e){System.out.println();}
	}
	
}

