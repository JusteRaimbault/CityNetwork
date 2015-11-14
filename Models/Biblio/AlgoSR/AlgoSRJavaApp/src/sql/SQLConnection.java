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
	
	
	private static String sqlUser;
	
	private static String sqlPassword;
	
	public static Connection sqlDB;
	
	
	
	/**
	 * Setup sql credentials
	 * 
	 * @param user
	 * @param pass
	 */
	public static void setupSQLCredentials(String user,String pass){
		sqlUser = user;sqlPassword = pass;
	}
	
	
	/**
	 * Connects to the database ; assumed on localhost, at standard port 3306.
	 */
	public static void setupSQL(String database){
		try{
	      Class.forName("com.mysql.jdbc.Driver");
	      
		  sqlDB = DriverManager.getConnection("jdbc:mysql://localhost:3306/"+database,sqlUser,sqlPassword);
		}catch(Exception e){
			e.printStackTrace();
		}
	}
	
	
	
	
}
