/**
 * 
 */
package utils;

import java.io.File;
import java.io.FileWriter;
import java.util.Set;

import main.Reference;


/**
 * Export from reference set to RIS.
 * 
 * Basic ascii file writing.
 * 
 * @author Raimbault Juste <br/> <a href="mailto:juste.raimbault@polytechnique.edu">juste.raimbault@polytechnique.edu</a>
 *
 */
public class RISWriter {
	
	/**
	 * Write a set of refs to text file
	 * 
	 * @param filePath
	 * @param refs
	 */
	public static void write(String filePath,Set<Reference> refs){
		try{
			File file = new File(filePath);
			FileWriter writer = new FileWriter(file);
			
			for(Reference r:refs){
				writer.write("TY  - JOUR\nAB  - "+r.resume+"\n");
				for(String a:r.authors){
					writer.write("AU  - "+a+"\n");
				}
				for(String k:r.keywords){
					writer.write("AU  - "+k+"\n");
				}
				writer.write("KW  -\n");
				
				writer.write("T1  - "+r.title+"\n");
				
				writer.write("PY  - "+r.year+"\n");
				
				//do not forget the end of ref tag
				writer.write("ER  -\n");
				
				writer.write("\n\n");
			}
			
			
			writer.close();
			
		}catch(Exception e){e.printStackTrace();}
	}
}
