/**
 * 
 */
package utils;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.util.HashMap;
import java.util.LinkedList;

/**
 * @author Raimbault Juste <br/> <a href="mailto:juste.raimbault@polytechnique.edu">juste.raimbault@polytechnique.edu</a>
 *
 */
public class CSVReader {

	
	public static String[][] read(String filePath,String delimiter,String quote){
		try{
		   BufferedReader reader = new BufferedReader(new FileReader(new File(filePath)));
		   LinkedList<String[]> listRes = new LinkedList<String[]>();
		   String currentLine = reader.readLine().replace(quote, ""); // juste remove the quotes
		   while(currentLine!= null){
			   listRes.addLast(currentLine.split(delimiter));
			   currentLine = reader.readLine();
			   if(currentLine != null){currentLine = currentLine.replace(quote, "");}
		   }
		   reader.close();
		   //convert list to tab
		   //toArray does not return a matrix
		   String[][] res = new String[listRes.size()][listRes.get(0).length];
		   for(int i=0;i<res.length;i++){res[i]=listRes.get(i);}
		   return res;
		}catch(Exception e){e.printStackTrace();return null;}
	}
	
	public static HashMap<String,String> readMap(String file,String delimiter,String quote){
		HashMap<String,String> res = new HashMap<String,String>();
		String[][] tab = read(file,delimiter,quote);
		for(int r=0;r<tab.length;r++){
			res.put(tab[r][0], tab[r][1]);
		}
		return res;
	}
	
	
	public static void test(){
		String[][] f = read("data/testIterative/refs_0_keywords.csv","\t","");
		for(int i=0;i<f.length;i++){
			for(int j=0;j<f[i].length;j++){
				System.out.println(f[i][j]);
			}
		}
	}
	
	
}
