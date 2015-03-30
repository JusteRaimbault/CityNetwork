
;;;;;;;;;;;;;;;;;;;;;;;;;;
;; © F Le Nechet, J Raimbault 2015
;;;;;;;;;;;;;;;;;;;;;;;;;;



__includes [
  
  ;; setup
  "setup.nls" 
  
  ;; main
  "main.nls"
  
  ;; transport
  "transport.nls"
  
  ;;governement
  "governement.nls"
  
  ;; land-use
  "land-use.nls"
  
  
  ;;;;;;;;;;;;
  ;; Utils
  ;;;;;;;;;;;;
  
  ;; local utils
  
  ;; network
  "networkUtils.nls"
  
  ;; list
  "listUtils.nls"
  
  ;;external
  ; note : will not work in general - should put submodule locally
  "/Users/Juste/Documents/ComplexSystems/Softwares/NetLogo/utils/LogUtilities.nls"
  
]

globals [
;parametrePolycentrisme
;parAct
;parEmp
;parametreCoutDistance
;parametreDispersion
;parametreRatDispersion

Nmaires ; nombre de maires

Ncsp ; nombre de cat�gories socio-professionnelles
listNactifs
listPatchesRegion
listNbrConnecteurs
listSpeed
Nmodes
coeffChoixModal
listCarOwnership
listSalaires
listcoeffAccessibiliteFormeUrbaineActifs
listcoeffAccessibiliteFormeUrbaineEmplois
listcoeffUtilitesActifs
listcoeffUtilitesEmplois
matActifsActifs
matActifsEmplois
matEmploisActifs
matEmploisEmplois
; d�but "utile pour faire le r�seau fractal"
DFRACTAL
kFRACTAL
orderOfComplexity
fractalFactor
numberOfDirections
randomness%
radial%
randomness?
additivity?
int?
ext?
;fin "utile pour faire le r�seau fractal"

;d�but "utile pour la distribution de population initiale"
listActBussA
listActBussb
listEmpBussA
listEmpBussb
;fin "utile pour la distribution de population initiale"

; d�but "utile pour une prise en compte fine des couts de transport"
listvaleursTemps ; par csp
listcoutDistance ; par csp et par mode; typiquement prix du p�trole, abonnement de carte orange...

; fin "utile pour une prise en compte fine des couts de transport"


resultatCout
resultatDist


  ;; utils vars
  ;log-level  ;; -> added as chooser in interface

]



breed [maires maire]
breed [regions region]
breed [actifs actif]
breed [emplois emploi]
breed [chemins chemin]
breed [nodes node]



patches-own [
  mairePatch
  listAutiliteM
  listAutiliteR
  listEutiliteM
  listEutiliteR
  listAnbrR
  listAnbrM
  listEnbr
  dist-to-patch
  listCoutTransport
  ;listCoutTransportTemp
listDistTransportEffectif
listCoutTransportEffectif
listDistOiseauTransportEffectif
listCoutOiseauTransportEffectif
listDistReseauTransportEffectif
listCoutReseauTransportEffectif
;listCoutTransportEffectifTemp
listChemins
listCheminsTemp
listNoeuds
accessibilitePatches
;accessibilitePatchesTemp
listAccessibilitesPatches
;listAccessibilitesPatchesTemp
listNavettesPatches
listModesShare
listNavettesModes
listDensiteEmplois
listDensiteActifs
has-node?
has-maire?
]



maires-own [
centreMaire
listA-AbussiereInit ; param�tre de Bussi�re servant � l'initialisation (actifs)
listA-bbussiereInit ; param�tre de Bussi�re servant � l'initialisation (emplois)
listE-AbussiereInit ; param�tre de Bussi�re servant � l'initialisation (actifs)
listE-bbussiereInit ; param�tre de Bussi�re servant � l'initialisation (emplois) 

listPatchesMaire
budget
money-
money+
]

actifs-own [
cspActif
ageActif
emploiActif
]

emplois-own [
cspEmploi
ageEmploi
actifEmploi
]

chemins-own [
modeChemin
typeChemin
tempsChemin
distanceChemin

]

nodes-own [
typeNode
patchNode
assigned? ; pour dijkstra
final? ; pour dijkstra
dist-to-root ; pour dijkstra
time-to-root ; pour dijkstra
path ; pour dijkstra
connection
tempNode?
; d�but "pour le r�seau fractal"
father
order
node-id
distFRACTAL
radial
rocade
; fin "pour le r�seau fractal"
]

links-own [
  speed_l
  capacity_l
  waitTime
  typeLink
  tempLink?
  utilisation_l
  utilisation_temp
  speed_empty_l
  scale_l
]








to updateListConnecteursPatches [patch1]

let m 0

  ;; log-debug "je commence mes connecteurs" log-debug word "nombre de modes" nModes ;; DEBUG
  
  ask patch1 [
    set listNoeuds [[]]
  ]

while [m < nModes][
ask patch1 [
  set listNoeuds lput [] listNoeuds
  ;;;;;;;;;;show m
  ;;;;;;;;;;show listNoeuds
]
  set m m + 1
]



set m 0
while [m < nModes][

let nbrC item m listNbrConnecteurs

if any? nodes with [typeNode = m] [
if count nodes with [typeNode = m] < nbrC [
  set nbrC count nodes with [typeNode = m]
]
let nodes1 min-n-of nbrC nodes with [typeNode = m] [distance patch1] 

let listTemp []
ask nodes1 [
  set listTemp lput self listTemp
]

ask patch1 [set listNoeuds replace-item m listNoeuds listTemp]
;NL4 - set [listNoeuds] of patch1 replace-item m [listNoeuds] of patch1 listTemp

]


   set m m + 1
]

;ask patch1 [
;;;;;;;;;;;show "mes connecteurs sont"
;;;;;;;;;;;show listNoeuds
;]

end










to updateListCoutTransportsPatches [tempmaire temp?]
;;;;;;;;;;;show "d�but"
let listP []
;ifelse is-maire? tempmaire [
;  set listP [listPatchesMaire] of tempmaire
;][
  set listP listPatchesRegion
;]

