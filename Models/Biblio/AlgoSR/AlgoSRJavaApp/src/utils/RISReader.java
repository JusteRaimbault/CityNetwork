/**
 * 
 */
package utils;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.util.HashSet;
import java.util.LinkedList;

import main.Reference;

/**
 * @author Raimbault Juste <br/> <a href="mailto:juste.raimbault@polytechnique.edu">juste.raimbault@polytechnique.edu</a>
 *
 */
public class RISReader {

	
	/**
	 * Constructs a set of refs from RIS file.
	 * 
	 * Used to reuse bib files.
	 * 
	 * @param filePath
	 * @return
	 */
	public static HashSet<Reference> read(String filePath){
		HashSet<Reference> refs = new HashSet<Reference>();
		try{
		   BufferedReader reader = new BufferedReader(new FileReader(new File(filePath)));
		   String currentTitle="",currentAbstract="",currentYear="";
		   String currentLine = reader.readLine();
		   while(currentLine!= null){
			   // check new ref criterium : TY -
			   if(currentLine.startsWith("TY")&&currentTitle.length()>0){
				   refs.add(Reference.construct("", currentTitle, currentAbstract, currentYear, ""));}
			   if(currentLine.startsWith("AB")){currentAbstract=currentLine.split("AB  - ")[1];}
			   if(currentLine.startsWith("T1")){currentTitle=currentLine.split("T1  - ")[1];}
			   if(currentLine.startsWith("PY")){currentYear=currentLine.split("PY  - ")[1];}
			   currentLine = reader.readLine();
		   }
		   reader.close();
		   
		}catch(Exception e){e.printStackTrace();return null;}
		return refs;
	}
	
	
	
	public static void main(String[] args){
		read("/Users/Juste/Documents/ComplexSystems/CityNetwork/Models/Biblio/AlgoSR/junk/refs_transportation+network+urban+growth_14.ris");
		for(Reference r:Reference.references.keySet()){System.out.println(r);}
	}
	
	
	
	
}
