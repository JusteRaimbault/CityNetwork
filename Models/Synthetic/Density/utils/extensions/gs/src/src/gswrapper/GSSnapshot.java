/**
 * 
 */
package gswrapper;

import org.nlogo.api.AgentSet;
import org.nlogo.api.Argument;
import org.nlogo.api.Context;
import org.nlogo.api.DefaultReporter;
import org.nlogo.api.ExtensionException;
import org.nlogo.api.LogoException;
import org.nlogo.api.Syntax;

/**
 * Takes a snapshot of current network
 * 
 * @author Raimbault Juste <br/> <a href="mailto:juste.raimbault@polytechnique.edu">juste.raimbault@polytechnique.edu</a>
 *
 */
public class GSSnapshot extends DefaultReporter {	  
	
		/**
		 * Syntaw : nodebreed,linkbreed,weight_attribute_name -> * (GSNetwork Object)
		 */
		public Syntax getSyntax() {
			return Syntax.reporterSyntax(new int[] {Syntax.StringType(),Syntax.StringType(),Syntax.StringType()}, Syntax.WildcardType());
		}
	  
		
		public Object report(Argument args[], Context context) throws ExtensionException {
			String nodebreed,linkbreed,weight ;
		    try {
		    	nodebreed = args[0].getString();linkbreed=args[1].getString(); weight=args[2].getString(); 
		    }
		    catch(LogoException e) {
		      throw new ExtensionException( e.getMessage() ) ;
		    }
		   
		    //AgentSet nodes = ((org.nlogo.agent.World)context.getAgent().world()).getBreed(nodebreed);
		    //AgentSet nodes = (AgentSet)((org.nlogo.agent.World)context.getAgent().world()).getBreeds().get(nodebreed);
		    //AgentSet links = ((org.nlogo.agent.World)context.getAgent().world()).getLinkBreed(linkbreed);		
		    AgentSet links = ((org.nlogo.agent.World)context.getAgent().world()).links();	
		    AgentSet nodes = ((org.nlogo.agent.World)context.getAgent().world()).turtles();
		    //return new GSNetwork(nodes,links,weight);
		    return new GSNetwork(nodes,links,weight,context);
	  }
	  
	}