let i 0
let m 0
while [i < length listP] [
  updateListConnecteursPatches item i listP
  ;;;;;;;;;;;;;show "update Connecteurs OK"
 
 ask item i listP [
  ;;;;;;;;;;;show 1


;  set listChemins [[]] 
;  set listCoutTransport [[]]
;  set listCoutTransportEffectif [[[]]]
 
   set listChemins [] 
  set listCoutTransport []
  set listDistTransportEffectif []
  set listCoutTransportEffectif []
  set listDistOiseauTransportEffectif []
  set listCoutOiseauTransportEffectif [] 
   set listDistReseauTransportEffectif []
  set listCoutReseauTransportEffectif [] 
  
set m 0

  while [m < nModes] [

    ;;;;;;;;;;;show m * 10
    ;set listCoutTransportTemp lput [] listCoutTransportTemp 
    ;set listCoutTransportEffectifTemp lput []  listCoutTransportEffectifTemp
    ;set listCheminsTemp lput [] listCheminsTemp
    set listChemins lput [] listChemins
    set listCoutTransport lput [] listCoutTransport
    ;set listCoutTransportEffectif lput [[]] listCoutTransportEffectif
set listDistTransportEffectif lput [] listDistTransportEffectif    
set listCoutTransportEffectif lput [] listCoutTransportEffectif
set listDistOiseauTransportEffectif lput [] listDistOiseauTransportEffectif    
set listCoutOiseauTransportEffectif lput [] listCoutOiseauTransportEffectif    
set listDistReseauTransportEffectif lput [] listDistReseauTransportEffectif    
set listCoutReseauTransportEffectif lput [] listCoutReseauTransportEffectif    
  
;    while [m < Nmodes] [
;      set listNavettesModes lput [[]] listNavettesModes
;      set listModesShare lput [[]] listModesShare
;      let c 0
;      while [c < Ncsp] [
;         set listNavettesModes replace-item m listNavettesModes lput [] item m listNavettesModes
;        set listModesShare replace-item m listModesShare lput [] item m listModesShare
;        
;        set c c + 1
;      ]
;      set m m + 1
;    ]    
;    
    
    
        let c 0
    
    while [c < Ncsp] [
    set listDistTransportEffectif replace-item m listDistTransportEffectif lput [] item m listDistTransportEffectif
    set listCoutTransportEffectif replace-item m listCoutTransportEffectif lput [] item m listCoutTransportEffectif
        set listDistOiseauTransportEffectif replace-item m listDistOiseauTransportEffectif lput [] item m listDistOiseauTransportEffectif
    set listCoutOiseauTransportEffectif replace-item m listCoutOiseauTransportEffectif lput [] item m listCoutOiseauTransportEffectif
        set listDistReseauTransportEffectif replace-item m listDistReseauTransportEffectif lput [] item m listDistReseauTransportEffectif
    set listCoutReseauTransportEffectif replace-item m listCoutReseauTransportEffectif lput [] item m listCoutReseauTransportEffectif
    
     set listCoutTransport replace-item m listCoutTransport lput [] item m listCoutTransport;MODIFENCOURS
     ; ;;;;show listCoutTransportEffectif
      set c c + 1
    ]
    set m m + 1
    ;;;;;;;;;;show "on calcule initialise les temps entre patches pour le mode"
    ;;;;;;;;;;show m
    ;;;;;;;;;;show "listCoutTransport"
    ;;;;;;;;;;show listCoutTransport
  
  ]  
]
 set i i + 1
]
;MODIFENCOURS
;set m 0
;while [m < nModes] [
;  ;;;;;;;;;;;show "je m'apprete a updater les couts, pour le mode / 10"
;  ;;;;;;;;;;;show m * 10
;  updateListCoutTransportsPatchesMode tempmaire temp? listP m
;  set m m + 1
;]

set m 0
while [m < nModes] [
    let c 0
    while [c < Ncsp] [
    ;;;;;;;;;;;show "je m'apprete a updater les couts, pour le mode / 10"
    ;;;;;;;;;;;show m * 10
    updateListCoutTransportsPatchesMode tempmaire temp? listP m c
    set c c + 1
  ]
  set m m + 1 
]





end

to updateListCoutTransportsPatchesMode [tempmaire temp? listP mode csp]

;;;;;;;;;;show "on calcule les temps entre patches pour le mode"
;;;;;;;;;;show mode

let i 0
let temp 0
let tempD 0
let tempDOiseau 0
let tempDReseau 0
let tempCOiseau 0
let tempCReseau 0

let tempL []
while [i < length listP] [
  let j 0
;  ask item i listP [
;  ifelse is-maire? tempmaire [
;  
;  set listCoutTransportTemp []  
;  set listCoutTransportEffectifTemp []
;  if not temp? [  set listCheminsTemp [] ]
;  ][
;  set listCoutTransport []
;  set listCoutTransportEffectif []
;  if not temp? [  set listChemins [] ]
;  ]
;  ]
;  
;    
  ;;;;;;;;;;;;;show "liste couts initialis�e"
  while [j < length listP] [
    ;;;;;;;;;;;show item i listP
    ;;;;;;;;;;;show item j listP
    ask item i listP [
    set tempD (item 4 coutTransportPatches item i listP item j listP mode csp)
    set tempDOiseau (item 0 coutTransportPatches item i listP item j listP mode csp)
    set tempDReseau (item 1 coutTransportPatches item i listP item j listP mode csp)
    set tempCOiseau (item 2 coutTransportPatches item i listP item j listP mode csp)
    set tempCReseau (item 3 coutTransportPatches item i listP item j listP mode csp)    
    set temp (item 5 coutTransportPatches item i listP item j listP mode csp)
    if not temp? [set tempL but-first but-first but-first but-first but-first but-first coutTransportPatches item i listP item j listP mode csp]
;    ifelse is-maire? tempmaire [
;    ;set listCoutTransportTemp lput temp listCoutTransportTemp
;    set listCoutTransportTemp replace-item mode listCoutTransportTemp lput temp item mode listCoutTransportTemp
;    
;    
;    if listNavettesPatches != 0 [
;    
;    ;set listCoutTransportEffectifTemp lput (temp * item j listNavettesPatches) listCoutTransportEffectifTemp
;    set listCoutTransportEffectifTemp replace-item mode listCoutTransportEffectifTemp lput (temp * item j listNavettesPatches) item mode listCoutTransportEffectifTemp
;    
;    ]
;    if not temp? [
;    ;set listCheminsTemp lput tempL listCheminsTemp
;    set listCheminsTemp replace-item mode listCheminsTemp lput tempL item mode listCheminsTemp
;    ]
;    ]
;    [
    ;MODIFENCOURSset listCoutTransport replace-item mode listCoutTransport lput temp item mode listCoutTransport
    let trefle item mode listCoutTransport
      set trefle replace-item csp trefle lput (temp) item csp trefle
       set listCoutTransport replace-item mode listCoutTransport trefle
    
    if listNavettesPatches != 0 [ 
    ;MODIFENCOURSset c 0
    ;MODIFENCOURSwhile [c < nCsp] [
    let treff item mode listCoutTransportEffectif
      set treff replace-item csp treff lput (temp * item j item csp listNavettesPatches) item csp treff
       set listCoutTransportEffectif replace-item mode listCoutTransportEffectif treff
      ;MODIFENCOURSset c c + 1
    ;]
    
    ;set listCoutTransportEffectif replace-item mode listCoutTransportEffectif lput (temp * item j listNavettesPatches) item mode listCoutTransportEffectif
    
    ;]
   
       let dreif item mode listDistTransportEffectif
      set dreif replace-item csp dreif lput (tempD * item j item csp listNavettesPatches) item csp dreif
       set listDistTransportEffectif replace-item mode listDistTransportEffectif dreif
   
       let dreifDistOiseau item mode listDistOiseauTransportEffectif
      set dreifDistOiseau replace-item csp dreifDistOiseau lput (tempDOiseau * item j item csp listNavettesPatches) item csp dreifDistOiseau
       set listDistOiseauTransportEffectif replace-item mode listDistOiseauTransportEffectif dreifDistOiseau
       
              let dreifDistReseau item mode listDistReseauTransportEffectif
      set dreifDistReseau replace-item csp dreifDistReseau lput (tempDReseau * item j item csp listNavettesPatches) item csp dreifDistReseau
       set listDistReseauTransportEffectif replace-item mode listDistReseauTransportEffectif dreifDistReseau
       
         let dreifCoutOiseau item mode listCoutOiseauTransportEffectif
      set dreifCoutOiseau replace-item csp dreifCoutOiseau lput (tempCOiseau * item j item csp listNavettesPatches) item csp dreifCoutOiseau
       set listCoutOiseauTransportEffectif replace-item mode listCoutOiseauTransportEffectif dreifCoutOiseau
       
              let dreifCoutReseau item mode listCoutReseauTransportEffectif
      set dreifCoutReseau replace-item csp dreifCoutReseau lput (tempCReseau * item j item csp listNavettesPatches) item csp dreifCoutReseau
       set listCoutReseauTransportEffectif replace-item mode listCoutReseauTransportEffectif dreifCoutReseau
       
  
   
   
   
   
     if not temp? [ 
      ;set listChemins lput tempL listChemins
      set listChemins replace-item mode listChemins lput tempL item mode listChemins
      ;;;;;;;;show listChemins
      ]
    ]
    
    
    
    ;;;;;;;;;;;;;show "cout tranport i -> j calcul�"
    ]
    set j j + 1
  ]
  set i i + 1
]


