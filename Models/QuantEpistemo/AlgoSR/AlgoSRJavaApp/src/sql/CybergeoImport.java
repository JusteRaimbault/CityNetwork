/**
 * 
 */
package sql;

import main.Main;
import main.corpuses.Corpus;
import main.reference.Abstract;
import main.reference.CybergeoBiblioParser;
import main.reference.Reference;
import main.reference.Title;

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
import org.jsoup.select.Elements;

import utils.BasicWriter;
import utils.CSVReader;
import utils.CSVWriter;
import utils.GEXFWriter;
import utils.RISWriter;
import utils.StringUtils;

/**
 * @author Raimbault Juste <br/> <a href="mailto:juste.raimbault@polytechnique.edu">juste.raimbault@polytechnique.edu</a>
 *
 */
public class CybergeoImport {

	
	
	
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
		   ResultSet sqlrefs = SQLConnection.sqlDB.createStatement().executeQuery(
				"SELECT `titre`,`altertitre`,`resume`,`datepubli`,`identity`,`langue`,`bibliographie` "
				+ "FROM  `textes` "
				+ filter +";");
		   while(sqlrefs.next()){
			   
			   String id = sqlrefs.getString(5);
			   String biblio = sqlrefs.getString(7);
			   Title title = getTitle(sqlrefs.getString(1),sqlrefs.getString(2),sqlrefs.getString(6));
			   Reference r = Reference.construct(id,title, getAbstract(sqlrefs.getString(3)), sqlrefs.getString(4), "");
				
			   r.date= sqlrefs.getString(4);
			   r.addAttribute("langue", sqlrefs.getString(6));
			   r.addAttribute("translated",new Boolean(title.translated).toString());
			   
			   // get authors
			   ResultSet authorsIds = SQLConnection.sqlDB.createStatement().executeQuery("SELECT `id2` FROM  `relations` WHERE  `id1` = " +sqlrefs.getString(5)+" AND  `nature` LIKE  'G' ORDER BY  `degree` ASC ;");
			   while(authorsIds.next()){
			      ResultSet author = SQLConnection.sqlDB.createStatement().executeQuery("SELECT `nomfamille`,`prenom` FROM `auteurs` WHERE `idperson` = "+authorsIds.getString(1)+" ;");
			      if(author.next()){r.authors.add(author.getString(2)+" , "+author.getString(1));}
			   }
			   
			   // get keywords
			   ResultSet keywordsIds = SQLConnection.sqlDB.createStatement().executeQuery("SELECT `id2` FROM  `relations` WHERE  `id1` = " +sqlrefs.getString(5)+" AND  `nature` LIKE  'E' ORDER BY  `degree` ASC ;");
			   while(keywordsIds.next()){
			      ResultSet keywords = SQLConnection.sqlDB.createStatement().executeQuery("SELECT `nom` FROM `indexes` WHERE `identry` = "+keywordsIds.getString(1)+" ;");
			      while(keywords.next()){r.keywords.add(keywords.getString(1));}
			   }
			   
			// keywords fr
			   String keywords_fr = "";
			   ResultSet kwFRIds = SQLConnection.sqlDB.createStatement().executeQuery("SELECT `id2` FROM  `relations` WHERE  `id1` = " +id+" AND  `nature` LIKE  'E' ORDER BY  `degree` ASC ;");
			   while(kwFRIds.next()){
			      ResultSet kw = SQLConnection.sqlDB.createStatement().executeQuery("SELECT `g_name` FROM `entries` WHERE `id` = "+kwFRIds.getString(1)+" AND `idtype`=33 ;");
			      while(kw.next()){if(keywords_fr.length()>0){keywords_fr+=",";}keywords_fr+=kw.getString(1);}
			   }
			   r.addAttribute("keywords_fr", keywords_fr);
			   
			   
			   r.biblio = new CybergeoBiblioParser().parse(biblio);
			   
			   //if(r.authors.size()>0){res.add(r);}
			   //else{System.out.println(r.toString());}
			   //if(r.title.title.length()<5){System.out.println(r);}
			   
			   res.add(r);
			   
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
	public static void directExport(String outDir,boolean writeFullTexts){
		LinkedList<String[]> table = new LinkedList<String[]>();
		
		try{
			// add header
			   String[] header = {"id","Title","Title_en","keywords_en","keywords_fr","authors","date","langue","translated"};
			   table.add(header);
			
			   ResultSet sqlrefs = SQLConnection.sqlDB.createStatement().executeQuery(
					"SELECT `identity`,`titre`,`altertitre`,`langue`,`datepubli` "
					+ "FROM  `textes`;");
			   			   
			   while(sqlrefs.next()){
				   String id = sqlrefs.getString(1);
				   String lang = sqlrefs.getString(4);
				   Title proc_title = getTitle(sqlrefs.getString(2),sqlrefs.getString(3),lang);
				   String title = proc_title.title;
				   String title_en = proc_title.en_title;
				   
				   String date = sqlrefs.getString(5);
				   boolean translated = proc_title.translated;
				   
				   String[] row = {id,title,title_en,"","","",date,lang,new Boolean(translated).toString()};
				   
				   // get authors
				   String authors = "";
				   ResultSet authorsIds = SQLConnection.sqlDB.createStatement().executeQuery("SELECT `id2` FROM  `relations` WHERE  `id1` = " +id+" AND  `nature` LIKE  'G' ORDER BY  `degree` ASC ;");
				   while(authorsIds.next()){
				      ResultSet author = SQLConnection.sqlDB.createStatement().executeQuery("SELECT `nomfamille`,`prenom` FROM `auteurs` WHERE `idperson` = "+authorsIds.getString(1)+" ;");
				      if(author.next()){if(authors.length()>0){authors+=",";}authors+=author.getString(2)+" "+author.getString(1);}
				   }
				   row[5]=authors;
				   
				   // get keywords
				   
				   /**
				    * entrytypes : motsclesen : id=34
				    * 			   motsclesfr : id=33
				    * 			      - de : id=5712
				    * ... -> get only en keywords ?
				    */
				   String keywords = "";
				   ResultSet kwIds = SQLConnection.sqlDB.createStatement().executeQuery("SELECT `id2` FROM  `relations` WHERE  `id1` = " +id+" AND  `nature` LIKE  'E' ORDER BY  `degree` ASC ;");
				   while(kwIds.next()){
				      ResultSet kw = SQLConnection.sqlDB.createStatement().executeQuery("SELECT `g_name` FROM `entries` WHERE `id` = "+kwIds.getString(1)+" AND `idtype`=34 ;");
				      while(kw.next()){if(keywords.length()>0){keywords+=",";}keywords+=kw.getString(1);}
				   }
				   //if(keywords.length()==0){keywords="-";}
				   row[3]=keywords;
				   
				   // keywords fr
				   String keywords_fr = "";
				   ResultSet kwFRIds = SQLConnection.sqlDB.createStatement().executeQuery("SELECT `id2` FROM  `relations` WHERE  `id1` = " +id+" AND  `nature` LIKE  'E' ORDER BY  `degree` ASC ;");
				   while(kwFRIds.next()){
				      ResultSet kw = SQLConnection.sqlDB.createStatement().executeQuery("SELECT `g_name` FROM `entries` WHERE `id` = "+kwFRIds.getString(1)+" AND `idtype`=33 ;");
				      while(kw.next()){if(keywords_fr.length()>0){keywords_fr+=",";}keywords_fr+=kw.getString(1);}
				   }
				   //if(keywords_fr.length()==0){keywords_fr="-";}
				   row[4]=keywords_fr;
				   
				   if(writeFullTexts){
					   new File(outDir+"/texts").mkdir();
					   // print text and abstract in files
					   ResultSet rawText = SQLConnection.sqlDB.createStatement().executeQuery("SELECT `texte` FROM textes WHERE `identity` = "+id+" LIMIT 1 ; ");
					   if(rawText.next()){
						   BasicWriter.write(outDir+"/texts/"+id+"_text.txt", rawText(rawText.getString(1)));
					   }

					   ResultSet res = SQLConnection.sqlDB.createStatement().executeQuery("SELECT `resume` FROM textes WHERE `identity` = "+id+" LIMIT 1 ; ");
					   if(res.next()){
						   LinkedList<String> t = new LinkedList<String>();
						   t.add(getAbstract(res.getString(1)).resume);
						   BasicWriter.write(outDir+"/texts/"+id+"_abstract.txt", t);
					   }
				   }
				   
				   System.out.println(title);
				   
				   table.add(row);
				   
			   }
			   
			   // export to csv file
			   String[][] csv = new String[table.size()][table.get(0).length];
			   for(int i=0;i<csv.length;i++){csv[i]=table.get(i);}
			   
			   CSVWriter.write(outDir+"cybergeo_withFR.csv", csv, "\t","\"");
			   
			}catch(Exception e){
				e.printStackTrace();
			}
			
		
	}
	

	
	
	
	/**
	 * Get english raw text from xml multiling structure
	 * 
	 * @param xml
	 * @return
	 */
	public static Abstract getAbstract(String xml){
		Document d = Jsoup.parse(xml);
		try{
		return new Abstract(d.getElementsByAttributeValue("lang", "en").first().text());
		}catch(Exception e){return new Abstract(xml);}
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
	 * Get eng title from title, altertitle fields
	 * 
	 * @param title
	 * @param altertitle
	 * @return
	 */
	public static Title getTitle(String title,String altertitle,String lang){
		// find english title : if not in altertitle, then must be the main title
		Document ad = Jsoup.parse(altertitle);
		Document d = Jsoup.parse(title);
		//return d.text();
		
		String restitle="",resentitle="";


		// original language is english
		// no need to fill en_title field
		try{
			restitle = d.getElementsByAttributeValue("lang", lang).first().text();				
		}catch(Exception e){
			try{restitle = d.getElementsByTag("span").first().text();}catch(Exception ee){restitle=title;}
		}
		
		if(lang.compareTo("en")!=0){
			//other language or not filled
			try{
				resentitle = d.getElementsByAttributeValue("lang", "en").first().text();
			}catch(Exception e){
				try{
					resentitle =  ad.getElementsByAttributeValue("lang", "en").first().text();
				}catch(Exception ee){}
			}
		}
		
		//if(restitle.length()==0){restitle="";}
		//if(resentitle.length()==0){resentitle="";}
		if(restitle.length()==0&&resentitle.length()>0){restitle=resentitle;}
		
		if(restitle.replace(" ", "").length()<4){
			//System.out.println("ERROR : "+title);
			//System.out.println(d.text());
			//System.out.println();
			restitle = d.text();
			//System.out.println(restitle.replace("\"", ""));
	    }
		
		return new Title(restitle.replace("\"", ""),resentitle.replace("\"", ""),title,lang);
	}
	
	
	
	
	
	public static void consolidateDatabases(){
		SQLConnection.setupSQLCredentials("root", "root");//localhost only server - OK
		SQLConnection.setupSQL("Cybergeo");
		
		// import refs from lodel base
		HashSet<Reference> res = importBase("");
		System.out.println("INITIAL CORPUS : "+res.size());
		
		// import refs from cybnetwork base
		//Corpus cybnetwork = SQLImporter.sqlImport("cybnetwork", "cybergeo", "refs", "links", -1, false);
		Corpus cybnetwork = SQLImporter.sqlImportPrimary("cybnetwork", "cybergeo", "", -1, false);
		
		for(Reference r:cybnetwork){
			// get corresponding old
			Reference clone = Reference.construct("", r.title, new Abstract(), "", "");
			clone.scholarID=r.scholarID;
			System.out.println(clone);
		}
		
		int count=0;
		for(Reference r:res){if(r.scholarID!=null&&r.scholarID.length()>0){count++;}}
		System.out.println("WITH SCHID : "+count);
		
		// import stats id - match with title
		String[][] stats = CSVReader.read(System.getenv("CS_HOME")+"/CyberGeo/cybergeo20/Data/raw/prov_ids.csv", "\t","");
		for(int i=0;i<stats.length;i++){
			Reference r = Reference.construct("", new Title(stats[i][1]), new Abstract(), "", "");
			r.addAttribute("UID", stats[i][0]);
			System.out.println(r);
		}
		count=0;
		for(Reference r:res){if(r.attributes.containsKey("UID")){count++;}}
		System.out.println("WITH UID : "+count);
		
		
		// export to csv
		String[][] data = new String[res.size()+1][];		
		String[] header={"id","UID","SCHID","Title","Title_en","keywords_en","keywords_fr","authors","date","langue","translated","numciting","numcited"};
		data[0]=header;
		int i=1;
		for(Reference r:res){
			data[i] = refToCSVArray(r);
			i++;
		}
		
		CSVWriter.write(System.getenv("CS_HOME")+"/CyberGeo/cybergeo20/Data/raw/merged.csv", data, "\t", "\"");
		
	}
	
	
	public static void computeDegrees(){
		Main.setup();
		//SQLConnection.setupSQLCredentials(); -> credential setup done in main
		Corpus cybnetwork = SQLImporter.sqlImport("cybnetwork", "cybergeo", "refs", "links", -1, false);
		// compute res on primary refs
		LinkedList<String[]> data = new LinkedList<String[]>();
		for(Reference r:cybnetwork){
			if(r.getAttribute("primary").length()>0){
				String[] row={r.scholarID,new Integer(r.citing.size()).toString(),new Integer(r.biblio.cited.size()).toString()};
				data.add(row);
			}
		}
		
		CSVWriter.write(System.getenv("CS_HOME")+"/CyberGeo/cybergeo20/Data/raw/cit.csv", data, "\t", "\"");
		
	}
	
	
	/**
	 * Export authors with infos
	 * 
	 * @param outdirs
	 */
	public static void exportAuthors(String outDir){
		LinkedList<String[]> authors = new LinkedList<String[]>();
		String[] header = {"idauthor","nom","prenom","mail","affiliation","titre","description"};
		authors.add(header);
		try{

			ResultSet sqlauthors = SQLConnection.sqlDB.createStatement().executeQuery("SELECT `idperson`,`nomfamille`,`prenom` FROM  `auteurs`;");

			while(sqlauthors.next()){
				String id=sqlauthors.getString(1);
				String nom=sqlauthors.getString(2);
				String prenom=sqlauthors.getString(3);
				// get infos
				// SELECT `idrelation` FROM  `relations` WHERE  `id1` = " +id+" AND  `nature` LIKE  'G'
				ResultSet sqlauthorships = SQLConnection.sqlDB.createStatement().executeQuery("SELECT `idrelation` FROM  `relations` WHERE  `id2` = " +id+" AND  `nature` LIKE  'G' ORDER BY idrelation");
				LinkedList<String> mails = new LinkedList<String>();
				LinkedList<String> affiliations = new LinkedList<String>();
				LinkedList<String> titres = new LinkedList<String>();
				String description="";
				while(sqlauthorships.next()){
					String idrelation = sqlauthorships.getString(1);
					//get corresponding authors entity
					ResultSet sqlauthordetails = SQLConnection.sqlDB.createStatement().executeQuery("SELECT courriel,affiliation,fonction,description FROM entities_auteurs WHERE idrelation="+idrelation+";");
					if(sqlauthordetails.next()){
						String currentMail = sqlauthordetails.getString(1),currentAffiliation=sqlauthordetails.getString(2),currentFonction=sqlauthordetails.getString(3);
						String currentDescription=sqlauthordetails.getString(4);
						//if no mail and description not null/empty, search for a mail in description (regex matching)
						if(currentMail==null||currentMail.length()==0){
							currentMail=mailFromDescription(currentDescription);
							description=textDescription(currentDescription);
						}
						
						if(currentMail!=null&&currentMail.length()>0&&currentMail!="NULL"){mails.add(currentMail);}
						if(currentAffiliation!=null&&currentAffiliation.length()>0&&currentAffiliation!="NULL"){affiliations.add(currentAffiliation);}
						if(currentFonction!=null&&currentFonction.length()>0&&currentFonction!="NULL"){titres.add(currentFonction);}	
						
					}
				}
				String mail="",affiliation="",fonction="";
				if(mails.size()>0){mail=mails.getLast();}
				if(affiliations.size()>0){affiliation=affiliations.getLast();}
				if(titres.size()>0){fonction=titres.getLast();}
				String[] row = {id,nom,prenom,mail,affiliation,fonction,description};
				System.out.println(id+" , "+nom+" , "+prenom+" , "+mail+" , "+description+" , "+affiliation+" , "+fonction);
				authors.add(row);
			}


		}catch(Exception e){e.printStackTrace();}

		CSVWriter.write(outDir+"/authors.csv", authors, ";", "\"");
		
	}
	
	
	/**
	 * Empirical parsing
	 * 
	 * @param description
	 * @return
	 */
	private static String mailFromDescription(String description){
		if(description==null){return "";}
		if(description.length()==0){return "";}
		// parse
		try{
			Document d = Jsoup.parse(description.replace("<br />"," "));
			Elements mailto=d.getElementsByAttributeValueContaining("href", "mailto");
			if(mailto.size()>0){return mailto.first().text();}
			// else split text and search for regexes
			String[] rows = d.text().replace("\n", " ").replace(",", " ").replace(":", " ").split(" ");
			for(String r:rows){
				if(r.contains("@")){return r;}
				if(r.contains("[at]")){return r.replace("[at]", "@");}
			}
			return "";
		}catch(Exception e){e.printStackTrace();return "";}
	}
	
	private static String textDescription(String description){
		if(description==null){return "";}
		if(description.length()==0){return "";}
		// parse
		try{
			Document d = Jsoup.parse(description.replace("<br />"," "));
			return d.text();
		}catch(Exception e){e.printStackTrace();return "";}
	}
	
	
	private static String[] refToCSVArray(Reference r){
		// export info :
		// "id","UID","SCHID","Title","Title_en","keywords_en","keywords_fr","authors","date","langue","translated",numciting,numcited
	    String[] res = new String[13];
	    res[0]=r.id;res[1]=r.getAttribute("UID");res[2]=r.scholarID;res[3]=r.title.title;
	    res[4]=r.title.en_title;res[5]=r.getKeywordString();res[6]=r.getAttribute("keywords_fr");res[7]=r.getAuthorString();res[8]=r.date;
	    res[9]=r.getAttribute("langue");res[10]=r.getAttribute("translated");res[11]=new Integer(r.citing.size()).toString();res[12]=new Integer(r.biblio.cited.size()).toString();
	    
	    return res;
	}
	
	
	
	
	/**
	 * @param args
	 */
	public static void main(String[] args) {
		SQLConnection.setupSQLCredentials("root", "root");
		SQLConnection.setupSQL("Cybergeo");
		//GEXFWriter.write("res/test_cyb_gexf.gexf", importBase());
		//RISWriter.write("/Users/Juste/Documents/ComplexSystems/Cybergeo/Data/processed/2003_fullbase_rawTitle_withKeywords.ris", importBase());
		//directExport(System.getenv("CS_HOME")+"/CyberGeo/cybergeo20/Data/raw/",false);
		
		//HashSet<Reference> res = importBase("");//importBase("WHERE  `datepubli` >=  '2003-01-01' LIMIT 10");
		//System.out.println(res.size());
		
		//consolidateDatabases();
		//computeDegrees();
		
		exportAuthors(System.getenv("CS_HOME")+"/CyberGeo/cybergeo20/Data/misc");
		
		
	}

}
