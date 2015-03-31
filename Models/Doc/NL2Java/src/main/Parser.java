/**
 * 
 */
package main;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.InputStreamReader;
import java.util.HashSet;
import java.util.Set;

/**
 * @author Raimbault Juste <br/> <a href="mailto:juste.raimbault@polytechnique.edu">juste.raimbault@polytechnique.edu</a>
 *
 */
public class Parser {
	
	/**
	 * Get comment blocks in a file.
	 * 
	 * Dirty to have two passes in file but more simple in parser calls.
	 * 
	 * @param file
	 * @return HashSet of CommentBlock
	 */
	public static Set<CommentBlock> parseComments(String file){
		try{
			HashSet<CommentBlock> blocks = new HashSet<CommentBlock>();
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
	
}
