extensions [table pathdir nw matrix context gradient morphology shell]

;;;;
;; Mesoscopic Co-evolution
;;
;;;;





__includes [

  ;; setup
  "setup.nls"

  ;; main coevol
  "main.nls"

  ;; network growth
  "network.nls"
  ;; heuristics
  "network-euclidian.nls"   ; diverse distance and gravity based heuristic
  "network-heuristic.nls"   ; gravity based empirical heuristic
  "network-biological.nls"  ; biological network growth


  ; cities distribution
  "cities.nls"
  ; density
  "density.nls"

  "patches.nls"



  ;; indicators
  "indicators.nls"


  ;; tests
   "test/test-includes.nls"

   ;; display
   "display.nls"

   ;; experiment
   "experiment.nls"

   ;;;;
   ;; Utils
   ;;;;

   "utils.nls"

   "utils/Network.nls"
   "utils/AgentSet.nls"
   "utils/Statistics.nls"
   "utils/File.nls"
   "utils/List.nls"
   "utils/Link.nls"
   "utils/Agent.nls"
   "utils/String.nls"
   "utils/SpatialKernels.nls"
   "utils/EuclidianDistance.nls"
   "utils/Logging.nls"


]


globals [

  ;;
  ; setup
  setup-rank-size-exp
  setup-max-pop
  setup-center-density
  ;setup-center-number
  setup-outside-links-number
  city-max-pop
  #-cities

  ;; network generation parameters

  max-pop

  ;; cities generation parameters
  populations

  cities-interaction-table

  ;; density generation params
  density-preffatt-total-time-steps
  ;sp-max-pop
  ;population-growth-rate
  ;density-alpha-localization
  ;density-diffusion-steps
  ;density-diffusion

  ; total population
  total-population
  cities-total-population

  ;; from density file (for coupling with scala density generator)
  density-file


  ;; patch explicative variables globals
  patch-population-max
  patch-population-min
  patch-population-share-max
  patch-population-share-min
  patch-distance-to-road-max
  patch-distance-to-road-min
  patch-closeness-centrality-max
  patch-closeness-centrality-min
  patch-bw-centrality-max
  patch-bw-centrality-min
  patch-accessibility-max
  patch-accessibility-min

  ; linear aggreg coeficients
  ;linear-aggreg-population-coef
  ;linear-aggreg-distance-to-road-coef
  ;linear-aggreg-closeness-centrality-coef
  ;linear-aggreg-bw-centrality-coef
  ;linear-aggreg-accessibility-coef


  distance-to-roads-decay


  ;; network

  ; network update
  network-update-time-mode ; "fixed-ticks" or "fixed-population"
  network-update-ticks

  ; growth parameters
  network-max-new-cities-number
  network-cities-max-density
  network-cities-density-radius
  network-distance-road-needed
  network-sigma-distance-road
  network-distance-road-min

  ; indicator tables
  shortest-paths
  nw-relative-speeds
  nw-distances

  pairs-total-weight


  ; network vars
  network-vars-decay

  ; accessibility
  accessibility-decay


  ; biological network
  ; parameters
  network-biological-initial-diameter
  network-biological-input-flow
  ;network-biological-threshold

  ; vars
  network-biological-o
  network-biological-d
  network-biological-nodes-number
  network-biological-new-links-number
  network-biological-diameter-max
  network-biological-total-diameter-variation
  bio-ticks


  ;; deprecated heuristics
  random-network-density
  basic-gravity-exponent
  neigh-gravity-threshold-quantile
  shortcuts-threshold

  ;;
  ; indicators

  indicator-sample-patches
  patch-values-table

  ;;
  ;  Multimodeling variables

  ;setup-method ; \in {"synthetic-settlement","empty","real"}

  ; network-generation-method
  ;   { "gravity-heuristic","biological","road-connexion" }
  ;network-generation-method
  eucl-nw-generation-method

  ; patch value function
  patch-value-function

  ; heuristic network : city interaction method
  ;
  ;  --   multimodeling more easy with external architecture file precising modules and options ? would imply dependancies etc ; to be investigated further --
  cities-interaction-method ; \in {"gravity"}


  ;;
  ; experiments
  experiment-id


  ;;
  headless?

  ;log-level


  ;;;;;
  ;; Weak coupling

  cities-generation-method ;  \in {"zipf-christaller";"random";"prefAtt-diffusion-density";"from-density-file";"fixed-density"}
  density-to-cities-method ; \in {"hierarchical-aggreg" ; "random-aggreg" ; "intersection-density"}

]


