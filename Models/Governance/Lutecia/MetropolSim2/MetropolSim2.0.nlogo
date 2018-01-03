
;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; MetropolSim 2.0
;;  
;; © F Le Nechet, J Raimbault 2015 ; see License.md.
;;
;;
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;


extensions [nw table profiler]


__includes [
  
  ;; setup
  "setup.nls" 
  
  ;; main
  "main.nls"
  
  ;; transport
  "transport.nls"
  
  ;; land-use
  "land-use.nls"
   
  ;;governement/network evolution
  "governement.nls"
  "infrastructure.nls"
  
  ;; indicators
  "indicators.nls"
  
  ;; display
  "display.nls"
  
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
  "/Users/Juste/Documents/ComplexSystems/Softwares/NetLogo/utils/io/LogUtilities.nls"
  "/Users/Juste/Documents/ComplexSystems/Softwares/NetLogo/utils/misc/List.nls"
  "/Users/Juste/Documents/ComplexSystems/Softwares/NetLogo/utils/gui/PlottingUtilities.nls"
  "/Users/Juste/Documents/ComplexSystems/Softwares/NetLogo/utils/misc/Table.nls"
  
]

globals [
  
  ;parametrePolycentrisme
  ;parAct
  ;parEmp
  ;parametreCoutDistance
  ;parametreDispersion
  ;parametreRatDispersion

  ;; Number of mayors
  Nmaires

  ;; number of socio-professional categories
  Ncsp
  
  listNactifs
  
  ;; number of actives moving at this iteration of land-use algo
  ; @type Int
  moving-actives
  ;;idem employment
  ; @type Int
  moving-employment
  
  ;; List of patches lexicalographically ordered by increasing (xcor,ycor)
  listPatchesRegion
  
  listNbrConnecteurs
  
  listSpeed
  
  ;; number of transportation modes
  Nmodes

  ;; parameter for discrete modal choice ?
  coeffChoixModal
  
  listCarOwnership
  listSalaires
  listcoeffAccessibiliteFormeUrbaineActifs
  listcoeffAccessibiliteFormeUrbaineEmplois
  listcoeffUtilitesActifs
  listcoeffUtilitesEmplois
  
  ;; flow matrices ?
  matActifsActifs
  matActifsEmplois
  matEmploisActifs
  matEmploisEmplois
  

  ;;;;;;;;;;;;;;;;;;;
  ;; fractal network parameters
  ;;;;;;;;;;;;;;;;;;;
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


  ;;;;;;;;;;;;;;;;;;;
  ;; initial population distribution parameters
  ;;;;;;;;;;;;;;;;;;;
  listActBussA
  listActBussb
  listEmpBussA
  listEmpBussb


  ;;;;;;;;;;;;;;;;;;;
  ; Finer description of transportation costs
  ;;;;;;;;;;;;;;;;;;;

  ; value of time for each csp
  listvaleursTemps
  
  ;;
  ; Transportations costs per CSP and transportation mode
  ;  typically vary : gaz prices, public transportation price
  listcoutDistance




  resultatCout
  resultatDist
 

  ;; utils vars
  ;log-level  ;; -> added as chooser in interface


  ;; Network variables
  ;; Caches for shortest path computation
  
  cached-nw-distances
  cached-nw-times
  cached-nw-paths

]



breed [maires maire]
breed [regions region]
breed [actifs actif]
breed [emplois emploi]
breed [chemins chemin]
breed [nodes node]



patches-own [
  
  ;;
  ; Is there a mayor here ?
  ;  @type boolean
  ;;
  has-maire?
  
  ;;
  ; Mayor ruling this patch
  ;  @type turtle(maire)
  ;;
  mairePatch
  
  
  ;;
  ; Utility of actives per CSP for this patch
  ;  see land-use.mouvementActifs , 
  ;  @type List_csp<Double>
  ;;
  list-A-utilite-R
  
  ;;
  ; See list-A-utilite-R
  ;  same for other category ; NOT USED
  ;;
  list-A-utilite-M
  
  
  ;;
  ; Utility of actives per CSP for this patch
  ;  see land-use.mouvementActifs , 
  ;  @type List_csp<Double>
  ;;
  list-E-utilite-R
  
  ;;
  ; See list-E-utilite-R
  ;  same for other category ; NOT USED
  ;;
  list-E-utilite-M
  
  
  ;;
  ; Number of actives (residents ?) for each CSP
  ;  @type List<Int>
  ;;
  list-A-nbr-R
  
  ;;
  ; Number of actives (mobiles ?) for each CSP
  ;  - NOT USED FOR NOW -
  ;  @type List<Int>
  ;;
  list-A-nbr-M
  
  ;;
  ; Number of jobs
  ; @type Int
  ;;
  list-E-nbr
  
  dist-to-patch
  
  ;;
  ; Transportation costs, from this patch to all patches (indexed by order in global patch list) by mode and CSP
  ;  @type List_mode<List_csp<List_patch>>
  ;;
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
  
  ;;
  ; Accessibility of the patch for each CSP
  ; @type List_csp<Double>
  ;;
  accessibilitePatches
  
  ;accessibilitePatchesTemp
  listAccessibilitesPatches
  ;listAccessibilitesPatchesTemp
  listNavettesPatches
  listModesShare
  listNavettesModes
  listDensiteEmplois
  listDensiteActifs
  
  ;;
  ; Is there a node here ?
  ;;
  has-node?
  
  ;; Display parameters
  
  ;;
  ; coloring variable
  coloring-variable
  
]




