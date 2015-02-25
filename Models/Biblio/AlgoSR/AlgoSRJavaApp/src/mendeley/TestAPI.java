/**
 * 
 */
package mendeley;

import java.util.HashSet;

import main.Reference;


/**
 * @author Raimbault Juste <br/> <a href="mailto:juste.raimbault@polytechnique.edu">juste.raimbault@polytechnique.edu</a>
 *
 */
public class TestAPI {
	/**
	 * @param args
	 */
	public static void main(String[] args) {
		
		//setup
		MendeleyAPI.setupAPI();
		
		// test token request
		//System.out.println(MendeleyAPI.getAccessToken());

		HashSet<Reference> refs = MendeleyAPI.catalogRequest("transportation+network+city+growth", 100);
		
		for(Reference r:refs){
			//System.out.println(r);
		}
		
		// check if static map has the entries
		for(Reference r:Reference.references.keySet()){
			//System.out.println(r.resume);
		}
		
	}
}
