/**
 * 
 */
package main;

import java.util.LinkedList;

/**
 * @author Raimbault Juste <br/> <a href="mailto:juste.raimbault@polytechnique.edu">juste.raimbault@polytechnique.edu</a>
 *
 */
public class CommentBlock {

	/** text content */
	LinkedList<String> content;
	
	/** start line*/
	int start;
	
	/** end line */
	int end;
	
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
	 * Set end line.
	 * @param e
	 */
	void setEnd(int e){end = e;}
}
