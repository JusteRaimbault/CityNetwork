/**
 * 
 */
package utils;

import main.reference.Reference;
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
import java.util.HashSet;
import java.util.LinkedList;
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
		
		// ids can be unfilled or non-consistent : we must copy the set and add consistent ids
		//refs = new HashSet<Reference>(refs);
		int currentID=1;//start at 1
		for(Reference r:Reference.references.keySet()){// do on hashconsing table ? DIRTYYYY
			r.id = new Integer(currentID).toString();currentID++;
		}
		
		
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
		
		// construct the set of additional attributes
		HashMap<String,Attribute> additionalAttributes = new HashMap<String,Attribute>();
		HashSet<String> addAttrNames = new HashSet<String>();
		int id = 7;
		for(Reference ref:refs){
			for(String att:ref.attributes.keySet()){
				if(!addAttrNames.contains(att)){//new attribute
					addAttrNames.add(att);
					Attribute nextAttr = attrList.createAttribute(new Integer(id).toString(), AttributeType.STRING, att);
					additionalAttributes.put(att,nextAttr);
					id++;
				}
			}
		}
		
		// create nodes - maintaining a HashMap Ref -> Node
		HashMap<Reference,Node> nodes = new HashMap<Reference,Node>();
		
		//int i=0;
		for(Reference ref:refs){
			String authors = "";for(String a:ref.authors){authors=authors+a+" and ";}if(authors.length()>5)authors=authors.substring(0, authors.length()-5);
			String keywords = "";for(String k:ref.keywords){keywords=keywords+k+" ; ";}if(keywords.length()>3)keywords=keywords.substring(0, keywords.length()-3);
			//ref.id=new Integer(i).toString();
			
			Node node = graph.createNode(ref.id).setLabel(ref.title.title);
			node.getAttributeValues()
			  .addValue(attID, ref.id)
			  .addValue(attSchID, ref.scholarID)
			  .addValue(attTitle, ref.title.title)
			  .addValue(attAuthors, authors)
			  .addValue(attResume,ref.resume.resume)
			  .addValue(attKeywords,keywords)
			  .addValue(attYear, ref.year)
			  ;
			
			for(String addAttName:additionalAttributes.keySet()){
				if(ref.attributes.containsKey(addAttName)){
					node.getAttributeValues().addValue(additionalAttributes.get(addAttName),ref.attributes.get(addAttName));
				}else{//NULL default value
					node.getAttributeValues().addValue(additionalAttributes.get(addAttName),"NULL");
				}
			}
			
			nodes.put(ref, node);
			//i++;
		}
		
		// before creating links, add nodes corresponding to citing refs.
		HashMap<Reference,Node> prov = new HashMap<Reference,Node>();
		for(Reference ref:nodes.keySet()){
			for(Reference c:ref.citing){
				if(!nodes.containsKey(c)){
					Node node = graph.createNode(c.id).setLabel(c.title.title);
					node.getAttributeValues()
					  .addValue(attID, c.id)
					  .addValue(attSchID, c.scholarID)
					  .addValue(attTitle, c.title.title)
					  .addValue(attResume,c.resume.resume)
					  .addValue(attYear, c.year)
					  ;
					prov.put(c, node);
				}
			}
		}
		for(Reference r:prov.keySet()){nodes.put(r, prov.get(r));}
		
		// create citation links
		for(Reference ref:nodes.keySet()){
			Node d = nodes.get(ref);
			for(Reference c:ref.citing){
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
	 * does not work as all attributes are needed
	 * 
	 * @param graph
	 * @param ref
	 * @return
	 */
	private static Node refToNode(Graph graph,Reference ref){

		
		return null;
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
