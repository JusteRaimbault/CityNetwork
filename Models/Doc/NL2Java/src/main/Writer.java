/**
 * 
 */
package main;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.util.LinkedList;
import java.util.List;

/**
 * @author Raimbault Juste <br/> <a href="mailto:juste.raimbault@polytechnique.edu">juste.raimbault@polytechnique.edu</a>
 * 
 * Static output writer
 * 
 */
public class Writer {
	
	/**
	 * 
	 * @param contents
	 * @return
	 */
	public static boolean checkConsistence(List<Content> contents){
		boolean res = true;
		int prevEnd=0;
		for(Content c:contents){res=res&&(prevEnd<=c.start);prevEnd=c.end;}
		return res;
	}
	
	/**
	 * 
	 * @param contents
	 */
	public static void writeAllContents(LinkedList<Content> contents,String className,String file){
		try{
			BufferedWriter writer = new BufferedWriter(new FileWriter(new File(file)));
			
			// write class header
			//TODO : add Header class ?
			// use className for now
			
			//check if first content is a comment, then writes it before the class beginning
			if(contents.getFirst() instanceof CommentBlock){writeContent(contents.removeFirst(),writer);}
			
			//write class declaration
			writer.write("public class "+className+" {");
			
			for(Content c:contents){writeContent(c,writer);}
			
			writer.write("}");
			writer.close();
			
		}catch(Exception e){e.printStackTrace();}
	}
	
	/**
	 * 
	 * @param content
	 * @param writer
	 */
	public static void writeContent(Content content,BufferedWriter writer){
		if(content instanceof CommentBlock){writeCommentBlock((CommentBlock)content,writer);}
		if(content instanceof Primitive){writePrimitive((Primitive)content,writer);}
	}
	
	/**
	 * 
	 * @param com
	 * @param w
	 */
	public static void writeCommentBlock(CommentBlock com,BufferedWriter w){
		try{
			w.write("\n/**");
			for(String s:com.content){
				w.write("* "+s+"\n");
			}
			w.write("*/");
		}catch(Exception e){e.printStackTrace();}
	}
	
	/**
	 * 
	 * @param p
	 * @param w
	 */
	public static void writePrimitive(Primitive p,BufferedWriter w){
		if(p.header != CommentBlock.EMPTY){writeCommentBlock(p.header,w);}
		w.write("public static "+p.javaType+" ");
	}
	
	
}
