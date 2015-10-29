/**
 * 
 */
package main.reference;

import java.util.HashSet;

import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;

import utils.StringUtils;

/**
 * @author Raimbault Juste <br/> <a href="mailto:juste.raimbault@polytechnique.edu">juste.raimbault@polytechnique.edu</a>
 *
 */
public class CybergeoBiblioParser implements BiblioParser {

	/* (non-Javadoc)
	 * @see main.reference.BiblioParser#parse(java.lang.String)
	 */
	@Override
	public Bibliography parse(String biblio) {
		// get cited refs, from textes.`bibliographie` -> each ref as <p class="bibliographie">...</p>
		// title as <em>...</em>

		HashSet<String> res = new HashSet<String>();

		Document parsedBib = Jsoup.parse(biblio);
		for(Element bibitem:parsedBib.getElementsByClass("bibliographie")){
			//System.out.println(bibitem.html());
			
			String t = titleFromCybRef(bibitem.text());
			
			
			res.add(t);
			/*
			String t = titleFromCybRef(bibitem.html());
			if(t.length()>0){
				//System.out.println(t);
				//System.out.println(t.indexOf("<em>"));
				int emIndex = t.indexOf("<em>");
				if(emIndex==-1){
					res.add(titleFromCybRef(bibitem.text()).split(",")[0]);
				}else{
					if(emIndex < 3){
						res.add(bibitem.getElementsByTag("em").text());
					}
					else{res.add(titleFromCybRef(bibitem.text()).split(",")[0]);}
				}
			}
			*/
		}

		// dirty
		/*
		HashSet<String> r = new HashSet<String>();
		for(String s:res){r.add(StringUtils.deleteSpecialCharacters(s));}
		*/
		
		return new Bibliography(res,new HashSet<String>());
	}




	
	
	/**
	 * Specific procedure to extract references title from the html-formatted cybergeo bibliography.
	 * 
	 * Heuristic : first element after date ?
	 * 
	 * @param html
	 * @return
	 */
	public static String titleFromCybRef(String t){
		String res = "";
		try{
			int yIndex = 0;
			boolean found = false;
			for(int i=0;i<t.length()-4;i++){
				if(t.substring(i, i+4).matches("\\d\\d\\d\\d")&&!found){yIndex=i+4;found=true;};
			}
			//String[] end = t.substring(yIndex).split(",")[1].split(".");
			//String res="";
			//for(int i=1;i<end.length;i++){res+=end[i]+" ";}
			//return end[0];
			res=t.substring(yIndex+2);
		}catch(Exception e){e.printStackTrace();return "";}
		return res;
	}
	
	
	
	
	
}


