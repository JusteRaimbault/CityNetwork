/**
 * 
 */
package gswrapper;

import org.nlogo.api.Argument;
import org.nlogo.api.Context;
import org.nlogo.api.DefaultReporter;
import org.nlogo.api.ExtensionException;
import org.nlogo.api.LogoException;
import org.nlogo.api.Syntax;

/**
 * @author Raimbault Juste <br/> <a href="mailto:juste.raimbault@polytechnique.edu">juste.raimbault@polytechnique.edu</a>
 *
 */
public class Sum extends DefaultReporter {	  
	
		public Syntax getSyntax() {
			return Syntax.reporterSyntax(new int[] {Syntax.WildcardType(),Syntax.WildcardType()}, Syntax.NumberType());
		}
	  
		/**
		 * Totally not secure!
		 */
		public Object report(Argument args[], Context context) throws ExtensionException {
			int n1,n2 ;
		    try{
			n1 = ((TestObject) (args[0].get())).getValue();  
		    n2 = ((TestObject) (args[1].get())).getValue();  
		    }catch(LogoException e) {
			      throw new ExtensionException( e.getMessage() ) ;
			    }
		    
		    return new TestObject(n1+n2);
		    
	  }
	  
	}