/**
 * 
 */
package utils.tor;

/**
 * @author Raimbault Juste <br/> <a href="mailto:juste.raimbault@polytechnique.edu">juste.raimbault@polytechnique.edu</a>
 *
 */
public class TestTorPoolManager {

	
	/**
	 * Test for connexion from multiple threads -> to be launched //.
	 */
	public static void testSimultaneousConnexions() throws Exception{
		TorPoolManager.setupTorPoolConnexion();
		while(true){
			long t=(long)(Math.random()*20000.0);
			System.out.println("sleeping "+t+"s...");
			Thread.sleep(t);
			TorPoolManager.switchPort();
		}
	}
	
	
	
	/**
	 * @param args
	 */
	public static void main(String[] args) throws Exception{
		testSimultaneousConnexions();
	}

}
