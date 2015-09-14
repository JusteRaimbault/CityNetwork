/**
 * 
 */
package main;

import utils.tor.TorPool;

/**
 * @author Raimbault Juste <br/> <a href="mailto:juste.raimbault@polytechnique.edu">juste.raimbault@polytechnique.edu</a>
 *
 */
public class CitationNetworkRetriever {

	/**
	 * @param args
	 * 
	 * Usage : [torpid1,torpid2] , refFile, outFile, depth
	 * 
	 */
	public static void main(String[] args) {
		
		String refFile="",outFile="";
		int depth = 0;
		
		if(args.length==5){
           TorPool.forceStopPID(Integer.parseInt(args[0]), Integer.parseInt(args[1]));
           refFile = args[2];outFile = args[3];
           depth = Integer.parseInt(args[4]);
		}
		if(args.length==3){
			refFile = args[0];outFile = args[1];
	        depth = Integer.parseInt(args[2]);
		}
		
		CitationNetwork.buildCitationNetworkFromRefFile(refFile,outFile,depth);
		
		
	}

}
