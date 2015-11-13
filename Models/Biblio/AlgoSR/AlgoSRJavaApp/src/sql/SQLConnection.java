/**
 * 
 */
package sql;

import java.sql.Connection;
import java.sql.DriverManager;

/**
 * @author Raimbault Juste <br/> <a href="mailto:juste.raimbault@polytechnique.edu">juste.raimbault@polytechnique.edu</a>
 *
 */
public class SQLConnection {
	
	
	public static Connection sqlDB;
	
	/**
	 * connects to the database
	 */
	public static void setupSQL(String database){
		try{
	      Class.forName("com.mysql.jdbc.Driver");
	      // !! localhost config only, ok to leak is here ¡¡ //
		  sqlDB = DriverManager.getConnection("jdbc:mysql://localhost:3306/"+database,"root","root");
		}catch(Exception e){
			e.printStackTrace();
		}
	}
	
	
	
	
}
