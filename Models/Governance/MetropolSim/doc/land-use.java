public class land-use{

/**
*  Land-use evolution
* 
* 
*/
public static land-use(){

}

/**
*  Update utilities
* 
public static updateUtilites(){

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
public static mouvementsActifs(){

* 
*  in the case of social housing, must be evoked here, with list-A-nbr-M
* 
* 
* 
* 
*  variable used to study convergence
*  will be 2* real movement (as = sum abs (Delta ) on all patches, but -> 0 anyway )
* 
* 
*  for each csp
* 
* 
* 
* 
* 
*  temp = sum_{patches}{exp(beta(csp)U(csp,actives))}
* 
* 
* 
* 
* 
* 
* 
* set plabel int ( 100 LICENSE.md MetropolSim19.nlogo MetropolSim2.0.nlogo display.java display.nls doc fractal-network.java fractal-network.nls governement.java governement.nls indicators.java indicators.nls infrastructure.java infrastructure.nls land-use.java land-use.nls listUtils.nls main.nls networkUtils.nls setup.nls transport.nls exp (item c listcoeffUtilitesActifs LICENSE.md MetropolSim19.nlogo MetropolSim2.0.nlogo display.java display.nls doc fractal-network.java fractal-network.nls governement.java governement.nls indicators.java indicators.nls infrastructure.java infrastructure.nls land-use.java land-use.nls listUtils.nls main.nls networkUtils.nls setup.nls transport.nls item c listAUtiliteR) / temp ) / 100
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
*/
/**
public static mouvementsEmplois(){

* 
* 
* 
* 
* 
* 
* 
* 
* 
* 
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
*/
/**
public static updateDensityActifs(){

* 
* 
* 
* 
* 
*  list of densities by CSP
*  for each csp
* 
* 
* 
*  for each patch (other !)
* 
* 
*  for each mode
* 
*  list mode share : (mode,csp,patch) from this patch
* 
*  @TODO -- NOT USED --
* let tempCout coutDistance (item j item c item m listCoutTransport)
* 
* set tempActifs tempActifs + tempShare LICENSE.md MetropolSim19.nlogo MetropolSim2.0.nlogo display.java display.nls doc fractal-network.java fractal-network.nls governement.java governement.nls indicators.java indicators.nls infrastructure.java infrastructure.nls land-use.java land-use.nls listUtils.nls main.nls networkUtils.nls setup.nls transport.nls (item c [listAnbrR] of item j listPatchesRegion + item c [listAnbrM] of item j listPatchesRegion) LICENSE.md MetropolSim19.nlogo MetropolSim2.0.nlogo display.java display.nls doc fractal-network.java fractal-network.nls governement.java governement.nls indicators.java indicators.nls infrastructure.java infrastructure.nls land-use.java land-use.nls listUtils.nls main.nls networkUtils.nls setup.nls transport.nls tempCout
* 
*  check if we are dealing with another patch
* 
* 
* 
*  just weight by distance : no transportation cost ?
* 
* 
* 
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
*/
/**
public static updateDensityEmplois(){

* 
* 
* 
* 
* 
* 
* 
*  same procedure as for actives
* 
* 
* 
* 
* for each mode
* 
* 
* 
* 
* set tempEmplois tempEmplois + tempShare LICENSE.md MetropolSim19.nlogo MetropolSim2.0.nlogo display.java display.nls doc fractal-network.java fractal-network.nls governement.java governement.nls indicators.java indicators.nls infrastructure.java infrastructure.nls land-use.java land-use.nls listUtils.nls main.nls networkUtils.nls setup.nls transport.nls (item c [listEnbr] of item j listPatchesRegion) LICENSE.md MetropolSim19.nlogo MetropolSim2.0.nlogo display.java display.nls doc fractal-network.java fractal-network.nls governement.java governement.nls indicators.java indicators.nls infrastructure.java infrastructure.nls land-use.java land-use.nls listUtils.nls main.nls networkUtils.nls setup.nls transport.nls tempCout
* 
* 
* 
* 
* 
* 
* 
* 
* 
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
*/
/**
public static updateUtiliteActifs(){

* 
* 
* 
* 
*  compute utility of actives for each patch and each csp, and sum of utilities on all patches
* 
* 
* 
* set listAutiliteM replace-item c listAutiliteM item c listAutiliteM
* 
* 
* 
* 
* 
* 
* 
* 
* 
* 
* set listAutiliteM replace-item c listAutiliteM item c listAutiliteM
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
*/
/**
public static updateUtiliteEmplois(){

* 
* 
* 
* 
* 
* 
* 
* set list-E-utilite-M replace-item c list-E-utilite-M item c list-E-utilite-M
* 
* 
* 
* 
* 
* 
* 
* 
* 
* set listEutiliteM replace-item c listEutiliteM item c listEutiliteM
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
*/
/**
public static calculerutiliteActifs(){

* 
*  get accessibility for this csp from accessibility list
* 
* 
* 
* 
* 
* 
* 
* 
* 
* 
* 
* 
* 
* 
* coeffAccessibiliteFormeUrbaine
* 
}

* 
* 
* 
* 
* 
*/
public static calculerutiliteEmplois(){

}

}
