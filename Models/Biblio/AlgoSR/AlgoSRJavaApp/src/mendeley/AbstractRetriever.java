/**
 * 
 */
package mendeley;

import java.util.HashSet;

import org.apache.commons.lang3.StringUtils;

import main.Reference;

/**
 * @author Raimbault Juste <br/> <a href="mailto:juste.raimbault@polytechnique.edu">juste.raimbault@polytechnique.edu</a>
 *
 */
public class AbstractRetriever {

	/**
	 * @param args
	 * 
	 * args[0] : title
	 * args[1] : path to config file
	 * 
	 */
	public static void main(String[] args) {
		String title = args[0];
		String confPath = args[1];
		
		// do not forget to setup api
		
		main.Main.setup(confPath);
		
		MendeleyAPI.setupAPI();
		
		// rq : replacement should not been needed as provided title will be already treated (in appscript ?)
		HashSet<Reference> refs = MendeleyAPI.catalogRequest(title.replaceAll(" ","+").replaceAll("\\{", "").replaceAll("\\}", ""), 1);
		//at most one element
		Reference r = refs.iterator().next();
		String qTitle = StringUtils.lowerCase(title.replaceAll("\\+", " ").replaceAll("\\{", "").replaceAll("\\}", ""));
		String rTitle = StringUtils.lowerCase(r.title);
		
		try{
		   if(StringUtils.getLevenshteinDistance(qTitle,rTitle)< 4){
			   System.out.println(r.resume);
		   }
		   //else do nothing, no abstract found
		}catch(Exception e){
			//empty abstract if issue

		}
		
	}

}
