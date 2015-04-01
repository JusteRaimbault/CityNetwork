/**
 * 
 */
package main;

import java.util.LinkedList;

/**
 * @author Raimbault Juste <br/> <a href="mailto:juste.raimbault@polytechnique.edu">juste.raimbault@polytechnique.edu</a>
 *
 */
public class CommentBlock extends Content {

	/**
	 * EMPTY block, more elegant than using null
	 */
	public static final CommentBlock EMPTY = new CommentBlock("",0);
	
	
	/** text content */
	LinkedList<String> content;
	
	
	/**
	 * Basic constructor used at the encounter of beginning.
	 * 
	 * @param line
	 * @param s
	 */
	CommentBlock(String line,int s){
		content = new LinkedList<String>();
		content.add(line);
		start = s;
	}
	
	/**
	 * add a line to content
	 * @param line
	 */
	void addLine(String line){
		content.add(line);
	}
	
	
	
	
	
	/**
	 * 
	 * @return
	 */
	public String toString(){
		String res = "---------------\nCommentBlock, start "+start+", end "+end+"\n";
		for(String l:content){res+=l+"\n";}
		return res;
	}
	
	
}
