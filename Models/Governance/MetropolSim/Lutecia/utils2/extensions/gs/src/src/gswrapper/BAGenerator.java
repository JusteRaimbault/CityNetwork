/**
 * 
 */
package gswrapper;

/**
 * @author Raimbault Juste <br/> <a href="mailto:juste.raimbault@polytechnique.edu">juste.raimbault@polytechnique.edu</a>
 *
 */


import org.graphstream.algorithm.generator.BarabasiAlbertGenerator;
import org.graphstream.graph.Edge;
import org.graphstream.graph.Graph;
import org.graphstream.graph.implementations.SingleGraph;
import org.nlogo.api.*;



public class BAGenerator extends DefaultReporter {  
	
	public Syntax getSyntax() {
		return Syntax.reporterSyntax(new int[] {Syntax.NumberType()}, Syntax.ListType());
	}
  
	
	public Object report(Argument args[], Context context) throws ExtensionException {

		LogoListBuilder list = new LogoListBuilder();
	    int n ;
	    try {
	      n = args[0].getIntValue();  
	    }
	    catch(LogoException e) {
	      throw new ExtensionException( e.getMessage() ) ;
	    }
	    Graph graph = new SingleGraph("BarabasiAlbert");
	   
	    BarabasiAlbertGenerator gen = new BarabasiAlbertGenerator();
	    //gen.setMaxLinksPerStep(5);
	    //Generator gen = new WattsStrogatzGenerator(1000, 2, 0.5);

		/*gen.setParameter(Parameter.INITIAL_PEOPLE_COUNT, new Integer(1000));
		gen.setParameter(Parameter.INITIAL_POINT_OF_INTEREST_COUNT, new Integer(10));
		gen.setParameter(Parameter.DEL_PEOPLE_PROBABILITY, new Float(0.0));
		gen.setParameter(Parameter.DEL_POINT_OF_INTEREST_PROBABILITY, new Float(0.0));
		gen.setParameter(Parameter.ADD_PEOPLE_PROBABILITY, new Float(0.0));
		gen.setParameter(Parameter.ADD_POINT_OF_INTEREST_PROBABILITY, new Float(0.0));

		for (PointsOfInterestGenerator.Parameter c : PointsOfInterestGenerator.Parameter.values())
		    System.out.println(c);*/
		

		gen.addSink(graph);
		gen.begin();
		for(int i=0; i<n; i++) {
		   gen.nextEvents();
		}
		gen.end();
		//graph.display(false);
		
	    for (Edge e : graph.getEdgeSet()) {
	    	LogoListBuilder l = new LogoListBuilder();
	    	l.add(Double.parseDouble(e.getNode0().getId()));
	    	l.add(Double.parseDouble(e.getNode1().getId()));
	        list.add(l.toLogoList());
	    }
	    return list.toLogoList();
  }
  
}
