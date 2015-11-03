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

		HashSet<Reference> res = new HashSet<Reference>();

		Document parsedBib = Jsoup.parse(biblio);
		for(Element bibitem:parsedBib.getElementsByClass("bibliographie")){
			//System.out.println(bibitem.html());
			
			//String t = titleFromCybRef(bibitem.text());
			String r = "";
			String t = titleFromCybRef(bibitem.html());
			String y = yearFromCybRef(bibitem.html());
			if(t.length()>0){
				//System.out.println(t);
				//System.out.println(t.indexOf("<em>"));
				int emIndex = t.indexOf("<em>");
				if(emIndex==-1){
					r = titleFromCybRef(bibitem.text()).split(",")[0];
				}else{
					if(emIndex < 3){
						r=bibitem.getElementsByTag("em").text();
					}
					else{r=titleFromCybRef(bibitem.text()).split(",")[0];}
				}
			}
			
			// supp string cleaning (ex quotes)
			r=cleanString(r);
			res.add(new GhostReference(r,y));
			
			
		}

		// dirty
		/*
		HashSet<String> r = new HashSet<String>();
		for(String s:res){r.add(StringUtils.deleteSpecialCharacters(s));}
		*/
		
		// bibliography of ghost refs
		return new Bibliography(res);
	}


	private static String cleanString(String s){
		String res=s.replaceAll("\"", "").replaceAll("“", "").replaceAll("”", "").replaceAll("«", "").replaceAll("»", "");
		while(res.startsWith(" ")){res=res.substring(1);}
		while(res.endsWith(" ")){res=res.substring(0, res.length()-1);}
		
		return res;
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
			
			// TODO : PB : some biblio have year AFTER title -> count split[,] elements before year elem ?
			// ~ approximate heuristic.
			//  !! do not use yIndex + 2 -> split with , also ?
			//    quotes -> ?
			
			
			//String[] end = t.substring(yIndex).split(",")[1].split(".");
			//String res="";
			//for(int i=1;i<end.length;i++){res+=end[i]+" ";}
			//return end[0];
			res=t.substring(yIndex+1);
		}catch(Exception e){e.printStackTrace();return "";}
		return res;
	}
	
	private static String yearFromCybRef(String t){
		String res = "";
		try{
			int yIndex = 0;
			boolean found = false;
			for(int i=0;i<t.length()-4;i++){
				if(t.substring(i, i+4).matches("\\d\\d\\d\\d")&&!found){yIndex=i;found=true;};
			}
			res=t.substring(yIndex,yIndex+4);
		}catch(Exception e){e.printStackTrace();return "";}
		return res;
	}
	
	
	
	
}


