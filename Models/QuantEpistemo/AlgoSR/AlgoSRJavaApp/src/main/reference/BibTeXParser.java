/**
 * 
 */
package main.reference;

import java.io.StringReader;
import java.util.List;
import java.util.Map;

import org.jbibtex.BibTeXDatabase;
import org.jbibtex.BibTeXEntry;
import org.jbibtex.Key;
import org.jbibtex.LaTeXObject;
import org.jbibtex.LaTeXParser;

/**
 * Biblio parser for Bibtex bibliography
 * 
 * @author Raimbault Juste <br/> <a href="mailto:juste.raimbault@polytechnique.edu">juste.raimbault@polytechnique.edu</a>
 *
 */
public class BibTeXParser implements BiblioParser {

	/* (non-Javadoc)
	 * @see main.reference.BiblioParser#parse(java.lang.String)
	 */
	@Override
	public Bibliography parse(String s) {
		return null;
	}
	
	
	/**
	 * Get a ghost ref from bibtex string.
	 * DO NOT USE for all biblio parsing
	 * 
	 * @param s
	 * @return
	 */
	public static Reference parseBibtexString(String s) throws Exception {
		//try{
			//System.out.println("Parsing :\n"+s);
			org.jbibtex.BibTeXParser bibtexParser = new org.jbibtex.BibTeXParser();
			BibTeXDatabase database = bibtexParser.parse(new StringReader(s));
			Map<Key,BibTeXEntry> entries = database.getEntries();
			BibTeXEntry entry = entries.get(entries.keySet().iterator().next());
			String t = (entry.getField(BibTeXEntry.KEY_TITLE)).toUserString();
			String y = (entry.getField(BibTeXEntry.KEY_YEAR)).toUserString();
			return new GhostReference(t,y);
		//}catch(Exception e){e.printStackTrace();return null;}
	}
	
	
	
	public static void main(String[] args){
		// test the bibtexString parser
		try{
		Reference r=parseBibtexString("@article{title={titre test},year={2016}}");
		System.out.println(r);System.out.println(r.year);
		}catch(Exception e){}
	}
	
	

}
