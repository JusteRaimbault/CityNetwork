package gswrapper;

/**
 * @author Raimbault Juste <br/> <a href="mailto:juste.raimbault@polytechnique.edu">juste.raimbault@polytechnique.edu</a>
 *
 */
import org.nlogo.api.*;



public class GarbageCollector extends DefaultCommand {
  // take one number as input, report a list
  
	
	public Syntax getSyntax() {
		return Syntax.commandSyntax();
	}
  
	
	public void perform(Argument args[], Context context) throws ExtensionException {
	    System.gc();
  }
  
}