maires-own [
  
  centreMaire

  ;; Bussiere Parameters used to initialize
  listA-AbussiereInit ; (actifs)
  listA-bbussiereInit ; (emplois)
  listE-AbussiereInit ; (actifs)
  listE-bbussiereInit ; (emplois) 

  listPatchesMaire
  
  ;; wealth of governed zone
  budget
  
  ;; boundary params for uniform random drawing ?
  money-
  money+
]


actifs-own [
  cspActif
  ageActif
  emploiActif
]


; emplois are agents ?
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
  connection
  tempNode?


  ;;;;;;;;;;
  ;; Dijkstra algo params
  ;;;;;;;;;;
  assigned? ; pour dijkstra
  final? ; pour dijkstra
  dist-to-root ; pour dijkstra
  time-to-root ; pour dijkstra
  path ; pour dijkstra


  ;;;;;;;;;;
  ;; Fractal network parameters
  ;;;;;;;;;;
  father
  order
  node-id
  distFRACTAL
  radial
  rocade
  
  ;;;;
  ;; Dijstktra replacement variables
  ;;

  ;; DEPRECATED : global vars
  ;; cached nw distances, same order as listNoeuds of destination patch
  ;cached-nw-distances  
  ;; idem for nw times
  ;cached-nw-times  
  ;; and paths
  ;cached-nw-paths

]


links-own [
  
  ;; speed in link
  speed_l
  
  capacity_l
  
  waitTime
  
  ;; transportation type
  typeLink
  
  ;; temporary link ? (used for best link research)
  tempLink?
  
  utilisation_l
  utilisation_temp
  speed_empty_l
  scale_l
  
  ;;;;
  ;; Dijstktra replacement variables
  ;;
  
  ;; length of the link, used for weighted shortest path algo
  transportation-link-length
  
]

















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
573
10
643
43
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
646
10
717
43
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
572
381
673
414
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
572
417
672
450
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
10
464
170
584
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
575
84
698
117
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
676
382
788
415
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
10
585
170
705
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
573
453
683
486
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
675
417
829
450
showAccessibilitePatches
ask patches [\n  set plabel int (sum accessibilitePonderee self)\n]
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
574
310
681
343
showUtiliteActifs
ask patches [\nset plabel int (100 * sum list-A-utilite-R) / 100\n]
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
273
417
355
462
sommePatches
sum [plabel] of patches
17
1
11

BUTTON
572
181
651
214
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
572
147
655
180
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
653
181
741
214
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
656
147
741
180
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
573
346
684
379
showUtiliteEmplois
ask patches [\nset plabel int (100 * sum list-E-utilite-R) / 100\n]
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
685
310
794
343
showdensiteActifs
ask patches [\n  set plabel int sum listDensiteActifs\n]
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
687
346
806
379
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
771
46
930
79
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
771
79
930
112
parametrePolycentrisme
parametrePolycentrisme
0
2
2
0.1
1
NIL
HORIZONTAL

SLIDER
771
111
930
144
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
933
47
985
107
parAct
3
1
0
Number

INPUTBOX
933
110
985
170
parEmp
3
1
0
Number

SLIDER
771
144
930
177
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
1020
58
1400
413
10

CHOOSER
1020
10
1112
55
log-level
log-level
"debug" "default"
0

TEXTBOX
771
26
921
44
Setup Params
11
0.0
1

TEXTBOX
575
60
725
78
Runtime Params
11
0.0
1

TEXTBOX
574
242
724
260
Display
11
0.0
1

MONITOR
10
416
60
461
links
count links
17
1
11

PLOT
1023
423
1183
579
profiler
NIL
NIL
0.0
10.0
0.0
10.0
false
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" ""

PLOT
177
465
354
615
land-use conv
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
"actives" 1.0 0 -14439633 true "" ""
"employment" 1.0 0 -5825686 true "" ""

CHOOSER
575
261
667
306
patch-color
patch-color
"none" "utility-A" "utility-E" "nbr-A" "nbr-E"
3

MONITOR
62
416
112
461
nodes
count nodes
17
1
11

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
