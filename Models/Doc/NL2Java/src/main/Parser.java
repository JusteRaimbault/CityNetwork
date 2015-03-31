/**
 * 
 */
package main;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.InputStreamReader;
import java.util.HashSet;
import java.util.LinkedList;
import java.util.Set;

/**
 * @author Raimbault Juste <br/> <a href="mailto:juste.raimbault@polytechnique.edu">juste.raimbault@polytechnique.edu</a>
 *
 */
public class Parser {
	
	/**
	 * Get comment blocks in a file in occurence order.
	 * 
	 * Dirty to have two passes in file but more simple in parser calls.
	 * 
	 * @param file
	 * @return List of CommentBlock
	 */
	public static LinkedList<CommentBlock> parseComments(String file){
		try{
			LinkedList<CommentBlock> blocks = new LinkedList<CommentBlock>();
			BufferedReader reader = new BufferedReader(new FileReader(new File(file)));
			
			String currentLine = reader.readLine();
			int l = 1;
			boolean inBlock = false;
			CommentBlock currentBlock = null;
			
			while(currentLine != null){
				//condition to enter block
				boolean enteringBlock = currentLine.replace(" ", "").startsWith(";;");
				boolean outOfBlock = ! currentLine.replace(" ", "").startsWith(";");
				if(!inBlock){
					if(enteringBlock){
						//creates new block
						currentBlock = new CommentBlock(currentLine.replace(";", ""),l);
						blocks.add(currentBlock);
						inBlock = true;
					}
				}else{
					if(outOfBlock){inBlock=false;currentBlock.setEnd(l-1);}
					else{currentBlock.addLine(currentLine.replace(";", ""));}
				}
				currentLine = reader.readLine();
				l++;
			}
			
			
			return blocks;
		}
		catch(Exception e){e.printStackTrace();return null;}
	}
	
	
	

	/**
	 * Get primitives in a file in orccurence order
	 * 
	 * @param file
	 * @return List of Primitives
	 */
	public static LinkedList<Primitive> parsePrimitives(String file){
		try{
			LinkedList<Primitive> prims = new LinkedList<Primitive>();
			BufferedReader reader = new BufferedReader(new FileReader(new File(file)));
			
			String currentLine = reader.readLine();
			int l = 1;
			boolean inPrim= false;
			Primitive currentPrim = null;
			
			while(currentLine != null){
				//condition to enter block
				boolean enteringPrim = currentLine.replace(" ", "").startsWith("to");
				boolean outOfPrim = currentLine.replace(" ", "").startsWith("end");
				
				if(!inPrim){
					if(enteringPrim){
						//creates new prim
						String potName = currentLine.split(";")[0].replace(" ", ""),name="";
						if(potName.contains("to-report")){name=potName.replace("to-report", "");}
						else{name=potName.substring(2, potName.length()-2);}
						currentPrim = new Primitive(name,l);
						prims.add(currentPrim);
						inPrim = true;
					}
				}else{
					if(outOfPrim){inPrim=false;currentPrim.setEnd(l);}
				}
				currentLine = reader.readLine();
				l++;
			}
			
			
			return prims;
		}
		catch(Exception e){e.printStackTrace();return null;}
	}
	
	
	
	
	
}
