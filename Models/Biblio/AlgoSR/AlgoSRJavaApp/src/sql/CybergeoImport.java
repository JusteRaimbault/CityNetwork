/**
 * 
 */
package sql;

import main.Reference;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.util.HashSet;
import java.util.Set;

import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;

import utils.GEXFWriter;
import utils.RISWriter;

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
	
	
	public static Set<Reference> importBase(){
		HashSet<Reference> res = new HashSet<Reference>();
		try{
		   ResultSet sqlrefs = sqlDB.createStatement().executeQuery(
				"SELECT `titre`,`altertitre`,`resume`,`datepubli`,`identity` "
				+ "FROM  `textes` "
				+ "WHERE  `datepubli` >=  '2003-01-01' AND  `resume` !=  '' AND  `titre` != '';");
		   while(sqlrefs.next()){
			   Reference r = Reference.construct("", rawTitle(sqlrefs.getString(1),sqlrefs.getString(2)), rawText(sqlrefs.getString(3)), sqlrefs.getString(4), "");
				
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
			   
			   // get cited refs, from textes.`bibliographie` -> each ref as <p class="bibliographie">...</p>
			   // title as <em>...</em>
			   
			   
			   
			   
			   
			   res.add(r);
			   System.out.println(r.toString());
		   }
		   
		}catch(Exception e){
			e.printStackTrace();
		}
		
		return res;
	}
	
	
	/**
	 * Get english raw text from xml multiling structure
	 * 
	 * @param xml
	 * @return
	 */
	public static String rawText(String xml){
		Document d = Jsoup.parse(xml);
		try{
		return d.getElementsByAttributeValue("lang", "en").first().text();
		}catch(Exception e){return xml;}
	}
	
	/**
	 * Get eng title from title, aletrtitle fields
	 * 
	 * @param title
	 * @param altertitle
	 * @return
	 */
	public static String rawTitle(String title,String altertitle){
		// find english title : if not in altertitle, then must be the main title
		//Document ad = Jsoup.parse(altertitle);
		Document d = Jsoup.parse(title);
		return d.text();
		/*
		try{
		    return d.getElementsByAttributeValue("lang", "en").first().text();
		}catch(Exception e){
			try{
				return ad.getElementsByAttributeValue("lang", "en").first().text();
			}catch(Exception ee){
			   return d.getElementsByTag("span").text();
			}
		}
		*/
	}
	
	
	
	/**
	 * @param args
	 */
	public static void main(String[] args) {
		setupSQL();
		//GEXFWriter.write("res/test_cyb_gexf.gexf", importBase());
		RISWriter.write("/Users/Juste/Documents/ComplexSystems/Cybergeo/Data/processed/2003_fullbase_rawTitle_withKeywords.ris", importBase());
		
		/*
		try{
			   ResultSet sqlrefs = sqlDB.createStatement().executeQuery(
					"SELECT `titre`,`resume`,`datepubli`,`altertitre` "
					+ "FROM  `textes` "
					+ "WHERE  `datepubli` >=  '2003-01-01';");
			   for(int i=0;i<10;i++){
			   sqlrefs.next();
				 System.out.println(rawText(sqlrefs.getString(1)));
				 System.out.println(rawText(sqlrefs.getString(2)));
				 System.out.println(rawText(sqlrefs.getString(3)));
				 System.out.println(rawText(sqlrefs.getString(4)));
			   }
			   
			   
			}catch(Exception e){e.printStackTrace();}
		*/
		
	}

}
