/**
 * 
 */
package main.corpuses;

import java.util.HashMap;
import java.util.HashSet;

import main.Reference;

/**
 * @author Raimbault Juste <br/> <a href="mailto:juste.raimbault@polytechnique.edu">juste.raimbault@polytechnique.edu</a>
 *
 */
public interface CorpusFactory {
	
	/**
	 * Setup the factory with the given options (proper to each factory).
	 * 
	 * @param options
	 */
	public void setup(HashMap<String,String> options);
	
	/**
	 * Constructs the corpus and retrieves it.
	 * 
	 * @return
	 */
	public Corpus getCorpus();
	
}