end





to chercheEmploi [temp-actif]
; il s'agit pour l'actif consid�r� de trouver un emploi. pour l'instant, on fait
; cela n'importe au hasard, sans consid�ration de distance
ask temp-actif [
  set emploiActif one-of emplois with [actifEmploi = 0]
  
  ask emploiActif [set actifEmploi myself]
  ;set [actifEmploi] of emploiActif self
]


end

to chercheActif [temp-emploi]


end




to updatePlots
set-current-plot "accessibiliteTicks"
plotxy ticks sum [sum accessibilitePatches] of patches
set-current-plot "tempsTransport"
let m 0
let c 0
let temp 0
ask patches [
set m 0
while [m < nModes] [
  set c 0
  while [c < nCSP] [
    set temp temp + sum item c item m listCoutTransportEffectif
    set c c + 1
  ]
  set m m + 1
]
]

plotxy ticks temp

end

to-report chooseMaire
let tempM "region"

let tempR random 100
if tempR < probaLocal [
let argent sum [budget] of maires
let temp 0
ask maires [
set money- temp
set temp temp + budget
set money+ temp
]
let tempR2 random-float argent
;let tempM one-of maires


ask one-of maires with [money- <= tempR2 and money+ > tempR2] [
set tempM self
;updateListCoutTransportsPatches tempM
;updateAccessibilitePatches tempM
]

]
;;;;;show tempM
report tempM
end

to emptyActifs
ask patches [
let c 0
while [c < ncsp] [
  set listAnbrM replace-item c  listAnbrM 0
  set listAnbrR replace-item c  listAnbrR 0
  set c c + 1
]

]

end









to-report calculerutiliteActifs [csp]
let acces item csp AccessibilitePatches
let forme 1

let c 0
while [c < nCSP] [

    if item c listDensiteActifs > 0 [
    set forme forme * exp(item c item csp matActifsActifs * ln(item c listDensiteActifs))
    ]
    if item c listDensiteEmplois > 0 [
    set forme forme * exp(item c item csp matActifsEmplois * ln(item c listDensiteEmplois))
    ] 
  set c c + 1
]
;coeffAccessibiliteFormeUrbaine
report exp(item csp listcoeffAccessibiliteFormeUrbaineActifs * ln(acces)) * exp((1 - item csp listcoeffAccessibiliteFormeUrbaineActifs) * ln(forme))
end


to-report calculerutiliteEmplois [csp]
let acces item csp AccessibilitePatches
let forme 1

let c 0
while [c < nCSP] [

    if item c listDensiteActifs > 0 [
    set forme forme * exp(item c item csp matEmploisActifs * ln(item c listDensiteActifs))
    ]
    if item c listDensiteEmplois > 0 [
    set forme forme * exp(item c item csp matEmploisEmplois * ln(item c listDensiteEmplois))
    ] 
    ;;;;show forme
  set c c + 1
]
;;show forme
;coeffAccessibiliteFormeUrbaine
report exp(item csp listcoeffAccessibiliteFormeUrbaineEmplois * ln(acces)) * exp((1 - item csp listcoeffAccessibiliteFormeUrbaineEmplois) * ln(forme))
end




to mouvementsActifs
; si il y a des logements sociaux, c'est l� qu'il faut l'�voquer, avec les listAnbrM; pour l'instant, rien de tout �a...

let c 0
let temp 0
while [c < Ncsp] [
  set temp 0
  ask patches [
    set temp temp + exp (item c listcoeffUtilitesActifs * item c listAUtiliteR)
  ]
  ;;;;show temp
  ask patches [
    ;set plabel int ( 100 * exp (item c listcoeffUtilitesActifs * item c listAUtiliteR) / temp )  / 100
    set listAnbrR replace-item c listAnbrR (item c listNactifs * exp (item c listcoeffUtilitesActifs * item c listAUtiliteR) / temp)
    ;;;;show listAnbrR
  ]
  set c c + 1
]

end

to mouvementsEmplois

let c 0
let temp 0
while [c < Ncsp] [
set temp 0
  ask patches [
    set temp temp + exp (item c listcoeffUtilitesEmplois * item c listEUtiliteR)
  ]
  ;;;show temp
  ask patches [
    set listEnbr replace-item c listEnbr (item c listNactifs * exp (item c listcoeffUtilitesEmplois * item c listEUtiliteR) / temp)
  ]
  set c c + 1
]
end

to creerInfrastructureR [temp-maire]
let bestPaire1 0
let bestPaire2 0
let bestBCR -1000
let tempC 0
let tempB 0
updateListCoutTransportsPatches temp-maire false
updateAccessibilitePatches temp-maire
;let accesOld calculerAccessibilite "region" 1
;let accesOld sum [(sum listAnbrM + sum listAnbrR) * accessibilitePatches] of patches
;;;;;;;;;;;;show accesOld
;let accesOld 0

let accesOld reportAccessibilite temp-maire

