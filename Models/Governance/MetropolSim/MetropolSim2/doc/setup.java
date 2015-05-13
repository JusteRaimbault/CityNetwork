public class setup{

/**
*  General setup
* 
*  Creates initial configuration.
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
* 
* 
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
* 
*  >= 2
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
*/
/**
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
*  0 -> same distribution 1234 (per mayor) for each CSP
*  1 -> circular permutations : 1234 - 2341 - 3412 - 4123
*  2 - > other permutations: 1234 - 3412 - 4321 - 2143
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
* let intCent int (parAct / 100 - 10 LICENSE.md MetropolSim19.nlogo MetropolSim2.0.nlogo display.java display.nls doc fractal-network.java fractal-network.nls governement.java governement.nls indicators.java indicators.nls infrastructure.java infrastructure.nls land-use.java land-use.nls listUtils.java listUtils.nls main.java main.nls networkUtils.java networkUtils.nls setup.java setup.nls transport.nls intMille)
* let intDix int (parAct / 10 - 100 LICENSE.md MetropolSim19.nlogo MetropolSim2.0.nlogo display.java display.nls doc fractal-network.java fractal-network.nls governement.java governement.nls indicators.java indicators.nls infrastructure.java infrastructure.nls land-use.java land-use.nls listUtils.java listUtils.nls main.java main.nls networkUtils.java networkUtils.nls setup.java setup.nls transport.nls intMille - 10 LICENSE.md MetropolSim19.nlogo MetropolSim2.0.nlogo display.java display.nls doc fractal-network.java fractal-network.nls governement.java governement.nls indicators.java indicators.nls infrastructure.java infrastructure.nls land-use.java land-use.nls listUtils.java listUtils.nls main.java main.nls networkUtils.java networkUtils.nls setup.java setup.nls transport.nls intCent)
* let intUn int (parAct - 1000 LICENSE.md MetropolSim19.nlogo MetropolSim2.0.nlogo display.java display.nls doc fractal-network.java fractal-network.nls governement.java governement.nls indicators.java indicators.nls infrastructure.java infrastructure.nls land-use.java land-use.nls listUtils.java listUtils.nls main.java main.nls networkUtils.java networkUtils.nls setup.java setup.nls transport.nls intMille - 100 LICENSE.md MetropolSim19.nlogo MetropolSim2.0.nlogo display.java display.nls doc fractal-network.java fractal-network.nls governement.java governement.nls indicators.java indicators.nls infrastructure.java infrastructure.nls land-use.java land-use.nls listUtils.java listUtils.nls main.java main.nls networkUtils.java networkUtils.nls setup.java setup.nls transport.nls intCent - 10 LICENSE.md MetropolSim19.nlogo MetropolSim2.0.nlogo display.java display.nls doc fractal-network.java fractal-network.nls governement.java governement.nls indicators.java indicators.nls infrastructure.java infrastructure.nls land-use.java land-use.nls listUtils.java listUtils.nls main.java main.nls networkUtils.java networkUtils.nls setup.java setup.nls transport.nls intDix)
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
* set intCent int (parEmp / 100 - 10 LICENSE.md MetropolSim19.nlogo MetropolSim2.0.nlogo display.java display.nls doc fractal-network.java fractal-network.nls governement.java governement.nls indicators.java indicators.nls infrastructure.java infrastructure.nls land-use.java land-use.nls listUtils.java listUtils.nls main.java main.nls networkUtils.java networkUtils.nls setup.java setup.nls transport.nls intMille)
* set intDix int (parEmp / 10 - 100 LICENSE.md MetropolSim19.nlogo MetropolSim2.0.nlogo display.java display.nls doc fractal-network.java fractal-network.nls governement.java governement.nls indicators.java indicators.nls infrastructure.java infrastructure.nls land-use.java land-use.nls listUtils.java listUtils.nls main.java main.nls networkUtils.java networkUtils.nls setup.java setup.nls transport.nls intMille - 10 LICENSE.md MetropolSim19.nlogo MetropolSim2.0.nlogo display.java display.nls doc fractal-network.java fractal-network.nls governement.java governement.nls indicators.java indicators.nls infrastructure.java infrastructure.nls land-use.java land-use.nls listUtils.java listUtils.nls main.java main.nls networkUtils.java networkUtils.nls setup.java setup.nls transport.nls intCent)
* set intUn int (parEmp - 1000 LICENSE.md MetropolSim19.nlogo MetropolSim2.0.nlogo display.java display.nls doc fractal-network.java fractal-network.nls governement.java governement.nls indicators.java indicators.nls infrastructure.java infrastructure.nls land-use.java land-use.nls listUtils.java listUtils.nls main.java main.nls networkUtils.java networkUtils.nls setup.java setup.nls transport.nls intMille - 100 LICENSE.md MetropolSim19.nlogo MetropolSim2.0.nlogo display.java display.nls doc fractal-network.java fractal-network.nls governement.java governement.nls indicators.java indicators.nls infrastructure.java infrastructure.nls land-use.java land-use.nls listUtils.java listUtils.nls main.java main.nls networkUtils.java networkUtils.nls setup.java setup.nls transport.nls intCent - 10 LICENSE.md MetropolSim19.nlogo MetropolSim2.0.nlogo display.java display.nls doc fractal-network.java fractal-network.nls governement.java governement.nls indicators.java indicators.nls infrastructure.java infrastructure.nls land-use.java land-use.nls listUtils.java listUtils.nls main.java main.nls networkUtils.java networkUtils.nls setup.java setup.nls transport.nls intDix)
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
/**
public static parametrize-luti(){

* 
* 
* 
*  liste valable pour 3 CSP et 2 modes (pour transport land use ca sera bien)
* set listNbrConnecteurs (list (1) (1))
* set listSpeed (list (1) (1.5))
* set listNactifs (list (200) (600) (200))
* set listCarOwnership (list (1) (1) (1))
* set listSalaires (list (1) (1) (1))
* set listcoeffAccessibiliteFormeUrbaineActifs (list (0.2) (0.5) (0.7))
* set listcoeffAccessibiliteFormeUrbaineEmplois (list (0.7) (0.5) (0.2))
* set listcoeffUtilitesActifs (list (100) (80) (40))
* set listcoeffUtilitesEmplois (list (20) (80) (100))
* 
* 
* set matActifsActifs (list ((list (1)(0)(0)))((list (-1)(1)(-1)))((list (-2)(-2)(0.5))))
* set matActifsEmplois (list ((list (1)(0)(0)))((list (0)(1)(0)))((list (0)(0)(0.5))))
* set matEmploisActifs (list ((list (1)(-1)(-1)))((list (1)(1)(1)))((list (0)(0)(1))))
* set matEmploisEmplois (list ((list (1)(-1)(-1)))((list (-1)(1)(0)))((list (-2)(0)(1))))
* 
* set listvaleursTemps
* set listcoutDistance
* 
* (list ((list (0)(0)(0)))((list (0)(0)(0)))((list (0)(0)(0))))
* (list ((list (1)(0)(0)))((list (0)(1)(0)))((list (0)(0)(1))))
* 
* 
* 
* 
* 
*  liste valable pour 4 CSP et un mode (pour test th�orique de C4)
*  par mode
*  par mode
*  par CSP
*  par CSP
*  par CSP
*  par CSP
*  par CSP
*  par CSP
*  par CSP
* set listcoeffUtilitesActifs (list (50) (50) (50))
* set listcoeffUtilitesEmplois (list (50) (50) (50))
* 
* 
* 
* 
* 
* 
*  par csp
* set listcoutDistance (list (list (1) (1) (1) (1)))
* 
* 
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
*/
/**
public static initMaires(){

* 
* 
* 
* 
* 
* 
* 
* setxy (3 LICENSE.md MetropolSim19.nlogo MetropolSim2.0.nlogo display.java display.nls doc fractal-network.java fractal-network.nls governement.java governement.nls indicators.java indicators.nls infrastructure.java infrastructure.nls land-use.java land-use.nls listUtils.java listUtils.nls main.java main.nls networkUtils.java networkUtils.nls setup.java setup.nls transport.nls who + 1) 0
* setxy 0 0
* set xcor max-pxcor / 2
* set ycor max-pycor / 2
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
* show j
* 
* 
*  area of power for mayors is determined by Thiessen polygons of their distributions (at least for now)
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
*  we create now rents (?) and active/employments given an exogeneous Bussiere
* 
* 
* set listAnbrR lput (item i [listA-AbussiereInit] of mairePatch LICENSE.md MetropolSim19.nlogo MetropolSim2.0.nlogo display.java display.nls doc fractal-network.java fractal-network.nls governement.java governement.nls indicators.java indicators.nls infrastructure.java infrastructure.nls land-use.java land-use.nls listUtils.java listUtils.nls main.java main.nls networkUtils.java networkUtils.nls setup.java setup.nls transport.nls exp(- item i [listA-bbussiereInit] of mairePatch LICENSE.md MetropolSim19.nlogo MetropolSim2.0.nlogo display.java display.nls doc fractal-network.java fractal-network.nls governement.java governement.nls indicators.java indicators.nls infrastructure.java infrastructure.nls land-use.java land-use.nls listUtils.java listUtils.nls main.java main.nls networkUtils.java networkUtils.nls setup.java setup.nls transport.nls distance mairePatch)) listAnbrR
* 
* 
* 
* 
* for each csp
* 
* 
* 
* 
* 
* distance item j listMaires))
* distance item j listMaires))
* 
* 
* 
* 
*  initial number of actives for each CSP is then tempA for this patch
* 
* 
* 
* 
* 
* 
* 
* 
*  this line is used for visualizations, can be commented/deleted
*  @TODO : General viz factorization ?
* 
* ask patches [set pcolor (item 0 listAnbrR)]
* 
}

* 
* 
* 
* 
* 
* 
* 
*/
/**
public static initPatches(){

* 
* 
* 
* 
* 
*  sprout-nodes 1 [
*  set hidden? true
*  set patchNode myself
*  set typeNode -1
*  ]
*  set i 0
*  while [i < Ncsp] [
* 
* 
* 
* 
* 
* 
* set listEnbr []
* 
* 
* 
*  set i i + 1
*  ]
* 
* 
* 
* 
* 
* 
* ifelse (distance (mairePatch) = 0) [
*  ifelse (has-maire? = 1) [
*  set listEnbr lput (sum [item i listAnbrR] of patches with [mairePatch = [mairePatch] of myself]) listEnbr
*  ][
*  set listEnbr lput (0) listEnbr
*  ]
*  set listEnbr lput ((sum [item i listAnbrR] of patches with [mairePatch = [mairePatch] of myself]) / count patches with [mairePatch = [mairePatch] of myself]) listEnbr
* set listEnbr lput random 100 listEnbr
* 
*  number of actives "M" is zero fir each CSP and patch
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
*  for each csp
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
}

* 
* 
* 
* 
* 
public static initAccessibilite(){

* 
* 
* 
* 
*  set listNavettesModes [[[]]]
*  set listModesShare [[[]]]
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
*  set listNavettesModes replace-item m listNavettesModes lput [] listNavettesModes
* set listModesShare replace-item m listModesShare lput [] listModesShare
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
*  let m 0
*  while [m < Nmodes] [
* 
*  set temp temp + exp(- coeffChoixModal LICENSE.md MetropolSim19.nlogo MetropolSim2.0.nlogo display.java display.nls doc fractal-network.java fractal-network.nls governement.java governement.nls indicators.java indicators.nls infrastructure.java infrastructure.nls land-use.java land-use.nls listUtils.java listUtils.nls main.java main.nls networkUtils.java networkUtils.nls setup.java setup.nls transport.nls item j item m listCoutTransport)
*  set m m + 1
*  ]
* 
* 
* 
* 
* 
*  set temp1 exp(- coeffChoixModal LICENSE.md MetropolSim19.nlogo MetropolSim2.0.nlogo display.java display.nls doc fractal-network.java fractal-network.nls governement.java governement.nls indicators.java indicators.nls infrastructure.java infrastructure.nls land-use.java land-use.nls listUtils.java listUtils.nls main.java main.nls networkUtils.java networkUtils.nls setup.java setup.nls transport.nls [item j item m listCoutTransport] of item i listPatchesRegion)
* 
* let tempShare (item c listCarOwnership LICENSE.md MetropolSim19.nlogo MetropolSim2.0.nlogo display.java display.nls doc fractal-network.java fractal-network.nls governement.java governement.nls indicators.java indicators.nls infrastructure.java infrastructure.nls land-use.java land-use.nls listUtils.java listUtils.nls main.java main.nls networkUtils.java networkUtils.nls setup.java setup.nls transport.nls (temp1 / temp))
* if m = 0 [set tempShare (tempShare + (1 - item c listCarOwnership)) ]
* 
* 
* 
* 
* set tempShareL lput tempShare tempShareL
* 
* 
* 
*  set listModesShare replace-item m listModesShare lput (item c carownership LICENSE.md MetropolSim19.nlogo MetropolSim2.0.nlogo display.java display.nls doc fractal-network.java fractal-network.nls governement.java governement.nls indicators.java indicators.nls infrastructure.java infrastructure.nls land-use.java land-use.nls listUtils.java listUtils.nls main.java main.nls networkUtils.java networkUtils.nls setup.java setup.nls transport.nls (temp1 / temp)) item m listModesShare
* 
* 
* 
* 
* let tempNavettes item c listNavettesPatches
* 
* 
* 
* 
* set tempNavettes lput ((item c listNavettesPatches) LICENSE.md MetropolSim19.nlogo MetropolSim2.0.nlogo display.java display.nls doc fractal-network.java fractal-network.nls governement.java governement.nls indicators.java indicators.nls infrastructure.java infrastructure.nls land-use.java land-use.nls listUtils.java listUtils.nls main.java main.nls networkUtils.java networkUtils.nls setup.java setup.nls transport.nls (tempShare)) tempNavettes
* 
* set tempNavettes multiplyList tempNavettes (tempShare)
* let temp3 item m listNavettesModes
* set temp3 replace-item c temp3 tempNavettes
* 
*  set listNavettesModes replace-item m listNavettesModes lput ((item j listNavettesPatches) LICENSE.md MetropolSim19.nlogo MetropolSim2.0.nlogo display.java display.nls doc fractal-network.java fractal-network.nls governement.java governement.nls indicators.java indicators.nls infrastructure.java infrastructure.nls land-use.java land-use.nls listUtils.java listUtils.nls main.java main.nls networkUtils.java networkUtils.nls setup.java setup.nls transport.nls item m listModesShare) item m listNavettesModes
* 
* 
* set listNavettesModes replace-item m listNavettesModes temp3
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
* 
* 
}
