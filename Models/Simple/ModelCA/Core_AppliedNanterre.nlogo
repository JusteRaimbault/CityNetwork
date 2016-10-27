;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Urban configuration optimization with CA
;;
;; v2
;; - more flexible implementation ?
;; - hybrid coupling with dynamic ABM
;;
;; --> Precise more motivations and frame of use. Check for justification of use in the litterature; epsitemological fwk is one of the key
;; --> clean code and make ir run faster.
;;
;;
;;
;;
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



extensions[nw table gis profiler context matrix convol]


__includes[
  
  ;;main functions
  "main.nls"
  
  ;;setup functions for CA-Network
  "setupCA.nls"
  
  ;;patches procedures
  "patches.nls"
  
  ;;Evolutive ABM (economic evaluation)
  "economicABM.nls"
  
  ;;Basic evaluation functions
  "evaluation.nls"
  
  ;;application and exploration of the model
  "application.nls"
  "exploration.nls"
  
  ;;display functions
  "display.nls"
  
  
  ;;Utilities
  "utils/List.nls"
  "utils/EuclidianDistanceUtilities.nls"
  "utils/SpatialKernels.nls"
  "utils/Types.nls"
  "utils/Link.nls"  
  "utils/SortingUtilities.nls"
  "utils/File.nls"
  "utils/String.nls"
  
  ;;core running file
  "genetic-optim.nls"
  
]


globals[
  
  ;;;;;;;;;;;;;;
  ;; Rq : all globals including slider vars are listed here for comprehension purposes
  ;; vars in sliders are commented of course
  ;;;;;;;;;;;;;;
  
  
  ;;;;;;;;;;;;;
  ;; Core parameters
  ;;;;;;;;;;;;;
  
  ;distance-to-activities-coefficient
  ;density-coefficient
  ;distance-to-roads-coeficient
  
  
  ;;;;;;;;;;;;;;
  ;; GIS Configuration
  ;;;;;;;;;;;;;;
  centers-gis-layer
  paths-gis-layer
  
  
  ;;;;;;;;;;;;;
  ;;globals for dynamical ABM
  ;;;;;;;;;;;;;
  
  ;rent-update-radius
  mean-economic-value
  sigma-wealth
  ;move-threshold
  new-incomers-number
  
  ;;updated lists of available places
  ;;(efficiency purposes)
  available-houses
  
  ;;max number of ticks for convergence of economic ABM
  ;;Has to be fixed by experience !
  max-ticks-economic
  
  ;;;;;;;;;;;;;
  ;;globals for other evaluation functions
  ;;;;;;;;;;;;;
  moran-grid-size
  moran-populations
  
  ;;bounds as variables for efficiency purposes
  density-max
  density-min
  distance-to-roads-max
  distance-to-roads-min
  distance-to-centre-max
  distance-to-centre-min
  distance-to-activities-max
  distance-to-activities-min
  dmax
  
  
  ;;;;;;;;;;;;;
  ;; Globals for exploration of configurations
  ;;;;;;;;;;;;;
  
  ;;current points in the pareto plot
  ;;initialised and used iff config-comparison? == true
  pareto-points
  
  
  
  ;;;;;;;;;;;;;;
  ;; Runtime vars
  ;;;;;;;;;;;;;
  
  ;;time profile spent in go at each tick
  current-time-spent
  
  ;;tracker
  tracker-time
  
  ;;output-file
  output-file-name
  output-reporter-names
  
  ;;monitor economic times series?
  ;;(used to assess convergence of indicators)
  ;;gives too huge files ?
  ;monitor-economic?
  ;;since monitoring is done inside running of the model, we need a global var for output list
  current-output-conf-economic
  
  
  data-to-export
  data-export-patches
  
  config-name
  
  ;;;;;;;;;;;;;;;
  ;; GA vars
  ;;;;;;;;;;;;;;;
  
  area-number
  
  area-layer
  
  ;;crossing heuristic vars
  ;dmin-centers
  ;max-n-out-links
  
  evaluation-table
  best-confs
  
  
]

