/**
 * 
 */
package main;

/**
 * @author Raimbault Juste <br/> <a href="mailto:juste.raimbault@polytechnique.edu">juste.raimbault@polytechnique.edu</a>
 * 
 * Abstract descrption of a content block (Primitive or CommentBlock )
 */
public abstract class Content {
	
	/**
	 * Start line
	 */
	int start;
	
	/**
	 * End line
	 */
	int end;
	
	
	/**
	 * @param e
	 */
	void setEnd(int e) {
		end = e;	
	}
}
