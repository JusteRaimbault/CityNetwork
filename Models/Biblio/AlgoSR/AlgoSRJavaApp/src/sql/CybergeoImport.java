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
				"SELECT `altertitre`,`resume`,`datepubli` "
				+ "FROM  `textes` "
				+ "WHERE  `datepubli` >=  '2003-01-01';");
		   while(sqlrefs.next()){
			   res.add(Reference.construct("", rawText(sqlrefs.getString(1)), rawText(sqlrefs.getString(2)), sqlrefs.getString(3), ""));
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
		RISWriter.write("res/test_cyb.ris", importBase());
		
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