;;;;;;;;;;;;;;;;
;; GA breeds
;;;;;;;;;;;;;;;;

;;utils for crossing heuristic
breed[crossing-centres crossing-centre]
undirected-link-breed[crossing-paths crossing-path]


;;points of interest in the city
;;each is supposed to have an activity ?
breed[centres centre]

;;houses
;;really useful, since it is coupled with patch construction ?
breed[houses house]


;;network nodes
breed[intersections intersection]
;;network links
undirected-link-breed [paths path]





patches-own[
  
  ;;is the patch constructed ?
  constructed?
  
  ;;can it be contructed? (no road or no center)
  ;;-> when a new road is constructed, destroy old ones and set not constructible
  constructible?
  
  ;;objective value of the patch and associated internediate variables
  value
  pdensity
  pdistance-to-roads
  pdistance-to-centre
  pspeed-from-patch
  pdistance-to-activities
  
  ;;dynamic economic value (will be seen as a "rent")
  ;;for ABM economic evaluation
  rent
  next-rent

  ;; smoothed vars
  smoothed-density

]



centres-own[
  
  ;;integer representing the activity of the center
  activity 
  
  ;;The numerotation of centers is used during optimisation configuration
  ;;to make correspond place in conf to the good center
  ;;only centers with a!=0 are numeroted
  ;;because we optimise with a fixed activity
  number
  
  net-d-to-centre
  net-d-to-activities
]



intersections-own[
  ;;cache variable for network distances
  net-d-to-centre ;scalar
  net-d-to-activities ;list:index i is activity i
]

paths-own [
  path-length
  
  ;;additional bool for GA : internal paths need to be differentiated from boundaries
  internal?  
]
@#$#@#$#@
GRAPHICS-WINDOW
529
23
971
486
27
27
7.857142857142857
1
10
1
1
1
0
0
0
1
-27
27
-27
27
1
1
1
ticks
30.0

SLIDER
7
28
102
61
worldwidth
worldwidth
1
200
55
1
1
NIL
HORIZONTAL

BUTTON
376
25
442
58
NIL
setup
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
5
63
142
96
centers-number
centers-number
1
20
1
1
1
NIL
HORIZONTAL

SLIDER
349
126
493
159
neighborhood-radius
neighborhood-radius
1
10
5
1
1
NIL
HORIZONTAL

SLIDER
49
364
224
397
density-coefficient
density-coefficient
0
1
0.7
0.1
1
NIL
HORIZONTAL

SLIDER
50
404
224
437
distance-to-roads-coefficient
distance-to-roads-coefficient
0
1
0
0.1
1
NIL
HORIZONTAL

SLIDER
50
445
224
478
distance-to-center-coefficient
distance-to-center-coefficient
0
1
1
0.1
1
NIL
HORIZONTAL

SLIDER
349
89
511
122
distance-road-needed
distance-road-needed
0
50
2.2
0.1
1
NIL
HORIZONTAL

SLIDER
349
162
491
195
built-cells-per-tick
built-cells-per-tick
0
100
10
1
1
NIL
HORIZONTAL

BUTTON
449
25
512
58
go
go\nset current-time-spent profiler:inclusive-time \"go\"
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
1312
10
1366
55
houses
count houses
5
1
11

MONITOR
1372
11
1422
56
roads
count links
17
1
11

PLOT
1316
61
1476
181
patches values
ticks
values
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot mean [value] of patches"
"pen-1" 1.0 0 -7500403 true "" "plot max [value] of patches"
"pen-2" 1.0 0 -2674135 true "" "plot min [value] of patches"

SLIDER
6
97
142
130
activities-number
activities-number
0
10
1
1
1
NIL
HORIZONTAL

SLIDER
50
322
225
355
distance-to-activities-coefficient
distance-to-activities-coefficient
0
1
0
0.1
1
NIL
HORIZONTAL

SLIDER
349
197
499
230
activities-norma
activities-norma
-1
20
4
1
1
NIL
HORIZONTAL

