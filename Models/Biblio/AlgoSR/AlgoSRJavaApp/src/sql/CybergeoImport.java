/**
 * 
 */
package sql;

import main.Reference;

import java.io.File;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.util.HashSet;
import java.util.LinkedList;
import java.util.Set;

import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;

import utils.BasicWriter;
import utils.CSVWriter;
import utils.GEXFWriter;
import utils.RISWriter;
import utils.StringUtils;

/**
 * @author Raimbault Juste <br/> <a href="mailto:juste.raimbault@polytechnique.edu">juste.raimbault@polytechnique.edu</a>
 *
 */
public class CybergeoImport {

	
	public static Connection sqlDB;
	
	/**
	 * connects to the database
	 */
	public static void setupSQL(){
		try{
	      Class.forName("com.mysql.jdbc.Driver");
	      // !! localhost config only, ok to leak is here ¡¡ //
		  sqlDB = DriverManager.getConnection("jdbc:mysql://localhost:3306/Cybergeo","root","root");
		}catch(Exception e){
			e.printStackTrace();
		}
	}
	
	
	
	
	/**
	 * Imports the SQL base as a set of References.
	 * 
	 * @param filter : additional SQL request filter
	 *   	"	WHERE  `datepubli` >=  '2003-01-01' AND  `resume` !=  '' AND  `titre` != ''   "
	 *      append to the basic sql request.
	 *      
	 * @return Set of refs
	 */
	public static HashSet<Reference> importBase(String filter){
		
		HashSet<Reference> res = new HashSet<Reference>();
		
		try{
		   ResultSet sqlrefs = sqlDB.createStatement().executeQuery(
				"SELECT `titre`,`altertitre`,`resume`,`datepubli`,`identity`,`langue`,`bibliographie` "
				+ "FROM  `textes` "
				+ filter +";");
		   while(sqlrefs.next()){
			   
			   String biblio = sqlrefs.getString(7);
			   
			   Reference r = Reference.construct("", rawTitle(sqlrefs.getString(1),sqlrefs.getString(2),sqlrefs.getString(6))[0], rawAbstract(sqlrefs.getString(3)), sqlrefs.getString(4), "");
				
			   // get authors
			   ResultSet authorsIds = sqlDB.createStatement().executeQuery("SELECT `id2` FROM  `relations` WHERE  `id1` = " +sqlrefs.getString(5)+" AND  `nature` LIKE  'G' ORDER BY  `degree` ASC ;");
			   while(authorsIds.next()){
			      ResultSet author = sqlDB.createStatement().executeQuery("SELECT `nomfamille`,`prenom` FROM `auteurs` WHERE `idperson` = "+authorsIds.getString(1)+" ;");
			      if(author.next()){r.authors.add(author.getString(1)+" , "+author.getString(2));}
			   }
			   
			   // get keywords
			   ResultSet keywordsIds = sqlDB.createStatement().executeQuery("SELECT `id2` FROM  `relations` WHERE  `id1` = " +sqlrefs.getString(5)+" AND  `nature` LIKE  'E' ORDER BY  `degree` ASC ;");
			   while(keywordsIds.next()){
			      ResultSet keywords = sqlDB.createStatement().executeQuery("SELECT `nom` FROM `indexes` WHERE `identry` = "+keywordsIds.getString(1)+" ;");
			      while(keywords.next()){r.keywords.add(keywords.getString(1));}
			   }
			   
			   r.citedTitles = parseBibliography(biblio);
			   
			   res.add(r);
			   System.out.println(r.toString());
		   }
		   
		}catch(Exception e){
			e.printStackTrace();
		}
		
		return res;
	}
	
	
	
	/**
	 * Performs directly a csv + raw texts and abstracts export of the all base.
	 * (to not touch csv anymore)
	 * 
	 * @param outDir
	 */
	public static void directExport(String outDir){
		LinkedList<String[]> table = new LinkedList<String[]>();
		new File(outDir+"/texts").mkdir();
		try{
			// add header
			   String[] header = {"id","title_en","keywords_en","authors","date","langue","translated"};
			   table.add(header);
			
			   ResultSet sqlrefs = sqlDB.createStatement().executeQuery(
					"SELECT `identity`,`titre`,`altertitre`,`langue`,`datepubli` "
					+ "FROM  `textes`;");
			   			   
			   while(sqlrefs.next()){
				   String id = sqlrefs.getString(1);
				   String lang = sqlrefs.getString(4);
				   String[] proc_title = rawTitle(sqlrefs.getString(2),sqlrefs.getString(3),lang);
				   String title_en = proc_title[0];
				   
				   String date = sqlrefs.getString(5);
				   String translated = proc_title[1];
				   
				   String[] row = {id,title_en,"","",date,lang,translated};
				   
				   // get authors
				   String authors = "";
				   ResultSet authorsIds = sqlDB.createStatement().executeQuery("SELECT `id2` FROM  `relations` WHERE  `id1` = " +id+" AND  `nature` LIKE  'G' ORDER BY  `degree` ASC ;");
				   while(authorsIds.next()){
				      ResultSet author = sqlDB.createStatement().executeQuery("SELECT `nomfamille`,`prenom` FROM `auteurs` WHERE `idperson` = "+authorsIds.getString(1)+" ;");
				      if(author.next()){if(authors.length()>0){authors+=",";}authors+=author.getString(1)+" "+author.getString(2);}
				   }
				   row[3]=authors;
				   
				   // get keywords
				   
				   /**
				    * entrytypes : motsclesen : id=34
				    * 			   motsclesfr : id=33
				    * 			      - de : id=5712
				    * ... -> get only en keywords ?
				    */
				   String keywords = "";
				   ResultSet kwIds = sqlDB.createStatement().executeQuery("SELECT `id2` FROM  `relations` WHERE  `id1` = " +id+" AND  `nature` LIKE  'E' ORDER BY  `degree` ASC ;");
				   while(kwIds.next()){
				      ResultSet kw = sqlDB.createStatement().executeQuery("SELECT `g_name` FROM `entries` WHERE `id` = "+kwIds.getString(1)+" AND `idtype`=34 ;");
				      while(kw.next()){if(keywords.length()>0){keywords+=",";}keywords+=kw.getString(1);}
				   }
				   row[2]=keywords;
				   
				   // print text and abstract in files
				   ResultSet rawText = sqlDB.createStatement().executeQuery("SELECT `texte` FROM textes WHERE `identity` = "+id+" LIMIT 1 ; ");
				   if(rawText.next()){
					   BasicWriter.write(outDir+"/texts/"+id+"_text.txt", rawText(rawText.getString(1)));
				   }
				   
				   ResultSet res = sqlDB.createStatement().executeQuery("SELECT `resume` FROM textes WHERE `identity` = "+id+" LIMIT 1 ; ");
				   if(res.next()){
					   LinkedList<String> t = new LinkedList<String>();
					   t.add(rawAbstract(res.getString(1)));
					   BasicWriter.write(outDir+"/texts/"+id+"_abstract.txt", t);
				   }
				   
				   System.out.println(title_en);
				   
				   table.add(row);
				   
			   }
			   
			   // export to csv file
			   String[][] csv = new String[table.size()][table.get(0).length];
			   for(int i=0;i<csv.length;i++){csv[i]=table.get(i);}
			   
			   CSVWriter.write(outDir+"cybergeo.csv", csv, "\t");
			   
			}catch(Exception e){
				e.printStackTrace();
			}
			
		
	}
	
	
	
