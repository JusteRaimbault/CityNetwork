/**
 * 
 */
package main;

import java.util.LinkedList;

/**
 * @author Raimbault Juste <br/> <a href="mailto:juste.raimbault@polytechnique.edu">juste.raimbault@polytechnique.edu</a>
 *
 */
public class Class {
	

	/**
	 * Contents
	 */
	public LinkedList<Content> contents;	
	public LinkedList<CommentBlock> comments;
	public LinkedList<Primitive> prims;
	
	/**
	 * Class name
	 */
	public String name;
	
	
	public Class(String file) throws Exception{
		//get name from filename
		name = file.split(".nls")[0];
		comments = Parser.parseComments(file);
		//for(CommentBlock c:comments){System.out.println(c.toString());}
		prims = Parser.parsePrimitives(file);
		//for(Primitive c:prims){System.out.println(c.toString());}
		
		// fill content
		this.fillContent();
		//check consistence
		if(!Writer.checkConsistence(contents)){throw new Exception("Inconsistent file");}
	}
	
	/**
	 * Organize content in a consistent list
	 */
	public void fillContent() throws Exception {
		contents = new LinkedList<Content>();
		CommentBlock currentCommentBlock = null;
		Primitive currentPrimitive = null;
		if(prims.size()>0){currentPrimitive = prims.removeFirst();}
		if(comments.size()>0){currentCommentBlock = comments.removeFirst();}
		
		
		while(comments.size()>0||prims.size()>0){
			System.out.println(currentCommentBlock);System.out.println(currentPrimitive);
			//check non intersection of current Contents
			if(!(currentCommentBlock.end<=currentPrimitive.start||currentCommentBlock.start>=currentPrimitive.end||(currentCommentBlock.start>=currentPrimitive.start&&currentCommentBlock.end<=currentPrimitive.end))){
				throw new Exception("Inconsistent file (comments/prims)");
			}
			
			if (currentCommentBlock.end < currentPrimitive.start-1){contents.add(currentCommentBlock);if(comments.size()>0){currentCommentBlock=comments.removeFirst();};}
			else if(currentCommentBlock.end+1==currentPrimitive.start){currentPrimitive.header=currentCommentBlock;if(comments.size()>0){currentCommentBlock=comments.removeFirst();}}
			else if (currentCommentBlock.start>=currentPrimitive.start&&currentCommentBlock.end<=currentPrimitive.end){currentPrimitive.insideComments.add(currentCommentBlock);if(comments.size()>0){currentCommentBlock=comments.removeFirst();}}
			else if (currentCommentBlock.start >= currentPrimitive.end){contents.add(currentPrimitive);contents.add(currentCommentBlock);if(comments.size()>0){currentCommentBlock=comments.removeFirst();};if(prims.size()>0){currentPrimitive=prims.removeFirst();}}
			else{contents.add(currentPrimitive);if(prims.size()>0){currentPrimitive=prims.removeFirst();}}//add primitive if comment block has no position ?
		}
		
		
	}
	
	
	/**
	 * Write the Class
	 */
	public void write(){
		Writer.writeAllContents(contents, name, Main.outDirectory+name+".java");
	}
	
	
	
}