breed [cities city]

undirected-link-breed [roads road]


patches-own [

 ;; density generation
 patch-population-share
 patch-population


 ;; cities generation
 distance-weighted-total-pop

 ; closest city, on which nw measures are based
 patch-closest-city
 patch-closest-city-distance

 ; explicative variables (includes population)
 patch-distance-to-road
 patch-closeness-centrality
 patch-bw-centrality
 patch-accessibility

 ; aggregated value (rbd style)
 patch-value

]


cities-own [
  ; population
  city-population

  ; id
  id


  ;; network variables
  city-bw-centrality
  city-closeness-centrality
  city-accessibilities
  city-accessibility

]


roads-own [

  capacity

  ; length
  road-length


  bw-centrality

]


;;
;  auxiliary breeds

;;
; biological network generation

breed [biological-network-nodes biological-network-node]
breed [biological-network-poles biological-network-pole]

undirected-link-breed [biological-network-links biological-network-link]
undirected-link-breed [biological-network-real-links biological-network-real-link]

biological-network-nodes-own [
  ;; pressure
  pressure
  ;; total capacity
  total-capacity
  ;; number
  biological-network-node-number
]

biological-network-poles-own [
  real-pressure
]


biological-network-links-own [
  ;; diameter
  diameter
  ;; flow
  flow
  ;; length
  bio-link-length
]

biological-network-real-links-own [
  real-link-length
]
@#$#@#$#@
GRAPHICS-WINDOW
4
10
664
691
-1
-1
13.0
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
49
0
49
0
0
1
ticks
30.0

SLIDER
684
457
856
490
gravity-radius
gravity-radius
0
10000
2357
1
1
NIL
HORIZONTAL

SLIDER
682
228
854
261
population-growth-rate
population-growth-rate
0
3000
3000
1
1
NIL
HORIZONTAL

SLIDER
683
263
855
296
density-alpha-localization
density-alpha-localization
0
4
1.66
0.01
1
NIL
HORIZONTAL

SLIDER
683
297
855
330
density-diffusion-steps
density-diffusion-steps
0
6
1
1
1
NIL
HORIZONTAL

SLIDER
684
334
856
367
density-diffusion
density-diffusion
0
0.5
0.05
0.01
1
NIL
HORIZONTAL

MONITOR
1043
56
1109
101
cities pop
sum populations
17
1
11

MONITOR
1043
10
1124
55
patches-pop
total-population
17
1
11

OUTPUT
1129
10
1395
238
9

BUTTON
930
633
1011
666
network
reset-network\nnetwork-euclidian:generate-network eucl-nw-generation-method
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

TEXTBOX
683
168
833
200
Density Generation
11
0.0
1

MONITOR
1043
103
1100
148
cities
count cities
17
1
11

SLIDER
684
559
855
592
gravity-hierarchy-exponent
gravity-hierarchy-exponent
0
10
0.64
0.01
1
NIL
HORIZONTAL

BUTTON
1030
151
1124
184
indicators
indicators:compute-indicators
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
684
525
855
558
gravity-hierarchy-weight
gravity-hierarchy-weight
0
1
0.28
0.01
1
NIL
HORIZONTAL

SLIDER
684
491
856
524
gravity-inflexion
gravity-inflexion
0
10
2.7
0.1
1
NIL
HORIZONTAL

SLIDER
884
399
1056
432
#-max-new-links
#-max-new-links
0
100
10
1
1
NIL
HORIZONTAL

SLIDER
682
194
854
227
sp-max-pop
sp-max-pop
10000
100000
50100
100
1
NIL
HORIZONTAL

TEXTBOX
831
375
959
393
Network Generation
13
0.0
1

INPUTBOX
740
102
849
162
density-file-id
10
1
0
String

INPUTBOX
675
100
732
160
seed
1
1
0
Number

BUTTON
1020
634
1086
667
clear
ca random-seed seed
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
678
61
826
94
setup-center-number
setup-center-number
1
40
18
1
1
NIL
HORIZONTAL

TEXTBOX
678
10
828
28
Setup
11
0.0
1

