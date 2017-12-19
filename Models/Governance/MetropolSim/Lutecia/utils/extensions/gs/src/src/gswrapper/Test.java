/**
 * 
 */
package gswrapper;

import java.io.ByteArrayInputStream;
import java.io.IOException;

import org.graphstream.graph.Edge;
import org.graphstream.graph.Graph;
import org.graphstream.graph.implementations.DefaultGraph;
import org.graphstream.stream.file.FileSourceDGS;

/**
 * @author Raimbault Juste <br/> <a href="mailto:juste.raimbault@polytechnique.edu">juste.raimbault@polytechnique.edu</a>
 *
 */
public class Test {

	
	static void testInputStream(){
		String spec = "DGS004\n" 
                + "my 0 0\n" 
                + "an A \n" 
                + "an B \n"
                + "ae AB A B weight:0.001 \n";
		Graph graph = new DefaultGraph("Test");
		FileSourceDGS source = new FileSourceDGS();
        source.addSink(graph);
        try {
			source.readAll(new ByteArrayInputStream(spec.getBytes()));
		} catch (IOException e) {
			e.printStackTrace();
		}
        for(Edge e : graph.getEachEdge()){System.out.println(e);System.out.println(e.getAttribute("weight").toString());}
	}
	
	/**
	 * @param args
	 */
	public static void main(String[] args) {
		//input stream
		testInputStream();
		
		
	}

}