PLOT
864
505
1024
625
Calc time
ticks
time
0.0
10.0
0.0
3.0
true
false
"" ""
PENS
"default" 1.0 0 -10022847 true "" "plot current-time-spent / 1000"
"pen-1" 1.0 0 -15040220 true "" "plot profiler:inclusive-time \"sprawl\" / 1000"
"pen-2" 1.0 0 -14985354 true "" "plot profiler:inclusive-time \"go\" / 1000"

SWITCH
5
166
146
199
config-from-file?
config-from-file?
1
1
-1000

SLIDER
293
303
391
336
p-speed
p-speed
1
100
1
1
1
NIL
HORIZONTAL

SLIDER
104
29
196
62
max-ticks
max-ticks
1
500
10
1
1
NIL
HORIZONTAL

SWITCH
7
131
143
164
config-comparison?
config-comparison?
1
1
-1000

SLIDER
394
267
486
300
p-density
p-density
1
50
3
1
1
NIL
HORIZONTAL

SLIDER
293
267
391
300
p-activities
p-activities
1
50
3
1
1
NIL
HORIZONTAL

PLOT
987
13
1147
133
local densities
NIL
NIL
0.0
10.0
0.0
0.1
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot mean [pdensity] of patches"
"pen-1" 1.0 0 -7500403 true "" "plot min [pdensity] of patches"
"pen-2" 1.0 0 -2674135 true "" "plot max [pdensity] of patches"

PLOT
1148
13
1308
133
d to roads
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
"default" 1.0 0 -16777216 true "" "plot mean [pdistance-to-roads] of patches"
"pen-1" 1.0 0 -7500403 true "" "plot min [pdistance-to-roads] of patches"
"pen-2" 1.0 0 -2674135 true "" "plot max [pdistance-to-roads] of patches"

BUTTON
19
513
90
546
NIL
setup-ABM
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
20
551
89
584
go ABM
go-one-step-ABM
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
94
514
221
547
move-threshold
move-threshold
0
1
0.6
0.02
1
NIL
HORIZONTAL

SLIDER
95
552
269
585
rent-update-radius
rent-update-radius
0
30
10
1
1
NIL
HORIZONTAL

