/**
 * 
 */
package sql;

import utils.GEXFWriter;
import main.corpuses.Corpus;

/**
 * @author Raimbault Juste <br/> <a href="mailto:juste.raimbault@polytechnique.edu">juste.raimbault@polytechnique.edu</a>
 *
 */
public class SQLConverter {
	
	
	/**
	 * converts a simple cyb sql base to gexf.
	 * 
	 * @param database
	 * @param outfile
	 */
	public static void sqlToGexf(String database,String outfile){
		Corpus corpus = SQLImporter.sqlImport(database, "cybergeo", "refs", "links", false);
		GEXFWriter.writeCitationNetwork(outfile, corpus.references);
	}
	
}