BUTTON
1136
281
1199
314
setup
setup:setup
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
1136
317
1199
350
go
main:go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

CHOOSER
682
394
858
439
network-generation-method
network-generation-method
"deterministic-breakdown" "random-breakdown" "biological" "cost-driven" "road-connexion" "random"
3

SLIDER
884
196
1093
229
linear-aggreg-population-coef
linear-aggreg-population-coef
0
1
0.5
0.1
1
NIL
HORIZONTAL

SLIDER
884
230
1093
263
linear-aggreg-distance-to-road-coef
linear-aggreg-distance-to-road-coef
0
1
0.5
0.1
1
NIL
HORIZONTAL

SLIDER
884
264
1093
297
linear-aggreg-closeness-centrality-coef
linear-aggreg-closeness-centrality-coef
0
1
0.5
0.1
1
NIL
HORIZONTAL

SLIDER
884
298
1093
331
linear-aggreg-bw-centrality-coef
linear-aggreg-bw-centrality-coef
0
1
0.5
0.1
1
NIL
HORIZONTAL

SLIDER
884
332
1093
365
linear-aggreg-accessibility-coef
linear-aggreg-accessibility-coef
0
1
0.5
0.1
1
NIL
HORIZONTAL

CHOOSER
675
660
821
705
display-variable
display-variable
"population" "patch-value" "new-city-proba"
0

BUTTON
824
667
920
700
update display
display:update-display
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

TEXTBOX
887
174
1037
192
Linear aggreg coefs
11
0.0
1

BUTTON
938
713
1009
746
go bio
network-biological:go
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
1064
462
1264
495
network-biological-threshold
network-biological-threshold
0
2
0.3
0.1
1
NIL
HORIZONTAL

BUTTON
1015
713
1079
746
show bio
network-biological:show-links
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
1077
676
1155
709
connex
network-biological:kill-weak-links\nnetwork-biological:keep-connex-component
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
938
677
1004
710
clear bio
network-biological:clear-network
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
1006
676
1074
709
setup bio
network-biological:setup
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
1082
712
1147
745
simpl
network-biological:simplify-network\n
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
1064
498
1264
531
network-biological-steps
network-biological-steps
0
100
82
1
1
NIL
HORIZONTAL

SLIDER
858
100
978
133
raster-row
raster-row
0
100000
34286
1
1
NIL
HORIZONTAL

SLIDER
859
136
979
169
raster-col
raster-col
0
100000
36190
1
1
NIL
HORIZONTAL

CHOOSER
713
10
854
55
density-setup-method
density-setup-method
"synthetic" "empty" "real"
2

CHOOSER
855
10
1000
55
network-setup-method
network-setup-method
"synthetic" "real"
0

TEXTBOX
688
441
735
459
Gravity
11
0.0
1

TEXTBOX
1063
442
1132
460
Biological
11
0.0
1

SLIDER
859
458
1061
491
random-breakdown-hierarchy
random-breakdown-hierarchy
0
3
2
0.1
1
NIL
HORIZONTAL

SLIDER
860
492
1062
525
random-breakdown-threshold
random-breakdown-threshold
0
5
0.8
0.1
1
NIL
HORIZONTAL

TEXTBOX
863
442
1013
460
Random-breakdown
11
0.0
1

CHOOSER
1310
242
1402
287
log-level
log-level
"debug" "standard"
0

SLIDER
858
553
1030
586
cost-tradeoff
cost-tradeoff
0
0.1
0.05
0.001
1
NIL
HORIZONTAL

SLIDER
1067
399
1239
432
max-network-size
max-network-size
0
1000
1000
1
1
NIL
HORIZONTAL

SLIDER
1271
301
1395
334
final-time-step
final-time-step
-1
10
5
1
1
NIL
HORIZONTAL

BUTTON
1206
298
1263
331
go full
main:go-full-period
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

TEXTBOX
866
534
1016
552
Cost driven
11
0.0
1

SWITCH
845
64
1008
97
density-from-raster?
density-from-raster?
0
1
-1000

@#$#@#$#@
## WHAT IS IT?

Co-evolution of Urban Form and Transportation Network

## HOW IT WORKS

Preferential Attachment (parametric value of patches)/ diffusion for density ; multi-modeling heuristics for network

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
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
NetLogo 5.3.1
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
