/**
 * 
 */
package utils;

import main.Reference;
import it.uniroma1.dis.wsngroup.gexf4j.core.EdgeType;
import it.uniroma1.dis.wsngroup.gexf4j.core.Gexf;
import it.uniroma1.dis.wsngroup.gexf4j.core.Graph;
import it.uniroma1.dis.wsngroup.gexf4j.core.Mode;
import it.uniroma1.dis.wsngroup.gexf4j.core.Node;
import it.uniroma1.dis.wsngroup.gexf4j.core.data.Attribute;
import it.uniroma1.dis.wsngroup.gexf4j.core.data.AttributeClass;
import it.uniroma1.dis.wsngroup.gexf4j.core.data.AttributeList;
import it.uniroma1.dis.wsngroup.gexf4j.core.data.AttributeType;
import it.uniroma1.dis.wsngroup.gexf4j.core.impl.GexfImpl;
import it.uniroma1.dis.wsngroup.gexf4j.core.impl.StaxGraphWriter;
import it.uniroma1.dis.wsngroup.gexf4j.core.impl.data.AttributeListImpl;

import java.io.File;
import java.io.FileWriter;
import java.io.Writer;
import java.util.HashMap;
import java.util.Set;

/**
 * @author Raimbault Juste <br/> <a href="mailto:juste.raimbault@polytechnique.edu">juste.raimbault@polytechnique.edu</a>
 *
 */
public class GEXFWriter{
	
	/**
	 * Write the graph of References to gexf file, with link as citation network.
	 * 
	 * @param filepath
	 * @param refs
	 */
	public static void writeCitationNetwork(String filepath,Set<Reference> refs){
		
		Gexf gexf = new GexfImpl();		
		//gexf.getMetadata().setCreator("").setDescription(");
		Graph graph = gexf.getGraph();
		graph.setDefaultEdgeType(EdgeType.DIRECTED).setMode(Mode.STATIC);		
		AttributeList attrList = new AttributeListImpl(AttributeClass.NODE);
		graph.getAttributeLists().add(attrList);
		
		// add attributes to nodes
		Attribute attID = attrList.createAttribute("0", AttributeType.STRING, "id");
		Attribute attSchID = attrList.createAttribute("1", AttributeType.STRING, "scholarID");
		Attribute attTitle = attrList.createAttribute("2", AttributeType.STRING, "title");
		Attribute attAuthors = attrList.createAttribute("3", AttributeType.STRING, "authors");
		Attribute attResume = attrList.createAttribute("4", AttributeType.STRING, "resume");
		Attribute attKeywords = attrList.createAttribute("5", AttributeType.STRING, "keywords");
		Attribute attYear = attrList.createAttribute("6", AttributeType.STRING, "year");
		
		// create nodes - maintaining a HashMap Ref -> Node
		HashMap<Reference,Node> nodes = new HashMap<Reference,Node>();
		
		int i=0;
		for(Reference ref:refs){
			String authors = "";for(String a:ref.authors){authors=authors+a+" and ";}if(authors.length()>5)authors=authors.substring(0, authors.length()-5);
			String keywords = "";for(String k:ref.keywords){keywords=keywords+k+" ; ";}if(keywords.length()>3)keywords=keywords.substring(0, keywords.length()-3);
			ref.id=new Integer(i).toString();
			
			Node node = graph.createNode(ref.id).setLabel(ref.title);
			node.getAttributeValues()
			  .addValue(attID, ref.id)
			  .addValue(attSchID, ref.scholarID)
			  .addValue(attTitle, ref.title)
			  .addValue(attAuthors, authors)
			  .addValue(attResume,ref.resume)
			  .addValue(attKeywords,keywords)
			  .addValue(attYear, ref.year)
			  ;
			nodes.put(ref, node);
			i++;
		}
		
		// create citation links
		for(Reference ref:nodes.keySet()){
			Node d = nodes.get(ref);
			for(Reference c:ref.citing){
				//all refs must be in table (set consistency) and are therefore in node table
				if(!d.hasEdgeTo(c.id)){nodes.get(c).connectTo(d);}
			}
		}
		
		
		// write to file
		StaxGraphWriter graphWriter = new StaxGraphWriter();
		try {
			FileWriter out =  new FileWriter(new File(filepath), false);
			graphWriter.writeToStream(gexf, out, "UTF-8");
		} catch (Exception e) {
			e.printStackTrace();
		}
		
		
		
	}
	
	
	
	/**
	 * Write the kw network to gexf graph file ; in time ?
	 * PB : do not have occurence of kws in papers, should be recalculated
	 * 
	 * @TODO
	 * 
	 */
	public static void writeKeywordsNetwork(){
		
	}
	
	
	
	
	
	public static void main(String[] args){
		
		// tests
		
		
	}
	
	
	
	
}
