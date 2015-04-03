/**
 * 
 */
package main;

import java.io.BufferedReader;
import java.io.InputStreamReader;

/**
 * @author Raimbault Juste <br/> <a href="mailto:juste.raimbault@polytechnique.edu">juste.raimbault@polytechnique.edu</a>
 *
 */
public class Test {

	
	public static void test() throws Exception{
		Main.processDirectory("data/", "data/src/");
		System.out.println("\n\n----------- main.java-------------\n");
		Process p = Runtime.getRuntime().exec("cat data/main.java;cd data/src; doxygen config");
		BufferedReader reader = new BufferedReader(new InputStreamReader(p.getInputStream()));
        String line=reader.readLine();
        while (line != null) {    
            System.out.println(line);
            line = reader.readLine();
        }
	}
	
	/**
	 * @param args
	 */
	public static void main(String[] args) throws Exception {
		test();
	}

}
