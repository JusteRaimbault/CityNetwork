/**
 * 
 */
package main;

import java.util.HashSet;
import java.util.Set;

/**
 * @author Raimbault Juste <br/> <a href="mailto:juste.raimbault@polytechnique.edu">juste.raimbault@polytechnique.edu</a>
 *
 * Represents a primitive.
 * 
 * No need for an abstract class wrapping comment block and primitive, very few in common (start and end) ?
 * Yes, more easy to handle OutputStreamWriter (writes a Set of Content)
 */
public class Primitive extends Content {
	
	/**
	 * name
	 */
	String name;
	
	/**
	 * return type. Retrieven from @type annotation, with mapping ?
	 */
	String javaType;
	
	
	// add pointer to comments block, header and inside ? 
	
	/**
	 * Header comment block (CommentBlock.EMPTY if none)
	 */
	CommentBlock header;
	
	/**
	 * Inside comments.
	 */
	Set<CommentBlock> insideComments;
	
	/**
	 * Basic constructor.
	 * 
	 * @param name
	 * @param s
	 */
	Primitive(String n,int s){
	   	name=n;start=s;
	   	header=CommentBlock.EMPTY;//empty header by default
	   	insideComments=new HashSet<CommentBlock>();
	}

	
	
	
	
	
	
}
