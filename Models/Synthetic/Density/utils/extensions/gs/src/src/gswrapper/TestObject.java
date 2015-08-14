/**
 * 
 */
package gswrapper;


/**
 * @author Raimbault Juste <br/> <a href="mailto:juste.raimbault@polytechnique.edu">juste.raimbault@polytechnique.edu</a>
 *
 */
public class TestObject implements org.nlogo.api.ExtensionObject {

	private int value;
	
	TestObject(int i){value = i;}
	
	int getValue(){return value;}
	
	
	@Override
	public String dump(boolean readable, boolean exporting, boolean reference) {
		return new Integer(value).toString();
	}

	@Override
	public String getExtensionName() {
		return "test";
	}

	@Override
	public String getNLTypeName() {
		return "int-wrapper";
	}

	
	@Override
	public boolean recursivelyEqual(Object o) {
		return (o instanceof TestObject)&&((TestObject) o).value==value;
	}
	
}



