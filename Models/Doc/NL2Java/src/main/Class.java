/**
 * 
 */
package main;

import java.util.HashSet;
import java.util.LinkedList;
import java.util.Set;

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
		//for(Content c:contents){System.out.println(c);}
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
		if(prims.size()>0){currentPrimitive = prims.getFirst();}
		int pIndex = 1;
		Set<CommentBlock> toRemove = new HashSet<CommentBlock>();
		for(CommentBlock c:comments){
			if(c.end+1==currentPrimitive.start){toRemove.add(c);currentPrimitive.header=c;}
			if(c.start>=currentPrimitive.start&&c.end<=currentPrimitive.end){toRemove.add(c);currentPrimitive.insideComments.add(c);}
			//otherwise does not remove but change prim
			if(c.start >= currentPrimitive.end){currentPrimitive=prims.get(Math.min(pIndex, prims.size()-1));pIndex++;}
		}
		//remove -- no pb with pointer, same object.
		for(CommentBlock r:toRemove){comments.remove(r);}
		//for(CommentBlock c:comments){System.out.println(c);}
		
		// assumes at least one primitive
		if(prims.size()>0){currentPrimitive = prims.getFirst();}	
		
		if(comments.size()==0){for(Primitive p:prims){contents.add(p);}}
		else{
			currentCommentBlock = comments.removeFirst();
			while(comments.size()>0||prims.size()>0){
				if(currentPrimitive.start > currentCommentBlock.end){contents.add(currentCommentBlock);if(comments.size()>0){currentCommentBlock = comments.removeFirst();};}
				else{if(prims.size()>0){currentPrimitive = prims.removeFirst();};contents.add(currentPrimitive);}
				System.out.println(currentPrimitive);
				System.out.println(currentCommentBlock);
		    }
		}
		
		//System.out.println("New class : "+contents);
		/*
		
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
		*/
		
	}
	
	
	/**
	 * Write the Class
	 */
	public void write(){
		System.out.println("Writing "+contents);
		Writer.writeAllContents(contents, name, Main.outDirectory+name+".java");
	}
	
	
	
}