;ifelse is-maire? temp-maire [
;set accesOld sum [(sum listAnbrM + sum listAnbrR) * sum accessibilitePatches] of patches with [mairePatch = temp-maire]
;;set accesOld sum [sum listCoutTransportEffectifTemp] of patches with [mairePatch = temp-maire]
;][
;set accesOld sum [(sum listAnbrM + sum listAnbrR) * sum accessibilitePatches] of patches
;;set accesOld sum [sum listCoutTransportEffectif] of patches
;]
;;;;;;;;;;;;show "temps total de transport des administr�s"
;;;;;;;show "accessibilite"
;;;;;;;show accesOld
;
; and (mairePatch = temp-maire)
;
;ask patches with [mairePatch = ] [
ask patches with [has-node? = 1 or has-maire? = 1] [
if not is-maire? temp-maire or mairePatch = temp-maire [
let patchA self
  ask neighbors [
    if not is-maire? temp-maire or mairePatch = temp-maire [
    let patchB self
         let attributs (list 0 3 100 0)
         ifelse is-maire? temp-maire [set attributs lput 115 attributs]
         [set attributs lput 15 attributs]
;      ;;;;;;;;;;;;;;show patch x1 y1
;      ;;;;;;;;;;;;;;show patch x2 y2
      ;;;;;;;show "maintenant je vais entrer dans EVALUERBENEFICE"
    set tempB ((evaluerBeneficeInfrastructure patchA patchB attributs temp-maire 0) - accesOld)
    ; signe - pour les temps de transport: on cherche soit � maximiser l'accessibilit� totale, soit � minimiser le temps de transport total...
;      ;;;;;;;;;;;;;;;show tempB
      set tempC evaluerCoutInfrastructure patchA patchB 0
      ;show "gain accessibilit� possible"
      ;show tempB
      if (tempB / tempC) > bestBCR [    
          set bestBCR (tempB / tempC)
          set bestPaire1 patchA
          set bestPaire2 patchB
       ]
  ]
  ]
]
]
ask nodes with [tempNode? = 1] [die]
if true [;bestBCR > 1 [
let attributs (list 0 3 100 0)
ifelse is-maire? temp-maire [set attributs lput 115 attributs][set attributs lput 15 attributs]
  creerInfrastructure bestPaire1 bestPaire2 attributs 0
  creerInfrastructure bestPaire2 bestPaire1 attributs 0
]


ask nodes with [tempNode? = 1] [die]
if true [;bestBCR > 1 [
let attributs (list 0 3 100 0)

creerInfrastructure bestPaire1 bestPaire2 attributs 0
creerInfrastructure bestPaire2 bestPaire1 attributs 0
]
end


to creerImmobilierM [temp-maire]

end

to creerImmobilierR


end

to creerInfrastructure [bestPaire1 bestPaire2 attributsLinks tempLink]

;attributsLinks liste consitu�e de
; typeNode
; speed_l
; capacity
; waitTime


if (not any? nodes with [patchNode = bestPaire1 and typeNode >= 0]) and is-patch? bestPaire1 [
ask bestPaire1 [
  sprout-nodes 1 [
    set typeNode item 0 attributsLinks
    set patchNode myself
    set hidden? true
    set shape "circle"
    set color red
    set size 0.1
    set tempNode? tempLink
  ]
  if tempLink != 1 [set has-node? 1]
]
]
if (not any? nodes with [patchNode = bestPaire2 and typeNode >= 0]) and is-patch? bestPaire1  [
ask bestPaire2 [
  sprout-nodes 1 [
    set typeNode item 0 attributsLinks
    set patchNode myself
    set hidden? true
    set shape "circle"
    set color red
    set size 0.1
    set tempNode? tempLink
  ]
  if tempLink != 1 [set has-node? 1]
]
]
if any? nodes with [patchNode = bestPaire1  and typeNode >= 0] and any? nodes with [patchNode = bestPaire2 and typeNode >= 0] [
ask one-of nodes with [patchNode = bestPaire1  and typeNode >= 0] [

;create-link-from one-of nodes with [patchNode = bestPaire2] [
;  set color black
;  set maxSpeed 100
;  set capacity 10000
;  set waitTime 0
;  set BCRinit bestBCR
;]

create-link-to one-of nodes with [patchNode = bestPaire2 and typeNode >= 0] [
  ifelse tempLink = 1 [
  set color item 4 attributsLinks + 3
  ][set color item 4 attributsLinks
  ]
  ;set shape "ligne"
  
  set typeLink item 0 attributsLinks
  ifelse typeLink = 0 [
    set shape "rail"
  ][
    set shape "route"
  ]
  
  set speed_empty_l item 1 attributsLinks
  set speed_l speed_empty_l
  set capacity_l item 2 attributsLinks
  set waitTime item 3 attributsLinks
  set tempLink? tempLink
  ]
]
]
end

to updateAccessibilitePatches [tempmaire]
let i 0
let m 0
let temp 0
let listP []
;ifelse is-maire? tempmaire [
;  set listP [listPatchesMaire] of tempmaire
;][
  set listP listPatchesRegion
;]
while [i < length listP] [
ask item i listP [
;ifelse is-maire? tempmaire [
;set listAccessibilitesPatchesTemp []
;][
set  listAccessibilitesPatches []
set m 0
while [m < nModes] [
  set listAccessibilitesPatches lput [] listAccessibilitesPatches
  let c 0
  while [c < Ncsp] [
    set listAccessibilitesPatches replace-item m listAccessibilitesPatches lput [] item m listAccessibilitesPatches
    set c c + 1
  ]
  set m m + 1
]

set m 0
while [m < nModes] [
;  set temp calculAccessibilite item i listP listP m
;  set listAccessibilitesPatches replace-item m listAccessibilitesPatches lput temp listAccessibilitesPatches
;  
  let c 0
  while [c < nCsp] [
    calculAccessibilite (item i listP) listP m c
    set c c + 1
  ]
  set m m + 1
]
;]
;ask patches [

;ifelse is-maire? tempmaire [
;set accessibilitePatchesTemp temp
;][
set accessibilitePatches accessibilitePonderee self
;]
]
set i i + 1
]
end
to-report evaluerCoutInfrastructure [patchA patchB typeTransport]
;;;;;;;;;;;;;;;;show "j'�value le cout de l'infrastructure"
let tempCout 0
let patchCourant patchA
let dist1 0
let head 0
ask patchA [
  set dist1 distance patchB
  set head towards patchB
]
;let i 0
;
;while [i < dist1 + 1] [; and patchCourant != patchB] [
;  if patch-at-heading-and-distance head i != patchCourant [
;    set patchCourant patch-at-heading-and-distance head i
;    set tempCout sum [listAnbrM * listAutiliteR] of patchCourant + sum [listEnbr * listEutiliteM] of patchCourant
;  ]
;  set i i + 1
;]
;report tempCout

report dist1
;report 1
end

to-report accessibilitePonderee [patch1]
  ;let temp 0
  let j 0
  let listTemp [] ; j'en suis l�
  let c 0
  while [c < nCSP] [
        set listTemp lput 0 listTemp
          set c c + 1
      ]
  ;;;;;show listModesShare
  while [j < length listPatchesRegion] [
    let m 0
    while [m < nModes] [
      set c 0
      while [c < nCSP] [
        ;;;;;show item j item m listAccessibilitesPatches
        ;;;;;show item j item m listModesShare
        ;set temp temp + item j item m listModesShare * item j item m listAccessibilitesPatches
        ;set temp temp + item c item m item j listModesShare * item c item m item j listAccessibilitesPatches
        ;set temp temp + item j item c item m listModesShare * item j item c item m listAccessibilitesPatches
        set listTemp replace-item c listTemp (item c listTemp + item j item c item m listModesShare * item j item c item m listAccessibilitesPatches)
        set c c + 1
      ]
      
      
      set m m + 1
    ]
    
    
    set j j + 1
  ]

report listTemp
end


to-report reportAccessibilite [temp-maire]

;set accesNew sum [(sum listAnbrM + sum listAnbrR) * sum accessibilitePatches] of patches with [mairePatch = tempmaire]
let listP []
ifelse is-maire? temp-maire [
  set listP [listPatchesMaire] of temp-maire
][
  set listP listPatchesRegion
]
let temp 0
let c 0
while [c < Ncsp] [

  let i 0
  while [i < length listP] [
  ask item i listP [set temp temp + (item c listAnbrM + item c listAnbrR) * item c accessibilitePatches]
    set i i + 1
  ]
  ;ask patches [set temp temp + (item c listAnbrM + item c listAnbrR) * item c accessibilitePatches]
  
 
  
  set c c + 1
]

report temp
end




to-report evaluerBeneficeInfrastructure [patchA patchB attributsLinks tempmaire typeTransport]
; a terme impl�menter hausse accessibilit� et plus tard, impacts environnementaux de TC (dans les couts pour VP?)
  log-debug "Evaluating infrastructure"
;;;;;;;;;;;;;;show patchA
;;;;;;;;;;;;;;show patchB

creerInfrastructure patchA patchB attributsLinks 1
creerInfrastructure patchB patchA attributsLinks 1
;updateListCoutTransportsPatches tempmaire true
updateListCoutTransportsPatches "region" false
updateAccessibilitePatches tempmaire
updateDeplacementsDomicileTravail

;let accesNew 0
let accesNew reportAccessibilite tempmaire

;ifelse is-maire? tempmaire [
;
;set accesNew sum [(sum listAnbrM + sum listAnbrR) * sum accessibilitePatches] of patches with [mairePatch = tempmaire]
;; a changer, bien entendu, pour tenir compte des CSP
;;set accesNew sum [sum listCoutTransportEffectifTemp] of patches with [mairePatch = tempmaire]
;][
;
;set accesNew sum [(sum listAnbrM + sum listAnbrR) * sum accessibilitePatches] of patches
;;set accesNew sum [sum listCoutTransportEffectif] of patches
;]


;;;;;;;;;;;;show "gain possible de transport des administr�s"
;;;;;;;;;;;;show (- (accesNew - accesOld))


;let accesNew calculerAccessibilite niveau typeTransport
;;;;;;;;;;;;;;show accesNew - accesOld
;;;;;;;;;;;;;;show "c'est le b�n�fice de la construction propos�e"

ask links with [tempLink? = 1] [
die
]
ask nodes with [tempNode? = 1] [die]
;;;;;;;;;;;;show  accesNew - accesOld
report (accesNew)

end

to initAccessibilite
let i 0
while [i < length listPatchesRegion] [
ask item i listPatchesRegion [
;  set listNavettesModes [[[]]]
;  set listModesShare [[[]]]
   set listNavettesModes []
   set listModesShare []
  

  let m 0
    while [m < Nmodes] [
      set listNavettesModes lput [] listNavettesModes
      set listModesShare lput [] listModesShare
      let c 0
      while [c < Ncsp] [
        set listNavettesModes replace-item m listNavettesModes lput [] item m listNavettesModes
        set listModesShare replace-item m listModesShare lput [] item m listModesShare

       ; set listNavettesModes replace-item m listNavettesModes lput [] listNavettesModes
        ;set listModesShare replace-item m listModesShare lput [] listModesShare
        ;;;;;show listModesShare
        
        set c c + 1
      ]
      set m m + 1
    ]
]
set i i + 1
]
set i 0



while [i < length listPatchesRegion] [
  let j 0
  
  
  while [j < length listPatchesRegion] [
    let temp 0
    let temp1 0
    ask item i listPatchesRegion [
;    let m 0
;    while [m < Nmodes] [
;    
;      set temp temp + exp(- coeffChoixModal * item j item m listCoutTransport)
;      set m m + 1
;    ]
    let m 0
    while [m < Nmodes] [
      let c 0
      while [c < Ncsp] [

     ; set temp1 exp(- coeffChoixModal * [item j item m listCoutTransport] of item i listPatchesRegion)
      
     ;let tempShare (item c listCarOwnership * (temp1 / temp))
      ;if m = 0 [set tempShare (tempShare  + (1 - item c listCarOwnership)) ]
      
      
      
      let tempShareL item m listModesShare
      ;set tempShareL lput tempShare tempShareL
      set tempShareL replace-item c tempShareL lput (1 - m) item c tempShareL
      
      
      ; set listModesShare replace-item m listModesShare lput (item c carownership * (temp1 / temp)) item m listModesShare

           set listModesShare replace-item m listModesShare tempShareL
      
      ;;;;;show listModesShare
      ;let tempNavettes item c listNavettesPatches
;      ;;;;;show "tempNavettes"
;      ;;;;;show tempNavettes
;      ;;;;;show "listNavettesPatches"
;      ;;;;;show listNavettesPatches
      ;set tempNavettes lput ((item c listNavettesPatches) * (tempShare)) tempNavettes
      
      ;set tempNavettes multiplyList tempNavettes (tempShare)
       ;let temp3 item m listNavettesModes
       ;set temp3 replace-item c temp3 tempNavettes 
     
     ;  set listNavettesModes replace-item m listNavettesModes lput ((item j listNavettesPatches) * item m listModesShare) item m listNavettesModes
     
     
     ;set listNavettesModes replace-item m listNavettesModes temp3
     
      ;;;;;;;show listNavettesModes
        
        set c c + 1
      ]
      set m m + 1
    ]    
    
    ]
    
    set j j + 1
  ]
  set i i + 1
]





updateAccessibilitePatches "region"
end



;to-report calculAccessibilite [patchFrom listPatchs typeTransport]
to calculAccessibilite [patchFrom listPatchs typeTransport csp]
;;;;;;;;;;;;;;;;;show "je calcule l'accessibilite depuis un patch donn�"
let i 0
let toreport 0
let temp 0
while [i < length listPatchs] [
  
;  ifelse is-maire? tempmaire [
;  set temp [sum listEnbr] of item i listPatchs * coutDistance(item i [item typeTransport listCoutTransportTemp] of patchFrom)
;  set listAccessibilitesPatchesTemp lput temp listAccessibilitesPatchesTemp
;  set toreport toreport + temp
;  ][
  set temp [item csp listEnbr] of item i listPatchs * coutDistance(item i [item csp item typeTransport listCoutTransport] of patchFrom)
  
  let temp1 item typeTransport listAccessibilitesPatches
  ;;;;show temp1
  ;set temp1 lput temp temp1
  set temp1 replace-item csp  temp1  (lput temp item csp temp1)
  
  
  
  set listAccessibilitesPatches replace-item typeTransport listAccessibilitesPatches temp1 
  
  ;;;;show listAccessibilitesPatches
  
  ;set listAccessibilitesPatches replace-item typeTransport listAccessibilitesPatches lput temp (item typeTransport listAccessibilitesPatches)
  
  
  
  
  ;set toreport toreport + temp
;  ]
  set i i + 1
]
;let toreport 0
;ask patches [
;  ifelse temp? [
;  set toreport toreport + [sum listEnbr] of self * exp(- 1 * item i [listCoutTransportTemp] of patchFrom); a changer pour les accessibilit�s r�gionales
;  ][
;  set toreport toreport + [sum listEnbr] of self * exp(- 1 * item i [listCoutTransport] of patchFrom); a changer pour les accessibilit�s r�gionales
;  ]
;
;]

;report toreport
; accessibilite par type de transport????
end




to-report coutTransportPatches [patch1 patch2 typeTransport csp]
;;dictionnaire des types de transport

; 1 = transports en commun
; 2 = voiture



let cheminTemp []


let coutMin 99999
let cout1 0
let dist1 0
let distOiseau 0
let distReseau 0
let coutOiseau 0
let coutReseau 0
ask patch1 [
set cout1 distance patch2 * item csp item typeTransport listCoutDistance +  (distance patch2 / item typeTransport listSpeed) * item csp listValeursTemps
set dist1 distance patch2
set distOiseau dist1
set coutOiseau cout1
]

let i 0

let distTempOiseau 0
let distTempReseau 0
let timeTempOiseau 0
let timeTempReseau 0
let coutTempOiseau 0
let coutTempReseau 0
let coutTemp 0
let temptemp 0
let distMin dist1
let distOiseauA 0
let distReseauA 0
let coutOiseauA 0
let coutReseauA 0
while [i < length [item typeTransport listNoeuds] of patch1] [
let j 0

  ;;;;;;;;;;;;show "je fais dijkstra � partir de"
  ;;;;;;;;;;;;show item i [listNoeuds] of patch1
  dijkstra item i [item typeTransport listNoeuds] of patch1 typeTransport
  
  while [j <  length [item typeTransport listNoeuds] of patch2] [ 
  set distTempOiseau 0
  set distTempReseau 0
  set timeTempOiseau 0
  set timeTempReseau 0  
  set coutTempOiseau 0
  set coutTempReseau 0
  set coutTemp 0
  ;;;;;;;;;;;;show "je trouve la distance suivante"
    ask patch1 [
      set temptemp (distance item i [item typeTransport listNoeuds] of patch1)
      set distTempOiseau distTempOiseau + temptemp
      set timeTempOiseau timeTempOiseau + temptemp / item typeTransport listSpeed
    ]
    ;ask patch1 [set distTemp distTemp + (distance item i [listNoeuds] of patch1)]
    ;;;;;;;;;;;;show distTemp
    ask patch2 [
      set temptemp (distance item j [item typeTransport listNoeuds] of patch2)
      set distTempOiseau distTempOiseau + temptemp
      set timeTempOiseau timeTempOiseau + temptemp / item typeTransport listSpeed      
      ]
    ;ask patch2 [set distTemp distTemp + (distance item j [listNoeuds] of patch2)]
    ;;;;;;;;;;;;show distTemp
   ;;;;;;;;;;;;;;;show distTemp
   ;;;;;;;;;;;;show item j [listNoeuds] of patch2
   ; � ce stade distTemp est la distance "vol d'oiseau": il faut stocker cela!!!
   set coutTempOiseau distTempOiseau * item csp item typeTransport listCoutDistance + timeTempOiseau * item csp listValeursTemps
   ;BALISE
   
    set timeTempReseau [time-to-root] of item j [item typeTransport listNoeuds] of patch2
    set distTempReseau [dist-to-root] of item j [item typeTransport listNoeuds] of patch2
    set coutTempReseau distTempReseau * item csp item typeTransport listCoutDistance + timeTempReseau * item csp listValeursTemps
    set coutTemp coutTempReseau + coutTempOiseau
  ;;;;;;;;;;;;show distTemp
    ;;;;;;;;;;;;show "� comparer avec la distance euclidienne"
    ;;;;;;;;;;;;show dist
    if coutTemp < coutMin [
    set coutMin coutTemp
    set distMin (distTempReseau + distTempOiseau)
    set distOiseauA distTempOiseau
    set distReseauA distTempReseau
    set coutOiseauA coutTempOiseau
    set coutReseauA coutTempReseau    
    
    
;    ;;;;;;;;;;;show "noeud entr�e"
;    ;;;;;;;;;;;show item i [listNoeuds] of patch1
;    ;;;;;;;;;;;show "noeud sortie"
;    ;;;;;;;;;;;show item j [listNoeuds] of patch2
;    
    set cheminTemp [path] of item j [item typeTransport listNoeuds] of patch2
 ;   ;;;;;;;;;;;show cheminTemp
    ]
    
  set j j + 1]
set i i + 1]



;;;;;;;;;;;;;;;;;show nodes1
;;;;;;;;;;;;;;;;;show nodes2
;]
;;;;;;;;;;;;;show dist
;;;;;;;;;;;;;show distanceMin
if coutMin < cout1 [
set cout1 coutMin
set dist1 distMin

set distOiseau distOiseauA
set distReseau distReseauA
set coutOiseau coutOiseauA
set coutReseau coutReseauA

]

set cheminTemp fput cout1 cheminTemp
set cheminTemp fput dist1 cheminTemp;AVERIFIER
set cheminTemp fput coutReseau cheminTemp
set cheminTemp fput coutOiseau cheminTemp
set cheminTemp fput distReseau cheminTemp
set cheminTemp fput distOiseau cheminTemp

report cheminTemp
end




to updateLinksSpeed 
ask links [
  let temp utilisation_l + utilisation_temp
  ifelse  temp > 0 [
  set speed_l speed_empty_l / (1 + 10 * exp(2 * ln(temp / capacity_l)))
  ][
  set speed_l speed_empty_l 
  ]
]
end

to displayActifs

let i 0

while [i < length listPatchesRegion] [
ask item i listPatchesRegion [
set plabel word "a-" int (sum [ listAnbrM] of item i listPatchesRegion + sum [listAnbrR] of item i listPatchesRegion)  
]
set i i + 1
]

end

to displayEmplois

let i 0

while [i < length listPatchesRegion] [
ask item i listPatchesRegion [
set plabel word  "e-" ( int (sum [ listEnbr] of item i listPatchesRegion))
]
set i i + 1
]

end



to showTempsMoyen
ask patches [

let temp 0

let m 0
while [m < nModes] [
  let c 0
  while [c < nCSP] [
    set temp temp + sum item c item m listCoutTransportEffectif
    set c c + 1
  ]
  set m m + 1

 ]
 set plabel int (100 * temp / (sum listAnbrM + sum listAnbrR)) / 100
]

ask links [set thickness (utilisation_l + utilisation_temp) / 400]

end

to-report CoutMoyenTotal
let result 0
ask patches [

let temp 0

let m 0
while [m < nModes] [
  let c 0
  while [c < nCSP] [
    set temp temp + sum item c item m listCoutTransportEffectif
    set c c + 1
  ]
  set m m + 1

 ]
 set result result + temp
]
report result  / 400000
end


to-report DistMoyenTotal
let result 0
ask patches [

let temp 0

let m 0
while [m < nModes] [
  let c 0
  while [c < nCSP] [
    set temp temp + sum item c item m listDistTransportEffectif
    set c c + 1
  ]
  set m m + 1

 ]
 set result result + temp
]
report result  / 400000
end

@#$#@#$#@
GRAPHICS-WINDOW
19
10
285
297
-1
-1
64.0
1
10
1
1
1
0
0
0
1
0
3
0
3
0
0
1
ticks
30.0

BUTTON
628
267
698
300
setup
initRegion
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
702
268
773
301
go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
653
386
754
419
displayActifs
displayActifs
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
647
427
733
460
displayEmplois
displayEmplois
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
628
10
788
130
accessibiliteTicks
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" ""

SLIDER
625
345
797
378
probaLocal
probaLocal
0
100
25
1
1
NIL
HORIZONTAL

BUTTON
631
474
789
507
showTempsMoyen
showTempsMoyen
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
628
130
788
250
tempsTransport
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" ""

BUTTON
904
275
1014
308
utilisationLinks
let rand random 1\nask links [\nifelse rand = 0 [\nset thickness (utilisation_l + utilisation_temp) / 10000\n][\nset thickness 0\n]\n]
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
914
232
1084
265
showAccessibilitePatches
ask patches [\nset plabel int (sum accessibilitePonderee self)\n]
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
853
388
988
421
showUtiliteActifs
ask patches [\nset plabel int (100 * sum listAutiliteR) / 100\n]
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
872
17
967
62
sommePatches
sum [plabel] of patches
17
1
11

BUTTON
819
128
898
161
NIL
land-use
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
814
88
897
121
NIL
transport
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
814
171
926
204
NIL
gouvernement
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
915
330
1023
363
NIL
updateUtilites
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
852
424
984
457
showUtiliteEmplois
ask patches [\nset plabel int (100 * sum listEutiliteR) / 100\n]
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
995
388
1127
421
showdensiteActifs
ask patches [\nset plabel int sum listDensiteActifs\n\n]
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
994
426
1136
459
showDensiteEmplois
ask patches [\nset plabel int sum listDensiteEmplois\n\n]
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
648
611
820
644
parametreDispersion
parametreDispersion
0
1
1
0.1
1
NIL
HORIZONTAL

SLIDER
648
644
832
677
parametrePolycentrisme
parametrePolycentrisme
0
2
1.5
0.1
1
NIL
HORIZONTAL

SLIDER
648
676
832
709
parametreRatDispersion
parametreRatDispersion
0
2
0.5
0.1
1
NIL
HORIZONTAL

INPUTBOX
836
612
991
672
parAct
1
1
0
Number

INPUTBOX
836
677
991
737
parEmp
1
1
0
Number

SLIDER
648
709
829
742
parametreCoutDistance
parametreCoutDistance
0
2
1.35
0.1
1
NIL
HORIZONTAL

OUTPUT
1125
10
1394
365
10

CHOOSER
1028
10
1120
55
log-level
log-level
"debug" "default"
0

@#$#@#$#@
## WHAT IS IT?

LUTI model coupled with governance-based transportation network growth.


## HOW IT WORKS



## ARCHITECTURE

Sketch of global archi :


## HOW TO USE IT


## THINGS TO NOTICE


## THINGS TO TRY


## EXTENDING THE MODEL


## RELATED MODELS


## CREDITS AND REFERENCES

© F Le Nechet, J Raimbault 2015
Licensed under CC-BY-NC-SA 4.0.
See licence in model repository.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 5.1.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="experiment" repetitions="1" runMetricsEveryStep="true">
    <setup>;; (for this model to work with NetLogo's new plotting features,
  ;; __clear-all-and-reset-ticks should be replaced with clear-all at
  ;; the beginning of your setup procedure and reset-ticks at the end
  ;; of the procedure.)
  __clear-all-and-reset-ticks
initRegion</setup>
    <go>transport</go>
    <exitCondition>ticks = 1</exitCondition>
    <metric>distMoyenTotal</metric>
    <metric>coutMoyenTotal</metric>
    <enumeratedValueSet variable="parametreDispersion">
      <value value="0.5"/>
    </enumeratedValueSet>
    <steppedValueSet variable="parametrePolycentrisme" first="0" step="0.1" last="1.5"/>
    <enumeratedValueSet variable="parametreRatDispersion">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="parametreCoutDistance">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="parAct">
      <value value="1111"/>
      <value value="1234"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="parEmp">
      <value value="1111"/>
      <value value="1234"/>
      <value value="2341"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment" repetitions="1" runMetricsEveryStep="true">
    <setup>;; (for this model to work with NetLogo's new plotting features,
  ;; __clear-all-and-reset-ticks should be replaced with clear-all at
  ;; the beginning of your setup procedure and reset-ticks at the end
  ;; of the procedure.)
  __clear-all-and-reset-ticks
initRegion</setup>
    <go>transport</go>
    <exitCondition>ticks = 1</exitCondition>
    <metric>distMoyenTotal</metric>
    <metric>coutMoyenTotal</metric>
    <enumeratedValueSet variable="parametreDispersion">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="parametrePolycentrisme">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="parametreRatDispersion">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="parametreCoutDistance">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="parAct">
      <value value="1111"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="parEmp">
      <value value="1111"/>
      <value value="1234"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experimentNew" repetitions="1" runMetricsEveryStep="true">
    <setup>;; (for this model to work with NetLogo's new plotting features,
  ;; __clear-all-and-reset-ticks should be replaced with clear-all at
  ;; the beginning of your setup procedure and reset-ticks at the end
  ;; of the procedure.)
  __clear-all-and-reset-ticks
initRegion</setup>
    <go>transport</go>
    <exitCondition>ticks = 1</exitCondition>
    <metric>distMoyenTotal</metric>
    <metric>coutMoyenTotal</metric>
    <enumeratedValueSet variable="parametreDispersion">
      <value value="1"/>
    </enumeratedValueSet>
    <steppedValueSet variable="parametrePolycentrisme" first="0" step="0.5" last="1"/>
    <enumeratedValueSet variable="parametreRatDispersion">
      <value value="0.5"/>
    </enumeratedValueSet>
    <steppedValueSet variable="parametreCoutDistance" first="0" step="1" last="1"/>
    <enumeratedValueSet variable="parAct">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="parEmp">
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experimentTYPE1" repetitions="1" runMetricsEveryStep="true">
    <setup>;; (for this model to work with NetLogo's new plotting features,
  ;; __clear-all-and-reset-ticks should be replaced with clear-all at
  ;; the beginning of your setup procedure and reset-ticks at the end
  ;; of the procedure.)
  __clear-all-and-reset-ticks
initRegion</setup>
    <go>transport</go>
    <exitCondition>ticks = 1</exitCondition>
    <metric>distMoyenTotal</metric>
    <metric>coutMoyenTotal</metric>
    <enumeratedValueSet variable="parametreDispersion">
      <value value="1"/>
    </enumeratedValueSet>
    <steppedValueSet variable="parametrePolycentrisme" first="0" step="0.15" last="1.5"/>
    <enumeratedValueSet variable="parametreRatDispersion">
      <value value="0.5"/>
    </enumeratedValueSet>
    <steppedValueSet variable="parametreCoutDistance" first="0" step="0.2" last="1"/>
    <enumeratedValueSet variable="parAct">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="parEmp">
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experimentTYPE2" repetitions="1" runMetricsEveryStep="true">
    <setup>;; (for this model to work with NetLogo's new plotting features,
  ;; __clear-all-and-reset-ticks should be replaced with clear-all at
  ;; the beginning of your setup procedure and reset-ticks at the end
  ;; of the procedure.)
  __clear-all-and-reset-ticks
initRegion</setup>
    <go>transport</go>
    <exitCondition>ticks = 1</exitCondition>
    <metric>distMoyenTotal</metric>
    <metric>coutMoyenTotal</metric>
    <enumeratedValueSet variable="parametreDispersion">
      <value value="1"/>
    </enumeratedValueSet>
    <steppedValueSet variable="parametrePolycentrisme" first="0" step="0.15" last="1.5"/>
    <enumeratedValueSet variable="parametreRatDispersion">
      <value value="0.5"/>
    </enumeratedValueSet>
    <steppedValueSet variable="parametreCoutDistance" first="0" step="0.2" last="1"/>
    <enumeratedValueSet variable="parAct">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="parEmp">
      <value value="2"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experimentDISPERSION" repetitions="1" runMetricsEveryStep="true">
    <setup>;; (for this model to work with NetLogo's new plotting features,
  ;; __clear-all-and-reset-ticks should be replaced with clear-all at
  ;; the beginning of your setup procedure and reset-ticks at the end
  ;; of the procedure.)
  __clear-all-and-reset-ticks
initRegion</setup>
    <go>transport</go>
    <exitCondition>ticks = 1</exitCondition>
    <metric>distMoyenTotal</metric>
    <metric>coutMoyenTotal</metric>
    <steppedValueSet variable="parametreDispersion" first="0.1" step="0.1" last="1.5"/>
    <enumeratedValueSet variable="parametrePolycentrisme">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="parametreRatDispersion">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="parametreCoutDistance">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="parAct">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="parEmp">
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experimentTYPE2-addon" repetitions="1" runMetricsEveryStep="true">
    <setup>;; (for this model to work with NetLogo's new plotting features,
  ;; __clear-all-and-reset-ticks should be replaced with clear-all at
  ;; the beginning of your setup procedure and reset-ticks at the end
  ;; of the procedure.)
  __clear-all-and-reset-ticks
initRegion</setup>
    <go>transport</go>
    <exitCondition>ticks = 1</exitCondition>
    <metric>distMoyenTotal</metric>
    <metric>coutMoyenTotal</metric>
    <enumeratedValueSet variable="parametreDispersion">
      <value value="1"/>
    </enumeratedValueSet>
    <steppedValueSet variable="parametrePolycentrisme" first="0" step="0.15" last="1.5"/>
    <enumeratedValueSet variable="parametreRatDispersion">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="parametreCoutDistance">
      <value value="0.1"/>
      <value value="1.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="parAct">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="parEmp">
      <value value="2"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experimentTYPE1-addon" repetitions="1" runMetricsEveryStep="true">
    <setup>;; (for this model to work with NetLogo's new plotting features,
  ;; __clear-all-and-reset-ticks should be replaced with clear-all at
  ;; the beginning of your setup procedure and reset-ticks at the end
  ;; of the procedure.)
  __clear-all-and-reset-ticks
initRegion</setup>
    <go>transport</go>
    <exitCondition>ticks = 1</exitCondition>
    <metric>distMoyenTotal</metric>
    <metric>coutMoyenTotal</metric>
    <enumeratedValueSet variable="parametreDispersion">
      <value value="1"/>
    </enumeratedValueSet>
    <steppedValueSet variable="parametrePolycentrisme" first="0" step="0.15" last="1.5"/>
    <enumeratedValueSet variable="parametreRatDispersion">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="parametreCoutDistance">
      <value value="0.1"/>
      <value value="1.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="parAct">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="parEmp">
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experimentTYPE1-short" repetitions="1" runMetricsEveryStep="true">
    <setup>;; (for this model to work with NetLogo's new plotting features,
  ;; __clear-all-and-reset-ticks should be replaced with clear-all at
  ;; the beginning of your setup procedure and reset-ticks at the end
  ;; of the procedure.)
  __clear-all-and-reset-ticks
initRegion</setup>
    <go>transport</go>
    <exitCondition>ticks = 1</exitCondition>
    <metric>distMoyenTotal</metric>
    <metric>coutMoyenTotal</metric>
    <enumeratedValueSet variable="parametreDispersion">
      <value value="1"/>
    </enumeratedValueSet>
    <steppedValueSet variable="parametrePolycentrisme" first="0" step="0.5" last="1.5"/>
    <enumeratedValueSet variable="parametreRatDispersion">
      <value value="0.5"/>
    </enumeratedValueSet>
    <steppedValueSet variable="parametreCoutDistance" first="0" step="1" last="1"/>
    <enumeratedValueSet variable="parAct">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="parEmp">
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experimentTYPE1-medium" repetitions="1" runMetricsEveryStep="true">
    <setup>;; (for this model to work with NetLogo's new plotting features,
  ;; __clear-all-and-reset-ticks should be replaced with clear-all at
  ;; the beginning of your setup procedure and reset-ticks at the end
  ;; of the procedure.)
  __clear-all-and-reset-ticks
initRegion</setup>
    <go>transport</go>
    <exitCondition>ticks = 1</exitCondition>
    <metric>distMoyenTotal</metric>
    <metric>coutMoyenTotal</metric>
    <enumeratedValueSet variable="parametreDispersion">
      <value value="1"/>
    </enumeratedValueSet>
    <steppedValueSet variable="parametrePolycentrisme" first="0" step="0.3" last="1.5"/>
    <enumeratedValueSet variable="parametreRatDispersion">
      <value value="0.5"/>
    </enumeratedValueSet>
    <steppedValueSet variable="parametreCoutDistance" first="0" step="0.15" last="0.9"/>
    <enumeratedValueSet variable="parAct">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="parEmp">
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experimentTYPE1-medium-addon" repetitions="1" runMetricsEveryStep="true">
    <setup>;; (for this model to work with NetLogo's new plotting features,
  ;; __clear-all-and-reset-ticks should be replaced with clear-all at
  ;; the beginning of your setup procedure and reset-ticks at the end
  ;; of the procedure.)
  __clear-all-and-reset-ticks
initRegion</setup>
    <go>transport</go>
    <exitCondition>ticks = 1</exitCondition>
    <metric>distMoyenTotal</metric>
    <metric>coutMoyenTotal</metric>
    <enumeratedValueSet variable="parametreDispersion">
      <value value="1"/>
    </enumeratedValueSet>
    <steppedValueSet variable="parametrePolycentrisme" first="0" step="0.3" last="1.5"/>
    <enumeratedValueSet variable="parametreRatDispersion">
      <value value="0.5"/>
    </enumeratedValueSet>
    <steppedValueSet variable="parametreCoutDistance" first="1.05" step="0.15" last="1.35"/>
    <enumeratedValueSet variable="parAct">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="parEmp">
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experimentTYPE2-medium" repetitions="1" runMetricsEveryStep="true">
    <setup>;; (for this model to work with NetLogo's new plotting features,
  ;; __clear-all-and-reset-ticks should be replaced with clear-all at
  ;; the beginning of your setup procedure and reset-ticks at the end
  ;; of the procedure.)
  __clear-all-and-reset-ticks
initRegion</setup>
    <go>transport</go>
    <exitCondition>ticks = 1</exitCondition>
    <metric>distMoyenTotal</metric>
    <metric>coutMoyenTotal</metric>
    <enumeratedValueSet variable="parametreDispersion">
      <value value="1"/>
    </enumeratedValueSet>
    <steppedValueSet variable="parametrePolycentrisme" first="0" step="0.3" last="1.5"/>
    <enumeratedValueSet variable="parametreRatDispersion">
      <value value="0.5"/>
    </enumeratedValueSet>
    <steppedValueSet variable="parametreCoutDistance" first="0" step="0.15" last="1.35"/>
    <enumeratedValueSet variable="parAct">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="parEmp">
      <value value="2"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

ligne
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0

rail
0.0
-0.2 0 0.0 1.0
0.0 0 0.0 1.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 45 150 255
Line -7500403 true 135 225 165 225
Line -7500403 true 135 195 165 195
Line -7500403 true 135 165 165 165
Line -7500403 true 135 135 165 135
Line -7500403 true 135 105 165 105
Line -7500403 true 135 75 165 75

route
0.0
-0.2 0 0.0 1.0
0.0 0 0.0 1.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 135 45 135 255
Line -7500403 true 165 45 165 255
Line -7500403 true 135 255 165 255
Line -7500403 true 165 45 135 45
Line -7500403 true 150 255 150 240
Line -7500403 true 150 210 150 225
Line -7500403 true 150 195 150 180
Line -7500403 true 150 165 150 150
Line -7500403 true 150 135 150 120
Line -7500403 true 150 105 150 90
Line -7500403 true 150 75 150 60

@#$#@#$#@
0
@#$#@#$#@