	/**
	 * Extract biblio titles
	 * 
	 * @param biblio
	 * @return
	 */
	public static HashSet<String> parseBibliography(String biblio){
		// get cited refs, from textes.`bibliographie` -> each ref as <p class="bibliographie">...</p>
		// title as <em>...</em>
		
		HashSet<String> res = new HashSet<String>();
		
		Document parsedBib = Jsoup.parse(biblio);
		for(Element bibitem:parsedBib.getElementsByClass("bibliographie")){
			//System.out.println(bibitem.html());
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
		}
		
		// dirty
		HashSet<String> r = new HashSet<String>();
		for(String s:res){r.add(StringUtils.deleteSpecialCharacters(s));}
		
		return r;

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
		for(int i=0;i<t.length()-4;i++){
			if(t.substring(i, i+4).matches("\\d\\d\\d\\d")){yIndex=i+4;break;};
		}
		//String[] end = t.substring(yIndex).split(",")[1].split(".");
		//String res="";
		//for(int i=1;i<end.length;i++){res+=end[i]+" ";}
		//return end[0];
		res=t.substring(yIndex+2);
		}catch(Exception e){e.printStackTrace();return "";}
		return res;
	}
	
	
	
	
	/**
	 * Get english raw text from xml multiling structure
	 * 
	 * @param xml
	 * @return
	 */
	public static String rawAbstract(String xml){
		Document d = Jsoup.parse(xml);
		try{
		return d.getElementsByAttributeValue("lang", "en").first().text();
		}catch(Exception e){return xml;}
	}
	
	/**
	 * 
	 * 
	 * @param html
	 * @return
	 */
	public static LinkedList<String> rawText(String html){
		LinkedList<String> t = new LinkedList<String>();
		Document d = Jsoup.parse(html);
		try{
		  for(Element e:d.getElementsByTag("p")){t.add(e.text());}
		}catch(Exception e){t.add(html);}
		return t;
	}
	
	
	/**
	 * Get eng title from title, aletrtitle fields
	 * 
	 * @param title
	 * @param altertitle
	 * @return
	 */
	public static String[] rawTitle(String title,String altertitle,String lang){
		// find english title : if not in altertitle, then must be the main title
		Document ad = Jsoup.parse(altertitle);
		Document d = Jsoup.parse(title);
		//return d.text();
		
		String[] res = new String[2];
		
		System.out.println("--"+lang+"--");
		
		if(lang.compareTo("en")==0){
			res[1] = "1";
			try{
				res[0]= d.getElementsByAttributeValue("lang", "en").first().text();
				
			}catch(Exception e){
				try{res[0] = d.getElementsByTag("span").first().text();}catch(Exception ee){res[0]=title;}
			}
			return res;
		}
		else{

			try{
				res[0]= d.getElementsByAttributeValue("lang", "en").first().text();
				res[1] = "1";
			}catch(Exception e){
				try{
					res[0]=  ad.getElementsByAttributeValue("lang", "en").first().text();
					res[1] = "1";
				}catch(Exception ee){
					try{
						res[0] = d.getElementsByTag("span").first().text();
						res[1] = "0";
					}catch(Exception eee){
						res[0] = title;
						res[1] = "0";
					}
					
				}
			}
			return res;
		}
	}
	
	
	
	/**
	 * @param args
	 */
	public static void main(String[] args) {
		setupSQL();
		//GEXFWriter.write("res/test_cyb_gexf.gexf", importBase());
		//RISWriter.write("/Users/Juste/Documents/ComplexSystems/Cybergeo/Data/processed/2003_fullbase_rawTitle_withKeywords.ris", importBase());
		//directExport("res/raw/");
		
		importBase("WHERE  `datepubli` >=  '2003-01-01' LIMIT 10");
		
		
		
		
	}

}
