/**
 * 
 */
package main;

import java.io.File;


/**
 * @author Raimbault Juste <br/> <a href="mailto:juste.raimbault@polytechnique.edu">juste.raimbault@polytechnique.edu</a>
 *
 */
public class Main {

	public static String outDirectory;
	
	public static String directory;
	
	public static void processDirectory(String dirPath,String outDirPath){
		try{
			outDirectory = outDirPath;
			directory = dirPath;
			//creates it if not exists
			(new File(outDirectory)).mkdir();
			File dir = new File(dirPath);
			String[] files = dir.list();
			
			for(String s:files){
				if(s.endsWith(".nls")){
					System.out.println("Converting "+s);
					try{(new Class(s)).write();}
					catch(Exception e){e.printStackTrace();}
				}
			}
		}catch(Exception e){e.printStackTrace();}
	}
	
	/**
	 * @param args : directory to process ; output directory
	 */
	public static void main(String[] args) {
		processDirectory(args[0],args[1]);
	}

}
