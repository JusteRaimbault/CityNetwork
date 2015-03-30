
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

  ;; nulber of socio-professional categories
  Ncsp
  
  listNactifs
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
  listcoutDistance ; par csp et par mode; typiquement prix du p�trole, abonnement de carte orange...




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
  has-maire?
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


; emplois are agents
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


  ;;;;;;;;;;
  ;; Fractal network parameters
  ;;;;;;;;;;
  father
  order
  node-id
  distFRACTAL
  radial
  rocade

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
