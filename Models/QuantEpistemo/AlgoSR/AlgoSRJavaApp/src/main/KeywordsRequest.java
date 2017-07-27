/**
 * 
 */
package main;

import java.util.HashSet;

import main.reference.Reference;
import scholar.ScholarAPI;
import utils.tor.TorPoolManager;

/**
 * @author Raimbault Juste <br/> <a href="mailto:juste.raimbault@polytechnique.edu">juste.raimbault@polytechnique.edu</a>
 *
 */
public class KeywordsRequest {

	
	
	public static void main(String[] args) {
		
		try{TorPoolManager.setupTorPoolConnexion();}catch(Exception e){e.printStackTrace();}
		ScholarAPI.init();
		HashSet<Reference> refs = ScholarAPI.scholarRequest(args[0], 10, "direct");
		for(Reference ref :refs){
			System.out.println(ref.toString());
		}
		
	}
	
}
