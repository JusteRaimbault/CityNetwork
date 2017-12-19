/**
 * 
 */
package gswrapper;

import org.nlogo.api.*;

public class ClassManager extends DefaultClassManager {
	
	
    public void load(PrimitiveManager primitiveManager) {
    	//primitiveManager.addPrimitive("ba-generator", new BAGenerator());
    	primitiveManager.addPrimitive("snapshot", new GSSnapshot());
	}
  
  
}
