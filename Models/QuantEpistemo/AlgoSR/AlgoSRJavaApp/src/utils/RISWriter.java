/**
 * 
 */
package utils;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileOutputStream;
import java.io.FileWriter;
import java.io.OutputStreamWriter;
import java.io.Writer;
import java.util.Set;

import main.reference.Reference;


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
	 * @param filePath : file to write
	 * @param refs : references to be written
	 * @param strictIDPolicy : do we apply a strict scholar ID policy == do not write refs without id
	 */
	public static void write(String filePath,Set<Reference> refs,boolean strictIDPolicy){
		try{
			File file = new File(filePath);
			//Writer writer = new BufferedWriter(new OutputStreamWriter(new FileOutputStream(file), "ISO-8859-1"));
			Writer writer = new BufferedWriter(new OutputStreamWriter(new FileOutputStream(file), "UTF-8"));
			
			
			for(Reference r:refs){
				if(strictIDPolicy&&(r.scholarID==null||r.scholarID=="")){continue;}
				writer.write("TY  - JOUR\nAB  - "+r.resume.resume+"\n");
				for(String a:r.authors){
					writer.write("AU  - "+a+"\n");
				}
				for(String k:r.keywords){
					writer.write("KW  - "+k+"\n");
				}
				//writer.write("KW  -\n");
				
				writer.write("T1  - "+r.title.title+"\n");
				if(r.title.translated){
					writer.write("TT  - "+r.title.en_title+"\n");
				}
				
				// year
				writer.write("PY  - "+r.year+"\n");
				
				// write scholar ID
				writer.write("ID  - "+r.scholarID+"\n");
				
				//customized tag : references
				for(Reference t:r.biblio.cited){
					writer.write("BI  - "+BIBWriter.minimalBibTeXString(t)+"\n");
				}
				
				//do not forget the end of ref tag
				writer.write("ER  -\n");
				
				writer.write("\n\n");
			}
			
			
			writer.close();
			
		}catch(Exception e){e.printStackTrace();}
	}
}
