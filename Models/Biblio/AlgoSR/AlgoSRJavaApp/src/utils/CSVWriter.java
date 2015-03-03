/**
 * 
 */
package utils;

import java.io.File;
import java.io.FileWriter;

/**
 * @author Raimbault Juste <br/> <a href="mailto:juste.raimbault@polytechnique.edu">juste.raimbault@polytechnique.edu</a>
 *
 */
public class CSVWriter {

	public static void write(String filePath,String[][] data,String delimiter){
		try{
			FileWriter writer = new FileWriter(new File(filePath));
			Log.output("Writing with "+writer.toString());
			Log.output("Data : "+data.toString());Log.output(" to File "+filePath);
			for(int i=0;i<data.length;i++){
				//same row size requirement not checked
				for(int j=0;j<data[i].length;j++){
					writer.write(data[i][j]);
					if(j!=(data[i].length-1)){writer.write(delimiter);}
				}
				//if(i!=(data.length-1)){writer.write("\n");} // NO, each line including last must have endline
				writer.write("\n");
			}
			writer.close();
		}catch(Exception e){e.printStackTrace();}
		
	}
	
}
