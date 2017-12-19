/**
 * 
 */
package gswrapper;

import java.io.ByteArrayInputStream;
import java.io.IOException;

import org.graphstream.graph.Graph;
import org.graphstream.graph.implementations.DefaultGraph;
import org.graphstream.stream.file.FileSourceDGS;
import org.nlogo.api.Agent;
import org.nlogo.api.AgentSet;
import org.nlogo.api.Context;
import org.nlogo.api.ExtensionException;
import org.nlogo.api.Link;

/**
 * 
 * Wrapper for a graphstream graph object
 * 
 * @author Raimbault Juste <br/> <a href="mailto:juste.raimbault@polytechnique.edu">juste.raimbault@polytechnique.edu</a>
 *
 */
public class GSNetwork implements org.nlogo.api.ExtensionObject {

	
	private Graph graph;
	
	/**
	 * Empty constructor
	 * 
	 * @param name
	 */
	GSNetwork(String name){graph = new DefaultGraph(name);}
	
	/**
	 * From nodes and links
	 * 
	 * @param nodes
	 * @param links
	 */
	GSNetwork(AgentSet nodes,AgentSet links,String weight,Context context) throws ExtensionException{
		int ind=-1;
		try{
		graph = new DefaultGraph("Test");
		// use basic DGS string constructor
		String spec = "DGS004\nmy 0 0\n" ;
		//insert nodes
		for(Agent node:nodes.agents()){
			spec+="an "+node.id()+" \n";
		}
		//insert edges
		for(Agent link:links.agents()){
			String e1 = new Long(((Link)link).end1().id()).toString(),e2=new Long(((Link)link).end2().id()).toString();
			//ind = ((org.nlogo.agent.World)link.world()).indexOfVariable((org.nlogo.agent.Agent)link, weight);
			ind = (((org.nlogo.agent.World)context.getAgent().world())).linksOwnIndexOf(weight);
			String w = ((Double)link.getVariable(ind)).toString();
			spec+="ae "+e1+e2+" "+e1+" "+e2+" "+weight+":1.0 \n";
		}
		FileSourceDGS source = new FileSourceDGS();
        source.addSink(graph);
        try {
			source.readAll(new ByteArrayInputStream(spec.getBytes()));
		} catch (IOException e) {
			e.printStackTrace();
		}
		}catch(Exception e){
			String err=weight+" : "+ind+"\n";for(StackTraceElement s : e.getStackTrace()){err+="\n"+s.toString();}
			throw new ExtensionException(err);
		}
	}
	
	
	
	// wrap algos here
	private void computeShortestPaths(){
		
	}
	
	
	
	
	@Override
	public String dump(boolean readable, boolean exporting, boolean reference) {
		//return graph.toString();
		return "GraphStream Graph with "+graph.getNodeCount()+" Nodes and "+graph.getEdgeCount()+" Edges";
	}

	@Override
	public String getExtensionName() {
		return "gs";
	}

	@Override
	public String getNLTypeName() {
		return "gs-network";
	}

	
	@Override
	public boolean recursivelyEqual(Object o) {
		return (o instanceof GSNetwork)&&((GSNetwork) o).graph==graph;
	}
	
}



