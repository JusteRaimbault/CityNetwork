/**
 * 
 */
package utils;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;

/**
 * @author Raimbault Juste <br/> <a href="mailto:juste.raimbault@polytechnique.edu">juste.raimbault@polytechnique.edu</a>
 *
 */
public class Zipper {

	
	public static void zip(String filePath){
		try{
		String prefix = filePath.split(".ris")[0];
		String filename = filePath.split("/")[filePath.split("/").length-1].split(".ris")[0];
		FileOutputStream fout = new FileOutputStream(prefix+".zip");
		ZipOutputStream zout = new ZipOutputStream(fout);
		ZipEntry ze = new ZipEntry(filename);
		zout.putNextEntry(ze);
		FileInputStream input = new FileInputStream(new File(filePath));
		int currentbyte = input.read();
		while(currentbyte != -1){
			zout.write(currentbyte);
			currentbyte = input.read();
		}
		zout.closeEntry();
		zout.close();
		}catch(Exception e){e.printStackTrace();}
	}
	
	
}
