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
public class CSVWriter {

	public static void write(String filePath,String[][] data,String delimiter,String textQuote){
		try{
			FileWriter writer = new FileWriter(new File(filePath));
			//Log.output("Writing with "+writer.toString(),"debug");
			//Log.output("Data : "+data.toString());Log.output(" to File "+filePath,"debug");
			for(int i=0;i<data.length;i++){
				//same row size requirement not checked
				for(int j=0;j<data[i].length;j++){
					//Log.output(data[i][j],"debug");
					writer.write(textQuote+data[i][j]+textQuote);
					if(j!=(data[i].length-1)){writer.write(delimiter);}
				}
				//if(i!=(data.length-1)){writer.write("\n");} // NO, each line including last must have endline
				writer.write("\n");
			}
			writer.close();
		}catch(Exception e){e.printStackTrace();}
		
	}
	
	public static void write(String filePath,LinkedList<String[]> data,String delimiter,String textQuote){
		String[][] res = new String[data.size()][];
		int i=0;
		for(String[] r:data){
			res[i]=r;
			i++;
		}
		write(filePath,res,delimiter,textQuote);
	}
	
}
