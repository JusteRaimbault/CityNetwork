public class setup{

/**
*  General setup
*  Creates initial configuration
public static initRegion(){

* 
* 
* 
* 
*  globals
* 
* 
*  Fractal network, still in test ?
* createFractal
* 
*  maires agents
* 
* 
*  patches
* 
* 
*  update maires depending on patches config
* 
* 
* 
* 
* 
* 
* 
* 
* updateListCoutTransportsPatches "region" false
* updateDeplacementsDomicileTravail
* updateAccessibilitePatches "region"
* 
* 
* 
}

* 
* 
* 
* 
* 
* 
* 
* 
* 
public static _initGlobals(){

* 
* 
*  setup some land use parameters
* 
* 
*  Global variables ruling "luti" parametrization : Ncsp and Nmodes
* 
* 
* 
*  Parametrize luti
* 
* 
* 
*  modal choice
* 
* 
*  static ordered list of patches
* 
* 
* 
* 
* 
* 
* 
* 
* 
* 
* 
* 
* 
*  d�but "param�tres du r�seau fractal"
*  >= 2
* 
* 
* 
* 
* 
* 
* 
* 
*  fin "param�tres du r�seau fractal"
* 
* numberOfDirections
* 
* d�but "utile pour la distribution de population initiale"
*  adapt� pour 3 CSP
* set listActBussA [[100 0 0] [0 100 0] [0 0 100] [100 100 100]]
* set listActBussb [[0.5 0.5 0.5] [0.5 0.5 0.5] [0.5 0.5 0.5] [0.5 0.5 0.5]]
* set listEmpBussA [[0 100 0] [0 0 100] [100 0 0] [100 100 100]]
* set listEmpBussb [[1 1 1] [1 1 1] [1 1 1] [1 1 1]]
* 
* 
*  adapt� pour 4 CSP
* set listActBussA [[100 0 0 0] [0 100 0 0] [0 0 100 0][0 0 0 100]]
* set listActBussb [[0.5 0.5 0.5 0.5] [0.5 0.5 0.5 0.5] [0.5 0.5 0.5 0.5][0.5 0.5 0.5 0.5]]
* set listEmpBussA [[0 100 0 0] [0 0 100 0] [0 0 0 100][100 0 0 0]]
* set listEmpBussb [[1 1 1 1][1 1 1 1] [1 1 1 1][1 1 1 1]]
* 
* 
* 
* fin "utile pour la distribution de population initiale"
* 
* 
}

* 
* 
* 
* 
* 
* 
public static useParameters(){

* 
* 
* 
* set parametreDispersion 0.5
* set parametrePolycentrisme 1
* set parametreRatDispersion 3
* set parAct 1111
* set parEmp 1234
* set parametreCoutDistance 1
* 
* 
*  by CSP and Transportation mode, typically gaz prices, public transportation prices (abonnement carte orange)
* 
* 
* 
* 
* 
* 
* 
* 
* let tempList1 []
* set tempList1 lput p1 tempList1
* set tempList1 lput p2 tempList1
* set tempList1 lput p3 tempList1
* set tempList1 lput p4 tempList1
* 
* 
* let tempList2 lput first tempList1 tempList1
* set tempList2 but-first tempList2
* let tempList3 lput first tempList2 tempList2
* set tempList3 but-first tempList3
* let tempList4 lput first tempList3 tempList3
* set tempList4 but-first tempList4
* show tempList1
* show tempList2
* show tempList3
* show tempList4
* 
* 
* 
* 
* 
* 
* 
*  Parameter parAct is a qualitative value fixing shape of Bussiere distribution for actives
*  Possible values are :
*  0 -> same distribution 1234 (per mayor) for each CSP
*  1 -> circular permutations : 1234 - 2341 - 3412 - 4123
*  2 - > other permutations: 1234 - 3412 - 4321 - 2143
* 
* 
*  Parameter parEmp is the same for employment :
* 0 -> les 4 CSP ont la m�me distribution 1234 (par maire)
* 1 -> permutations circulaires : 1234 - 2341 - 3412 - 4123
* 2 - > autre permutation: 1234 - 3412 - 4321 - 2143
* 
* 
*  si en th�orie le polycentrisme peut etre diff�rent par CSP et par type (act / emp), on n'a pour l'instant qu'un indicateur pour tous: parametrePolycentrisme
* 
* 
* 
* 
* 
* 
* 
* 
* 
* 
* 
* 
* 
* 
* 
* 
* 
* 
* 
* 
* 
* 
* 
* 
* 
* 
* 
* 
* 
* 
* 
* 
* 
* 
* 
* 
* 
* 
* 
* let intMille int (parAct / 1000)
* let intCent int (parAct / 100 - 10 LICENSE.md MetropolSim19.nlogo MetropolSim2.0.nlogo display.java display.nls fractal-network.java fractal-network.nls governement.java governement.nls indicators.java indicators.nls land-use.java land-use.nls listUtils.java listUtils.nls main.java main.nls networkUtils.java networkUtils.nls setup.java setup.nls transport.nls intMille)
* let intDix int (parAct / 10 - 100 LICENSE.md MetropolSim19.nlogo MetropolSim2.0.nlogo display.java display.nls fractal-network.java fractal-network.nls governement.java governement.nls indicators.java indicators.nls land-use.java land-use.nls listUtils.java listUtils.nls main.java main.nls networkUtils.java networkUtils.nls setup.java setup.nls transport.nls intMille - 10 LICENSE.md MetropolSim19.nlogo MetropolSim2.0.nlogo display.java display.nls fractal-network.java fractal-network.nls governement.java governement.nls indicators.java indicators.nls land-use.java land-use.nls listUtils.java listUtils.nls main.java main.nls networkUtils.java networkUtils.nls setup.java setup.nls transport.nls intCent)
* let intUn int (parAct - 1000 LICENSE.md MetropolSim19.nlogo MetropolSim2.0.nlogo display.java display.nls fractal-network.java fractal-network.nls governement.java governement.nls indicators.java indicators.nls land-use.java land-use.nls listUtils.java listUtils.nls main.java main.nls networkUtils.java networkUtils.nls setup.java setup.nls transport.nls intMille - 100 LICENSE.md MetropolSim19.nlogo MetropolSim2.0.nlogo display.java display.nls fractal-network.java fractal-network.nls governement.java governement.nls indicators.java indicators.nls land-use.java land-use.nls listUtils.java listUtils.nls main.java main.nls networkUtils.java networkUtils.nls setup.java setup.nls transport.nls intCent - 10 LICENSE.md MetropolSim19.nlogo MetropolSim2.0.nlogo display.java display.nls fractal-network.java fractal-network.nls governement.java governement.nls indicators.java indicators.nls land-use.java land-use.nls listUtils.java listUtils.nls main.java main.nls networkUtils.java networkUtils.nls setup.java setup.nls transport.nls intDix)
* 
* if intMille = 1 [set listActBussA lput tempList1 listActBussA]
* if intMille = 2 [set listActBussA lput tempList2 listActBussA]
* if intMille = 3 [set listActBussA lput tempList3 listActBussA]
* if intMille = 4 [set listActBussA lput tempList4 listActBussA]
* 
* if intCent = 1 [set listActBussA lput tempList1 listActBussA]
* if intCent = 2 [set listActBussA lput tempList2 listActBussA]
* if intCent = 3 [set listActBussA lput tempList3 listActBussA]
* if intCent = 4 [set listActBussA lput tempList4 listActBussA]
* 
* if intDix = 1 [set listActBussA lput tempList1 listActBussA]
* if intDix = 2 [set listActBussA lput tempList2 listActBussA]
* if intDix = 3 [set listActBussA lput tempList3 listActBussA]
* if intDix = 4 [set listActBussA lput tempList4 listActBussA]
* 
* if intUn = 1 [set listActBussA lput tempList1 listActBussA]
* if intUn = 2 [set listActBussA lput tempList2 listActBussA]
* if intUn = 3 [set listActBussA lput tempList3 listActBussA]
* if intUn = 4 [set listActBussA lput tempList4 listActBussA]
* 
* 
* 
* set intMille int (parEmp / 1000)
* set intCent int (parEmp / 100 - 10 LICENSE.md MetropolSim19.nlogo MetropolSim2.0.nlogo display.java display.nls fractal-network.java fractal-network.nls governement.java governement.nls indicators.java indicators.nls land-use.java land-use.nls listUtils.java listUtils.nls main.java main.nls networkUtils.java networkUtils.nls setup.java setup.nls transport.nls intMille)
* set intDix int (parEmp / 10 - 100 LICENSE.md MetropolSim19.nlogo MetropolSim2.0.nlogo display.java display.nls fractal-network.java fractal-network.nls governement.java governement.nls indicators.java indicators.nls land-use.java land-use.nls listUtils.java listUtils.nls main.java main.nls networkUtils.java networkUtils.nls setup.java setup.nls transport.nls intMille - 10 LICENSE.md MetropolSim19.nlogo MetropolSim2.0.nlogo display.java display.nls fractal-network.java fractal-network.nls governement.java governement.nls indicators.java indicators.nls land-use.java land-use.nls listUtils.java listUtils.nls main.java main.nls networkUtils.java networkUtils.nls setup.java setup.nls transport.nls intCent)
* set intUn int (parEmp - 1000 LICENSE.md MetropolSim19.nlogo MetropolSim2.0.nlogo display.java display.nls fractal-network.java fractal-network.nls governement.java governement.nls indicators.java indicators.nls land-use.java land-use.nls listUtils.java listUtils.nls main.java main.nls networkUtils.java networkUtils.nls setup.java setup.nls transport.nls intMille - 100 LICENSE.md MetropolSim19.nlogo MetropolSim2.0.nlogo display.java display.nls fractal-network.java fractal-network.nls governement.java governement.nls indicators.java indicators.nls land-use.java land-use.nls listUtils.java listUtils.nls main.java main.nls networkUtils.java networkUtils.nls setup.java setup.nls transport.nls intCent - 10 LICENSE.md MetropolSim19.nlogo MetropolSim2.0.nlogo display.java display.nls fractal-network.java fractal-network.nls governement.java governement.nls indicators.java indicators.nls land-use.java land-use.nls listUtils.java listUtils.nls main.java main.nls networkUtils.java networkUtils.nls setup.java setup.nls transport.nls intDix)
* 
* if intMille = 1 [set listEmpBussA lput tempList1 listEmpBussA]
* if intMille = 2 [set listEmpBussA lput tempList2 listEmpBussA]
* if intMille = 3 [set listEmpBussA lput tempList3 listEmpBussA]
* if intMille = 4 [set listEmpBussA lput tempList4 listEmpBussA]
* 
* if intCent = 1 [set listEmpBussA lput tempList1 listEmpBussA]
* if intCent = 2 [set listEmpBussA lput tempList2 listEmpBussA]
* if intCent = 3 [set listEmpBussA lput tempList3 listEmpBussA]
* if intCent = 4 [set listEmpBussA lput tempList4 listEmpBussA]
* 
* if intDix = 1 [set listEmpBussA lput tempList1 listEmpBussA]
* if intDix = 2 [set listEmpBussA lput tempList2 listEmpBussA]
* if intDix = 3 [set listEmpBussA lput tempList3 listEmpBussA]
* if intDix = 4 [set listEmpBussA lput tempList4 listEmpBussA]
* 
* if intUn = 1 [set listEmpBussA lput tempList1 listEmpBussA]
* if intUn = 2 [set listEmpBussA lput tempList2 listEmpBussA]
* if intUn = 3 [set listEmpBussA lput tempList3 listEmpBussA]
* if intUn = 4 [set listEmpBussA lput tempList4 listEmpBussA]
* 
* 
* 
* 
}

* 
* 
* 
* 
*/
public static parametrize-luti(){

}

public static initMaires(){

}

public static initPatches(){

}

public static initAccessibilite(){

}

}
