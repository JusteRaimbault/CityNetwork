/**
 * 
 */
package profiling;

import org.graphstream.algorithm.APSP;
import org.graphstream.algorithm.APSP.APSPInfo;
import org.graphstream.algorithm.generator.Generator;
import org.graphstream.algorithm.generator.GridGenerator;
import org.graphstream.graph.Edge;
import org.graphstream.graph.Graph;
import org.graphstream.graph.Node;
import org.graphstream.graph.implementations.DefaultGraph;
import org.graphstream.graph.implementations.SingleGraph;

/**
 * 
 * Testing GS performances, checking realistic 
 * 
 * @author Raimbault Juste <br/> <a href="mailto:juste.raimbault@polytechnique.edu">juste.raimbault@polytechnique.edu</a>
 *
 */
public class TestGSPerfs {
    
	
	/**
	 * Test computation of pairwise shortest paths
	 * 
	 * @param worldWidth
	 */
	public static void testPairWisePaths(Graph g,String n1,String n2){
		APSP apsp = new APSP();
        apsp.init(g);
        apsp.setDirected(false);
        apsp.setWeightAttributeName("length"); // ensure that the attribute name used is "weight"

        apsp.compute(); // the method that actually computes shortest paths

        
        APSPInfo info = g.getNode(n1).getAttribute(APSPInfo.ATTRIBUTE_NAME);
        System.out.println(info.getShortestPathTo(n2));
	}
	
	public static Graph gridGraph(int size){
		Graph graph = new SingleGraph("grid");
		Generator gen = new GridGenerator(true,false);
		 
		gen.addSink(graph);
		gen.begin();
		for(int i=0; i<size; i++) {
		    gen.nextEvents();
		}
		gen.end();
		
		// add the attribute "length" to compute euclidian shortest distances
		for(Edge e:graph.getEdgeSet()){
			Double[] d0 = e.getNode0().getAttribute("xy");
			Double[] d1 = e.getNode1().getAttribute("xy");
			e.setAttribute("length", new Double(Math.sqrt(Math.pow(d0[0].doubleValue()-d1[0].doubleValue(),2)+Math.pow(d0[1].doubleValue()-d1[1].doubleValue(),2))));
		}
		
		return(graph);
	}
	
	public static void main(String[] args) {
		//System.out.println(gridGraph(15).getEdgeCount());
		Graph g = gridGraph(20);
		//for(Node n : g.getNodeSet()){System.out.println(n.getId());}
		//for(String s:g.getNode(1).getAttributeKeySet()){System.out.println(s);}
		//System.out.println(g.getNode(1).getAttribute("xy").toString());
		//for(Double d : (Double[]) g.getEdge(10).getNode0().getAttribute("xy")){System.out.println(d.toString());}
		//for(Edge e:g.getEdgeSet()){System.out.println(e.getAttribute("length").toString());}
		
		
		// test shortest paths
		long t = System.currentTimeMillis();
		
		testPairWisePaths(g,"0_0","13_15");
		System.out.println("Ellapsed time : "+(System.currentTimeMillis()-t)+" ms");
		
		
		
	}
	
}
