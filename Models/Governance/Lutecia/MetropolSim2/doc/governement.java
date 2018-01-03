public class governement{

/**
* 
* 
*/
/**
* 
* 
* 
* 
* 
* 
* 
*/
/**
public static gouvernement(){

* 
* 
* 
* 
* 
* 
*  find mayor building infrastructure and creates it
* 
* 
*  Q : is it good to tick inside ?
* 
* 
* 
*  plus tard, � tick correspondra une hausse progressive du car ownership, avec pour effet de rendre rentables les projets routiers, donc il se font, donc ca transforme la m�tropole...
* 
* 
}

* 
* 
* 
* 
public static updateMaires(){

* 
* 
*  visualization
* 
* 
*  budget = number of employments
*  a affiner une fois que la ville, y'a des gens dedans!
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
*/
/**
public static chooseMaire(){

* 
* 
* 
* 
* 
* 
* 
* 
* 
*  init random drawing vars money- and money+
* 
* 
* 
* 
* 
* 
* 
* let tempM one-of maires
* 
* 
* 
* 
* updateListCoutTransportsPatches tempM
* updateAccessibilitePatches tempM
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
*/
/**
public static updateListCoutTransportsPatches(){

* 
* 
* 
* ifelse is-maire? tempmaire [
*  set listP [listPatchesMaire] of tempmaire
* ][
* 
* ]
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
*  set listChemins [[]]
*  set listCoutTransport [[]]
*  set listCoutTransportEffectif [[[]]]
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
* set listCoutTransportTemp lput [] listCoutTransportTemp
* set listCoutTransportEffectifTemp lput [] listCoutTransportEffectifTemp
* set listCheminsTemp lput [] listCheminsTemp
* 
* 
* set listCoutTransportEffectif lput [[]] listCoutTransportEffectif
* 
* 
* 
* 
* 
* 
* 
*  while [m < Nmodes] [
*  set listNavettesModes lput [[]] listNavettesModes
*  set listModesShare lput [[]] listModesShare
*  let c 0
*  while [c < Ncsp] [
*  set listNavettesModes replace-item m listNavettesModes lput [] item m listNavettesModes
*  set listModesShare replace-item m listModesShare lput [] item m listModesShare
* 
*  set c c + 1
*  ]
*  set m m + 1
*  ]
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
* MODIFENCOURS
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
* MODIFENCOURS
* set m 0
* while [m < nModes] [
* 
* 
*  updateListCoutTransportsPatchesMode tempmaire temp? listP m
*  set m m + 1
* ]
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
*/
/**
public static updateListCoutTransportsPatchesMode(){

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
*  for each patch
* 
* 
*  ask item i listP [
*  ifelse is-maire? tempmaire [
* 
*  set listCoutTransportTemp []
*  set listCoutTransportEffectifTemp []
*  if not temp? [ set listCheminsTemp [] ]
*  ][
*  set listCoutTransport []
*  set listCoutTransportEffectif []
*  if not temp? [ set listChemins [] ]
*  ]
*  ]
* 
* 
* 
* 
*  other patches
* 
* 
* 
* 
*  ask i-th patch
* 
* 
* 
*/
/**
* 
* 
* 
* 
* 
* 
* 
*  ifelse is-maire? tempmaire [
* 
*  set listCoutTransportTemp replace-item mode listCoutTransportTemp lput temp item mode listCoutTransportTemp
* 
* 
*  if listNavettesPatches != 0 [
* 
* 
*  set listCoutTransportEffectifTemp replace-item mode listCoutTransportEffectifTemp lput (temp LICENSE.md MetropolSim19.nlogo MetropolSim2.0.nlogo display.java display.nls doc fractal-network.java fractal-network.nls governement.java governement.nls indicators.nls infrastructure.nls land-use.nls listUtils.nls main.nls networkUtils.nls setup.nls transport.nls item j listNavettesPatches) item mode listCoutTransportEffectifTemp
* 
*  ]
*  if not temp? [
* 
*  set listCheminsTemp replace-item mode listCheminsTemp lput tempL item mode listCheminsTemp
*  ]
*  ]
*  [
* MODIFENCOURSset listCoutTransport replace-item mode listCoutTransport lput temp item mode listCoutTransport
* 
* 
* 
* 
* 
* MODIFENCOURSset c 0
* MODIFENCOURSwhile [c < nCsp] [
* 
* 
* 
* MODIFENCOURSset c c + 1
* ]
* 
* set listCoutTransportEffectif replace-item mode listCoutTransportEffectif lput (temp LICENSE.md MetropolSim19.nlogo MetropolSim2.0.nlogo display.java display.nls doc fractal-network.java fractal-network.nls governement.java governement.nls indicators.nls infrastructure.nls land-use.nls listUtils.nls main.nls networkUtils.nls setup.nls transport.nls item j listNavettesPatches) item mode listCoutTransportEffectif
* 
* ]
* 
*  navettes used to update effective transport and distance variables ?
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
* set listChemins lput tempL listChemins
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
public static creerImmobilierM(){

* 
* 
}

* 
* 
public static creerImmobilierR(){

* 
* 
* 
}

* 
* 
* 
* 
* 
public static creerInfrastructure(){

* 
* 
* attributsLinks liste consitu�e de
*  typeNode
*  speed_l
*  capacity
*  waitTime
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
* create-link-from one-of nodes with [patchNode = bestPaire2] [
*  set color black
*  set maxSpeed 100
*  set capacity 10000
*  set waitTime 0
*  set BCRinit bestBCR
* ]
* 
* 
* 
* 
* 
* 
* set shape "ligne"
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
public static updateAccessibilitePatches(){

* 
* 
* 
* 
* 
* ifelse is-maire? tempmaire [
*  set listP [listPatchesMaire] of tempmaire
* ][
* 
* ]
* 
* 
* ifelse is-maire? tempmaire [
* set listAccessibilitesPatchesTemp []
* ][
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
*  set temp calculAccessibilite item i listP listP m
*  set listAccessibilitesPatches replace-item m listAccessibilitesPatches lput temp listAccessibilitesPatches
* 
* 
* 
* 
* 
* 
* 
* 
* ]
* ask patches [
* 
* ifelse is-maire? tempmaire [
* set accessibilitePatchesTemp temp
* ][
* 
* ]
* 
* 
* 
}

* 
* 
* 
* 
* 
*/
/**
public static evaluerCoutInfrastructure(){

* 
* 
* 
* 
*  let tempCout 0
*  let patchCourant patchA
*  let dist1 0
*  let head 0
*  ask patchA [
*  set dist1 distance patchB
*  set head towards patchB
*  ]
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
*  report dist1
* 
}

* 
* 
* 
* 
* 
*/
/**
public static evaluerBeneficeInfrastructure(){

* 
*  a terme impl�menter hausse accessibilit� et plus tard, impacts environnementaux de TC (dans les couts pour VP?)
* 
* 
* 
* 
* 
* 
* updateListCoutTransportsPatches tempmaire true
* 
* 
* 
* 
* let accesNew 0
* 
* 
* ifelse is-maire? tempmaire [
* 
* set accesNew sum [(sum listAnbrM + sum listAnbrR) LICENSE.md MetropolSim19.nlogo MetropolSim2.0.nlogo display.java display.nls doc fractal-network.java fractal-network.nls governement.java governement.nls indicators.nls infrastructure.nls land-use.nls listUtils.nls main.nls networkUtils.nls setup.nls transport.nls sum accessibilitePatches] of patches with [mairePatch = tempmaire]
* 
* 
* ][
* 
* set accesNew sum [(sum listAnbrM + sum listAnbrR) LICENSE.md MetropolSim19.nlogo MetropolSim2.0.nlogo display.java display.nls doc fractal-network.java fractal-network.nls governement.java governement.nls indicators.nls infrastructure.nls land-use.nls listUtils.nls main.nls networkUtils.nls setup.nls transport.nls sum accessibilitePatches] of patches
* 
* ]
* 
* 
* 
* 
* 
* 
* let accesNew calculerAccessibilite niveau typeTransport
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
*/
/**
public static coutTransportPatches(){

* 
* 
* 
*  1 = transports en commun
*  2 = voiture
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
* ask patch1 [set distTemp distTemp + (distance item i [listNoeuds] of patch1)]
* 
* 
* 
* 
* 
* 
* ask patch2 [set distTemp distTemp + (distance item j [listNoeuds] of patch2)]
* 
* 
* 
*  � ce stade distTemp est la distance "vol d'oiseau": il faut stocker cela!!!
* 
* BALISE
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
* ]
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
* AVERIFIER
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
* to-report calculAccessibilite [patchFrom listPatchs typeTransport]
public static calculAccessibilite(){

* 
* 
* 
* 
* 
* 
* 
*  ifelse is-maire? tempmaire [
*  set temp [sum listEnbr] of item i listPatchs LICENSE.md MetropolSim19.nlogo MetropolSim2.0.nlogo display.java display.nls doc fractal-network.java fractal-network.nls governement.java governement.nls indicators.nls infrastructure.nls land-use.nls listUtils.nls main.nls networkUtils.nls setup.nls transport.nls coutDistance(item i [item typeTransport listCoutTransportTemp] of patchFrom)
*  set listAccessibilitesPatchesTemp lput temp listAccessibilitesPatchesTemp
*  set toreport toreport + temp
*  ][
* 
* 
* 
* 
* set temp1 lput temp temp1
* 
* 
* 
* 
* 
* 
* 
* 
* set listAccessibilitesPatches replace-item typeTransport listAccessibilitesPatches lput temp (item typeTransport listAccessibilitesPatches)
* 
* 
* 
* 
* set toreport toreport + temp
*  ]
* 
* 
* let toreport 0
* ask patches [
*  ifelse temp? [
*  set toreport toreport + [sum listEnbr] of self LICENSE.md MetropolSim19.nlogo MetropolSim2.0.nlogo display.java display.nls doc fractal-network.java fractal-network.nls governement.java governement.nls indicators.nls infrastructure.nls land-use.nls listUtils.nls main.nls networkUtils.nls setup.nls transport.nls exp(- 1 LICENSE.md MetropolSim19.nlogo MetropolSim2.0.nlogo display.java display.nls doc fractal-network.java fractal-network.nls governement.java governement.nls indicators.nls infrastructure.nls land-use.nls listUtils.nls main.nls networkUtils.nls setup.nls transport.nls item i [listCoutTransportTemp] of patchFrom)
*  ][
*  set toreport toreport + [sum listEnbr] of self LICENSE.md MetropolSim19.nlogo MetropolSim2.0.nlogo display.java display.nls doc fractal-network.java fractal-network.nls governement.java governement.nls indicators.nls infrastructure.nls land-use.nls listUtils.nls main.nls networkUtils.nls setup.nls transport.nls exp(- 1 LICENSE.md MetropolSim19.nlogo MetropolSim2.0.nlogo display.java display.nls doc fractal-network.java fractal-network.nls governement.java governement.nls indicators.nls infrastructure.nls land-use.nls listUtils.nls main.nls networkUtils.nls setup.nls transport.nls item i [listCoutTransport] of patchFrom)
*  ]
* 
* ]
* 
* report toreport
*  accessibilite par type de transport.nls
}

* 
* 
* 
* 
* 
public static reportAccessibilite(){

* 
* 
* set accesNew sum [(sum listAnbrM + sum listAnbrR) LICENSE.md MetropolSim19.nlogo MetropolSim2.0.nlogo display.java display.nls doc fractal-network.java fractal-network.nls governement.java governement.nls indicators.nls infrastructure.nls land-use.nls listUtils.nls main.nls networkUtils.nls setup.nls transport.nls sum accessibilitePatches] of patches with [mairePatch = tempmaire]
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
* ask patches [set temp temp + (item c listAnbrM + item c listAnbrR) LICENSE.md MetropolSim19.nlogo MetropolSim2.0.nlogo display.java display.nls doc fractal-network.java fractal-network.nls governement.java governement.nls indicators.nls infrastructure.nls land-use.nls listUtils.nls main.nls networkUtils.nls setup.nls transport.nls item c accessibilitePatches]
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
public static accessibilitePonderee(){

* 
* let temp 0
* 
*  j'en suis l�
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
* set temp temp + item j item m listModesShare LICENSE.md MetropolSim19.nlogo MetropolSim2.0.nlogo display.java display.nls doc fractal-network.java fractal-network.nls governement.java governement.nls indicators.nls infrastructure.nls land-use.nls listUtils.nls main.nls networkUtils.nls setup.nls transport.nls item j item m listAccessibilitesPatches
* set temp temp + item c item m item j listModesShare LICENSE.md MetropolSim19.nlogo MetropolSim2.0.nlogo display.java display.nls doc fractal-network.java fractal-network.nls governement.java governement.nls indicators.nls infrastructure.nls land-use.nls listUtils.nls main.nls networkUtils.nls setup.nls transport.nls item c item m item j listAccessibilitesPatches
* set temp temp + item j item c item m listModesShare LICENSE.md MetropolSim19.nlogo MetropolSim2.0.nlogo display.java display.nls doc fractal-network.java fractal-network.nls governement.java governement.nls indicators.nls infrastructure.nls land-use.nls listUtils.nls main.nls networkUtils.nls setup.nls transport.nls item j item c item m listAccessibilitesPatches
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
public static updateListConnecteursPatches(){

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
* NL4 - set [listNoeuds] of patch1 replace-item m [listNoeuds] of patch1 listTemp
* 
* 
* 
* 
* 
* 
* 
* ask patch1 [
* 
* 
* ]
* 
}

* 
* 
* 
* 
* 
* 
* 
* to emptyActifs
* ask patches [
*  let c 0
*  while [c < ncsp] [
*  set list-A-nbr-M replace-item c list-A-nbr-M 0
*  set list-A-nbr-R replace-item c list-A-nbr-R 0
*  set c c + 1
*  ]
* ]
* 
* end
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
}
