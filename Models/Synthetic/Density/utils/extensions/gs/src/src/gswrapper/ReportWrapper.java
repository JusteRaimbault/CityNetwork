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
public class ReportWrapper extends DefaultReporter {	  
	
		public Syntax getSyntax() {
			return Syntax.reporterSyntax(new int[] {Syntax.NumberType()}, Syntax.ListType());
		}
	  
		
		public Object report(Argument args[], Context context) throws ExtensionException {
			int n ;
		    try {
		      n = args[0].getIntValue();  
		    }
		    catch(LogoException e) {
		      throw new ExtensionException( e.getMessage() ) ;
		    }
		    
		    return new TestObject(n);
		    
	  }
	  
	}