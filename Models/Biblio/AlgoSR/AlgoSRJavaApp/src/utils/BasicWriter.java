/**
 * 
 */
package utils;

import java.io.File;
import java.io.FileWriter;
import java.util.LinkedList;
import java.util.Set;

/**
 * @author Raimbault Juste <br/> <a href="mailto:juste.raimbault@polytechnique.edu">juste.raimbault@polytechnique.edu</a>
 *
 */
public class BasicWriter {

	public static void write(String filePath,LinkedList<String> data){
		try{
			FileWriter writer = new FileWriter(new File(filePath));
			for(String row:data){
				writer.write(row);
				writer.write("\n");
			}
			writer.close();
		}catch(Exception e){e.printStackTrace();}
		
	}
	
}
