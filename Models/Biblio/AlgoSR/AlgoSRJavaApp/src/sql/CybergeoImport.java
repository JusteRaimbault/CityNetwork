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
			   Reference r = Reference.construct("", rawText(sqlrefs.getString(1)+sqlrefs.getString(2)), rawText(sqlrefs.getString(3)), sqlrefs.getString(4), "");
				
			   // get authors
			   ResultSet authorsIds = sqlDB.createStatement().executeQuery("SELECT `id2` FROM  `relations` WHERE  `id1` = " +sqlrefs.getString(5)+" AND  `nature` LIKE  'G' ORDER BY  `degree` ASC ;");
			   while(authorsIds.next()){
			      ResultSet author = sqlDB.createStatement().executeQuery("SELECT `nomfamille`,`prenom` FROM `auteurs` WHERE `idperson` = "+authorsIds.getString(1)+" ;");
			      if(author.next()){r.authors.add(author.getString(1)+" , "+author.getString(2));}
			   }
			   res.add(r);
		   }
		   
		}catch(Exception e){
			e.printStackTrace();
		}
		
		return res;
	}
	
	
	public static String rawText(String xml){
		Document d = Jsoup.parse(xml);
		try{
		return d.getElementsByAttributeValue("lang", "en").first().text();
		}catch(Exception e){return xml;}
	}
	
	
	/**
	 * @param args
	 */
	public static void main(String[] args) {
		setupSQL();
		//GEXFWriter.write("res/test_cyb_gexf.gexf", importBase());
		RISWriter.write("/Users/Juste/Documents/ComplexSystems/Cybergeo/Data/processed/2003_with_resume_fullbase.ris", importBase());
		
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