BUTTON
292
25
355
58
clear
clear
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
864
628
914
673
tracker
tracker-time * 1000 / (profiler:inclusive-time \"go\")
5
1
11

PLOT
987
135
1147
255
distance to centres
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
"default" 1.0 0 -16777216 true "" "plot mean [pdistance-to-centre] of patches"
"pen-1" 1.0 0 -7500403 true "" "plot min [pdistance-to-centre] of patches"
"pen-2" 1.0 0 -2674135 true "" "plot max [pdistance-to-centre] of patches"

PLOT
1148
135
1308
255
accessibility of activities
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
"default" 1.0 0 -16777216 true "" "plot mean [pdistance-to-activities] of patches"
"pen-1" 1.0 0 -7500403 true "" "plot min [pdistance-to-activities] of patches"
"pen-2" 1.0 0 -2674135 true "" "plot max [pdistance-to-activities] of patches"

TEXTBOX
83
295
233
313
Weights of variables
11
0.0
1

TEXTBOX
354
69
504
87
Runtime params
11
0.0
1

TEXTBOX
299
249
449
267
Output params
11
0.0
1

TEXTBOX
18
490
168
508
Economic ABM
11
0.0
1

INPUTBOX
150
63
279
123
centers-gis-layer-path
../Data/Algo/centers.shp
1
0
String

INPUTBOX
150
124
279
184
paths-gis-layer-path
../Data/Algo/roads.shp
1
0
String

OUTPUT
493
504
861
709
12

BUTTON
368
507
487
564
Calculate reporters
calculate-reporters
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SWITCH
370
573
485
606
output-file?
output-file?
1
1
-1000

TEXTBOX
38
6
188
24
Setup parameters
11
0.0
1

MONITOR
21
590
92
635
households
count households
17
1
11

MONITOR
94
590
172
635
avail. houses
length available-houses
17
1
11

PLOT
2
638
162
758
total wealth
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
"default" 1.0 0 -16777216 true "" "plot sum [wealth] of households"

SLIDER
394
303
505
336
moran-grid-factor
moran-grid-factor
0
world-width
10
1
1
NIL
HORIZONTAL

SWITCH
179
594
281
627
monitor-economic?
monitor-economic?
0
1
-1000

PLOT
1016
281
1244
490
pareto
economic
accessibility
0.0
1.0
0.0
1.0
false
false
"" ""
PENS
"pen" 1.0 0 -10022847 true "" ""

TEXTBOX
1167
262
1317
280
GA Optim
14
0.0
1

SLIDER
167
638
339
671
n-repets-eco
n-repets-eco
0
10
3
1
1
NIL
HORIZONTAL

TEXTBOX
1098
494
1248
512
GA Optimisation
11
0.0
1

BUTTON
1095
513
1162
546
setup
setup-globals-ga
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
1229
514
1321
547
initial-act-share
initial-act-share
0
1
0.5
0.1
1
NIL
HORIZONTAL

SLIDER
1322
513
1427
546
dmin-centers
dmin-centers
0
10
1.5
0.1
1
NIL
HORIZONTAL

SLIDER
1228
549
1347
582
max-n-out-links
max-n-out-links
0
20
15
1
1
NIL
HORIZONTAL

SLIDER
1229
586
1377
619
max-global-density
max-global-density
0
1
0.2
0.1
1
NIL
HORIZONTAL

MONITOR
1229
622
1291
667
g-density
global-constructible-density
2
1
11

MONITOR
1295
622
1354
667
configs
length table:keys evaluation-table
17
1
11

BUTTON
1095
554
1158
587
run
run-algo
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
1348
549
1440
582
n-random-conf
n-random-conf
0
200
200
1
1
NIL
HORIZONTAL

BUTTON
390
428
493
461
export data
export-data-to-file
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SWITCH
5
204
104
237
headless?
headless?
1
1
-1000

SWITCH
281
340
403
373
export-data?
export-data?
1
1
-1000

SWITCH
404
340
526
373
export-movie?
export-movie?
0
1
-1000

SWITCH
107
204
223
237
fixed-seed?
fixed-seed?
0
1
-1000

SLIDER
4
239
96
272
seed
seed
0
1000000
272727
1
1
NIL
HORIZONTAL

BUTTON
433
376
517
409
close movie
movie-close
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

@#$#@#$#@
# WHAT IS IT?

Hybrid model (CA coupled with evolving network) for Urban configuration optimisation.

# HOW IT WORKS

##Agents and rules

Cells of the automaton (patches) can be occupied or not.
Evolving network is embedded into space.

At each time step:
  - N new cells are constructed according to their updated value, that depend on local density, distance to roads, distance to center and accessibility of activities, each weighted according to parameters <code>__-coefficient</code>
  - network evolves: if a cell is built and network is too far (> fixed param <code>distance-road-needed</code>), it is connected to the network through the shortest path.

Output are not calculated at each time step for efficiency purpose. Button <code>calculate-reporters</code> launch calculation and output in log file if specified.

##Parameters

###Main params
 - Weights of variables: <code>__-coefficient</code> determine respective weight of each var for its influence in the value of cells, ie in urban dev.

###Runtime params
have influence on final form but should be fixed in "normal" run, since have good proxies in real world.
 - <code>distance-road-needed</code> distance over which a new road has to be built for a new cell built
 - <code>neighborhood-radius</code> radius of neigh for eval of density
 - <code>built-cells-per-tick</code> number of new houses per tick. Not really real proxy but sensitivity analysis in paper suggest to take compromise ~ 15
 - <code>activities-norma</code> influence of each respective accessibility in the integrated accessibility. does not change really result, as soon as stays small.

###Output params
 - <code>p-__</code> value of parameter for p-norm used in integration. between 2 and 5 is a good compromise.

###Setup params
 - <code>worldwidth</code> world is square, patch size is calculated in function (window of fixed size)
 - <code>max-ticks</code> param used for run in headless mode, with hand exploration etc.
 - <code>centers-number, activities-number</code> initial number of centers and activities when setup is random (not setup from file)
switch for file input and name of GIS input files are used for concrete application.

###Economic ABM
Hand run of economic eval. see S1 for explanation.


##Evaluation functions

- integrated local density
- Moran index
- network integrated speed
- accessibility of activities
- economic performance

# HOW TO USE IT

##Basic use

Set the weights for the influence of the different variables (distance to centres, to activities, density)
The growing shape (as a sprawl) will strongly depend on these.

##Explorations and Application

###Exploration
Launch core functions by hand. See following for specs.

###Application
Set GIS input file, choose "input from file".
Launch by hand (compare-activities-configurations).
Your GIS file has to contain an "activity field", if == 0, will be fixed activity (in general station), exploration is then done on two other possible activities for the other centres.


#Specifications

##Model exploration
Exploration is not done through BehaviorSpace that is not really practical. Could also use OpenMole but works only for "simple" runs.
We would like to proceed to customized explorations, that are for most sensitiviy analysis, need sometimes customized functions.
  -> generic functions for model exploration (that could become utilities later)
NOTE on format !

Rq: could exploration always be generic and calculation done a posteriori export ? NO in fact since for example with morpho comparison, we need all patch set to compare footprints, what is in fact not reasonably exportable (or could it be ?)





# EXTENDING THE MODEL



##TODO List

###Implementation

dot = TODO, X = done

<ul>
  X more neighboorhood should not be squared OK circular <br/>
  X improve speed of model: heuristic for closest road ! <br/>
  X set random seed as an option !!! Do by hand.<br/>
  X bugs with death of some houses. NO, houses on links have to die. Should not contruct here in fact. --> that was a useful bug ! :: next issue <br/>
  X not construct on roads and center <br/>
  X should centers be ponctuals or spatial ? -> ponctual OK, will consider as an "activity directive for the area" <br/>
  X pb number of centers ? -> kill footprint calculator ! <br/>
  X Setup from gis files (centers and roads !) -> for applications, on real conf ! <br/>
  <li>Should be logic to have an external explicative variable coming from raster GIS file (what would be like elevation etc: pre-existing value). Later for further extensions.</li>
  X ABM: justify convergence and find reasonable outputs. eg time serie of rents distrib (mean,sigma to begin) <br/>


</ul>

###Results

  - classification of shapes: compare to radioconcentrique/ciudad linear
  - revoir application: scale!!! planning of areas and activities

###Exploration/Sensitivity analysis
  - basic exploration with many reporters and morpho !
  - exploration with morpho comparison of continuous/sequential. When looking at shapes obtained for different values, evoques that this parameter should in fact have a strong significance. Ex high value gives a very dense city. (logical)
Look at sensitivity of output regarding this parameter.

  - Q of center number/position -> test with many positions for a given number, how quick does the serie converge? If quick enough then compare number of centers.
--> execution on different conf and different number of centers, with large number (500 should be fine)

  - Convergence of economic ABM : could in fact be the motive of an other paper, really sensitive and seems to need a lot of repets to converge given the structure -> would need to explore in more details for establishing number of repet needed


##Possible future extensions

###From old model

;;add network auto-evolution :: add paths if not direct (eval all x ticks) ; evolve capacity of paths % density and quantity that goes through.

;; multiples centers :: creates independante clusters ; need to force connexion by diversification of activity?

;; irregular grid?? // elevation

###New perspectives

See discussion section of paper.



# RELATED MODELS

See Urban suite integrated in NL and Refs.

# CREDITS AND REFERENCES

##Conception and implementation:
<a href="mailto:juste.raimbault@polytechnique.edu">Juste Raimbault</a>
Dép HSS, Ecole Polytechnique
LVMT, Ecole Nationale des Ponts et Chaussées

##References

See refs in paper.
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

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

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

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

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

@#$#@#$#@
0
@#$#@#$#@
