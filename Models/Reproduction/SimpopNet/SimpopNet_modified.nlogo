extensions [nw]

__includes[
   "setup.nls"
]


globals[
  infinity          ; Because it does not exist Parce que ça n'existe pas natively in NetLogo
  sumlottery        ; Global needed for the computation of city-picking (network-growth)
  sumpop            ; Global needed for the computation of city-picking (network-growth)
  ;min-time-network  ; the shortest possible time travel between two cities in the network at the tick t
  system-pot-int    ;
  x-cross           ;
  y-cross           ;
  crossing-link1    ;
  crossing-link2    ;
]


  

to go
  
 if (ticks > 2000) 
   [
    show (
      word "liens," (count links) 
      ",new," (count links with [color != 5]) 
      ",pc_new," precision ( ((count links with [color != 5]) / (count links) ) * 100)2)
    
    ;export-listes
    stop
   ]
   
   
   
 nw:set-context turtles links  ; For a new snapshot of the network at each step
  
 grow-cities                ; according to the present network

 calculate-accessibility    ; according to the present network
 
 ;ask cities [set size (5 * population / max [population] of cities)]
 ask cities [set size ( log (1000 * population / max [population] of cities) 10)]
  
  
 grow-network               ; according to the present city-size distribution
 
 adapt-graph                ; Procedure that creates interscation (new nodes on the network) where to links of the same speed cross
 
 update-lists-cities
 
 tick 
    
end

breed [cities city]

cities-own 
[
  population            ; population of the city
  
  city-pot-int          ; potential interaction of the city with all the other-city of the system
  N-city-pot-int        ; normalized potential interaction of the city with all the other-city of the system
  min-time-neighbor     ; the journey time to go the nearest neighbor of this city
  
  accessibility         ; accessibility of the city (shimbel index)
  
  potentiel-interaction ; temporary-attribut for the computation of lotery-potentiel
  tmp-pop               ; temporary-attribut for the computation of city-growth
  attraction            ; force of attraction of the city over all the other in net migration of individuals
  categorie             ; only for the world creation
  network1
  network2
  network3
  
 
 ;; Outputs computation
 list-population
 list-accessibility
 list-attraction
 list-mean-linksspeed
]




to grow-cities
  
  if (city-growth-model = "Gibrat")       [grow-gibrat]
  if (city-growth-model = "coevolution")  [grow-coevolution]
  
end





;*********************************************
;                                            *
;           Gibrat                           *
;                                            *
;*********************************************

to grow-gibrat
  ask cities
  [
    let previous-pop population
    set population max list 0 ((previous-pop * (1 + gibrat-growthrate)))
    if population < 1 [die]
  ]
end

to-report gibrat-growthrate
  let rand-nb 0
  set rand-nb random-normal gibrat-mean gibrat-std
  report rand-nb
end




;*********************************************
;                                            *
;           coevolution                      *
;                                            *
;*********************************************
  

to grow-coevolution
    
;  compute-min-time-network
  compute-city-pot-int
  compute-system-pot-int
  compute-tempor-pop
  
  
; In order to procede to synchronous population comutation, we use a temporary population variable
  ask cities
  [ set population tmp-pop]
    
end
  
  
to compute-tempor-pop
    ask cities [ 
      set N-city-pot-int (lambda ^ beta * ((count cities) / system-pot-int) * city-pot-int)
      set  tmp-pop (population * (1 + N-city-pot-int))
      ]
end 
  

to compute-system-pot-int
  set system-pot-int (sum [city-pot-int] of cities)
end  
  
  
to compute-city-pot-int
   ask cities [
     set city-pot-int value-city-pot-int
     ]
end
 
 
; to compute-min-time-network
;   
;   ask cities [set min-time-neighbor city-min-time-neighbor]
;   set min-time-network min [min-time-neighbor] of cities
;   print min-time-network
;   
; end
 
 
to-report city-min-time-neighbor
     let l-MT []
     ask other cities [
          let MT 0
          set MT time-network self myself
          set l-MT lput MT l-MT
                 ]
  
     report min l-mt
end

 
; 

to-report value-city-pot-int
     let ppot -1
     let listpotF []
     let counter 1
     
     ask other cities [
       let potF 0
       set potF (( [population] of self) / ((time-network self myself + 1) ) ^ beta)    
       set listpotF lput potF listpotF
       set counter counter + 1 
       ]
     set ppot (
       (sum listpotF) 
       )

     report ppot  
 end

  
 
  
  
  
  links-own [
  speed        ; 
  weight       ; lenght / speed
  list-speed   ;
]

breed [crosses cross]
crosses-own [ me? ]

;******************************************************************************


to grow-network
  
  if (Network-growth = "scenario")       [grow-net-scenario]
  if (Network-growth = "coevolution")  [grow-net-coevolution]

end




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Network Growth Scenario ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


To grow-net-scenario
  
  if ticks = 1802 [ ask city 48 [ create-link-with city 58 [ actualisation-of-link ] ]]
  if ticks = 1805 [ ask link 58 38 [ actualisation-of-link ] ]
  if ticks = 1810 [ ask city 48 [ create-link-with city 91 [ actualisation-of-link ] ]]
  if ticks = 1812 [ ask city 48 [ create-link-with city 76 [ actualisation-of-link ] ]]
  if ticks = 1818 [ ask city 38 [ create-link-with city 6 [ actualisation-of-link ] ]]
  if ticks = 1820 [ ask link 58 8 [ actualisation-of-link ] ]
  if ticks = 1825 [ ask city 48 [ create-link-with city 65 [ actualisation-of-link ] ]]
  if ticks = 1830 [ ask city 48 [ create-link-with city 3 [ actualisation-of-link ] ]]
  if ticks = 1840 [ ask city 3 [ create-link-with city 61 [ actualisation-of-link ] ]]
  if ticks = 1846 [ ask city 61 [ create-link-with city 6 [ actualisation-of-link ] ]]
    
  if ticks = 1865 [ ask link 48 91 [ actualisation-of-link ] ]
  if ticks = 1870 [ ask city 91 [ create-link-with city 11 [ actualisation-of-link ] ]]
  if ticks = 1880 [ ask link 48 58 [ actualisation-of-link ] ]
  if ticks = 1889 [ ask link 6 61 [ actualisation-of-link ] ]
  if ticks = 1905 [ ask city 6 [ create-link-with city 3 [ actualisation-of-link ] ]]
  if ticks = 1912 [ ask city 46 [ create-link-with city 48 [ actualisation-of-link ] ]]
  
  if ticks = 1964 [ ask link 48 58 [ actualisation-of-link ] ]
  if ticks = 1969 [ ask link 48 91 [ actualisation-of-link ] ]
  if ticks = 1972 [ ask link 48 3 [ actualisation-of-link ] ]
  if ticks = 1912 [ ask city 3 [ create-link-with city 6 [ actualisation-of-link ] ]]
  
end



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Coevolution Network Growth ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


to grow-net-coevolution

 
   ; Update globals
 set sumpop sum [population] of cities
 set sumlottery sum [population ^ lottery-power] of cities
  
   ; Lottery random selection of a city (I) amongs all cities, according to their population
 let cityI city-1pick
   ; Lottery random selection of another city (J) amongs all other cities, according to their interaction potentiel with city I
 let cityJ lottery-potentiel cityI
    
 
 
 
 ifelse link ([who] of cityI) ([who] of cityJ) != Nobody
  ; If the a link between I and J existes, the weight of the link is actualised
  [
    ask link ([who] of cityI) ([who] of cityJ) 
    [ actualisation-of-link ]
    
    update-networks-info cityI
    update-networks-info cityJ
    
  ]
  

  ; If the a link between I and J does not existe, the sinuosity index (IS) is computed 
  [
    let efficacityIJ Efficacity-index cityI cityJ
    
    ifelse ( 
             efficacityIJ < (IS)  ; The existing network is allready efficient enought if  the (sinuosity index < threshold sinuosity index).
             )
    [
      ; nothing is done
    ]
   
    ; if  the (sinuosity index > threshold sinuosity index), the network is not efficient enough : 
    ; A link between the cities I and J is created and initialised according the the present paramters
    [
      ask cityI 
      [ create-link-with cityJ 
         [ actualisation-of-link ] 
      ]
      update-networks-info cityI
      update-networks-info cityJ
    ]
  ]

end



;******************************************************
; Actualisation of link parameters
;******************************************************


to actualisation-of-link
    set speed current-speed
    set weight (link-length / speed)
    set color current-color 
    set thickness 0.5
end

to-report current-speed
  let speed-date 0
  if ticks <= 2000  [set speed-date speed3]
  if ticks <= 1960  [set speed-date speed2]
  if ticks <= 1860  [set speed-date speed1]
  report speed-date
end

to-report current-color
  let color-date 0
  if ticks <= 2000  [set color-date red]
  if ticks <= 1960  [set color-date yellow]
  if ticks <= 1860  [set color-date blue]
  report color-date
end



;******************************************************
; Lottery mecanisms for the random selection of cities
;******************************************************

to-report city-1pick
  ; The random election is made accroding to the population of the cities
  let totpopI random-float sumlottery
  let cityI nobody
  ask cities
  [if cityI = nobody
    [ifelse (population ^ lottery-power) > totpopI
      [set cityI self]
      [set totpopI totpopI - (population ^ lottery-power)]
    ]
  ]
 report cityI 
end


to-report lottery-potentiel [#1pick]
  ; The random election is made accroding to the interaction potentiel of each cities with the first city picked
  calcul-potentiels #1pick
  let pool-cities cities with [who != [who] of #1pick]
  
  let totpotentiel random-float sum [potentiel-interaction ^ lottery-power] of pool-cities
  let city-picked nobody
  ask pool-cities
  [
   if city-picked = nobody
   [
     ifelse (potentiel-interaction ^ lottery-power) > totpotentiel
     [set city-picked self]
     [set totpotentiel totpotentiel - (potentiel-interaction ^ lottery-power) ] 
   ]
  ]
  report city-picked
  
end


;***************************************************************************
; Indexes computation (journey time, sinuosity, intercation potential, etc)
;******************************************************************************


;; Interctaion potential = (Pi*Pj)^beta-pop / (Tij)^beta-time
to calcul-potentiels [#1pick]
  ask cities with [who != [who] of #1pick]
  [
  let pipj [population] of self * [population] of #1pick
  let tij time-eucl #1pick self
  set potentiel-interaction ( (pipj) / (tij ^ beta))
  ]
end


to-report time-eucl [#startpoint #destination]
  let DistEucl False  
  ask #startpoint [set DistEucl distance #destination]
  set DistEucl (DistEucl * (1 / current-speed))
  report DistEucl
end


to-report Efficacity-index [#startpoint #destination]
  ; Calcul de l'indice de sinuosité
  let IndS (time-network #startpoint #destination) / (time-eucl #startpoint #destination)
  report IndS
end

to-report time-network [#startpoint #destination]
  let DistNetwork false
  set DistNetwork [ nw:weighted-distance-to #startpoint "weight" ] of #destination
  report DistNetwork
end



;*******************************************
; graph reconstruction when crossing
;*******************************************

to adapt-graph
  find-crossing
  if x-cross != false [ create-intersection]
end


to find-crossing
  
 ;; each pair of segments checks for intersections once
  ask links [
    ;; performing this check on the who numbers keeps us from checking every pair twice
    ;; we only check links with similiar speed
    ask links with [(self > myself) and ([speed] of self = [speed] of myself) and (not-neighbors self myself) and ([speed] of self != 1)][
      let result intersection self myself
      if not empty? result [
       ;  print result
        set x-cross (item 0 result)
        set y-cross (item 1 result)  
        set crossing-link1 (item 2 result)
        set crossing-link2 (item 3 result)      
        ]
    ]
            ]
end


to create-intersection
 ; print "hatching"
  create-crosses 1 [
          set shape "x"
          set color (current-color + 2)
          set size 1
          setxy (x-cross) (y-cross)
          set me? true]
  
   ask crossing-link1   [ask both-ends [ create-links-with crosses with [me? = true]
                                         [actualisation-of-link]]]
   ask crossing-link2 [ask both-ends [ create-links-with crosses with [me? = true]
                                       [actualisation-of-link]]]

   ask crossing-link1 [die]
   ask crossing-link2 [die]
   ask crosses with [me? = true] [set me? false]
   set crossing-link1 false
   set crossing-link2 false
   set x-cross false
   set y-cross false
   adapt-graph
end

to-report not-neighbors [l1 l2]
  ifelse [end1] of l1 != [end1] of l2
  and 
  [end1] of l1 != [end2] of l2
  and 
  [end2] of l1 != [end1] of l2
  and 
  [end2] of l1 != [end2] of l2
  
  [report true]
  [report false]
end


;; reports a two-item list of x and y coordinates, or an empty list if no intersection is found
to-report intersection [t1 t2]
  let m1 [tan (90 - link-heading)] of t1
  let m2 [tan (90 - link-heading)] of t2
  ;; treat parallel/collinear lines as non-intersecting
  if m1 = m2 [ report [] ]
  ;; is t1 vertical? if so, swap the two turtles
  if abs m1 = tan 90
  [
    ifelse abs m2 = tan 90
      [ report [] ]
      [ report intersection t2 t1 ]
  ]
  ;; is t2 vertical? if so, handle specially
  if abs m2 = tan 90 [
     ;; represent t1 line in slope-intercept form (y=mx+c)
      let c1 [link-ycor - link-xcor * m1] of t1
      ;; t2 is vertical so we know x already
      let x [link-xcor] of t2
      ;; solve for y
      let y m1 * x + c1
      ;; check if intersection point lies on both segments
      if not [x-within? x] of t1 [ report [] ]
      if not [y-within? y] of t2 [ report [] ]
      report (list x y t1 t2)
  ]
  ;; now handle the normal case where neither turtle is vertical;
  ;; start by representing lines in slope-intercept form (y=mx+c)
  let c1 [link-ycor - link-xcor * m1] of t1
  let c2 [link-ycor - link-xcor * m2] of t2
  ;; now solve for x
  let x (c2 - c1) / (m1 - m2)
  ;; check if intersection point lies on both segments
  if not [x-within? x] of t1 [ report [] ]
  if not [x-within? x] of t2 [ report [] ]
  report (list x (m1 * x + c1) t1 t2)
end

to-report x-within? [x]  ;; turtle procedure
  report abs (link-xcor - x) <= abs (link-length / 2 * sin link-heading)
end

to-report y-within? [y]  ;; turtle procedure
  report abs (link-ycor - y) <= abs (link-length / 2 * cos link-heading)
end

to-report link-xcor
  report ([xcor] of end1 + [xcor] of end2) / 2
end

to-report link-ycor
  report ([ycor] of end1 + [ycor] of end2) / 2
end






  


to update-lists-cities
  ask cities
  [
   let pop  precision population 2

   set list-population lput pop list-population  
   set list-accessibility lput accessibility list-accessibility
   set list-attraction lput attraction list-attraction
   set list-mean-linksspeed lput (mean [speed] of my-links) list-mean-linksspeed
  ]
end



;*******************************************
; calcul de l'indice d'accessibilité d'un noeud
;*******************************************

 to calculate-accessibility
   ask cities [
     set accessibility value-accessibility
     ]
   map-accesibility
 end
 
to map-accesibility
  let max-accesibility 0
  set max-accesibility max [accessibility] of cities
  ask cities
  [set color scale-color green accessibility 0 max-accesibility 
    ]
end

  
to-report value-accessibility
     let acc -1
     let listpcc []
     let compteur 1
      ask other cities [
       ;print (word "Appellé : " self)
       let tpspcc 0
       set tpspcc time-network self myself
       set listpcc lput tpspcc listpcc
       set compteur compteur + 1 
       ]
     set acc sum listpcc
;     print "-> !" 
     report acc  
 end





;*******************************************
; Fichier export de simulation...
;*******************************************




to export-listes
  ; On crée nos csv
  if (file-exists? "z-out_populations.csv" = True) [file-delete "z-out_populations.csv"]
  if (file-exists? "z-out_accessibility.csv" = True) [file-delete "z-out_accessibility.csv"]
  if (file-exists? "z-out_attraction.csv" = True) [file-delete "z-out_attraction.csv"]
   if (file-exists? "z-out_network-info.csv" = True) [file-delete "z-out_network-info.csv"]
  if (file-exists? "z-out_linksspeed.csv" = True) [file-delete "z-out_linksspeed.csv"]
  
  let listeTemps []
  set listeTemps lput "Cities" listeTemps
  let iTemps 0
  while [iTemps <= ticks] 
  [
    set listeTemps lput iTemps listeTemps
    set iTemps (iTemps + 1)
  ]
  
  let listeTemps10 []
  set listeTemps10 lput "Cities" listeTemps10
  let iTemps10 0
  while [iTemps10 <= ticks] 
  [
    set listeTemps10 lput iTemps10 listeTemps10
    set iTemps10 (iTemps10 + 10)
  ]
  
  file-open  "z-out_populations.csv"
  foreach listeTemps [file-type (word ? ",")]
  file-close
  file-open  "z-out_accessibility.csv"
  foreach listeTemps [file-type (word ? ",")]
  file-close
  file-open  "z-out_attraction.csv"
  foreach listeTemps [file-type (word ? ",")]
  file-close
 
  file-open  "z-out_network-info.csv"
  file-type "Ville,DateNW1,PopNW1,DateNW2,PopNW2,DateNW3,PopNW3"
  file-close
  
    file-open  "z-out_network-info.csv"
  file-type "Ville,DateNW1,PopNW1,DateNW2,PopNW2,DateNW3,PopNW3"
  file-close
  
    file-open  "z-out_linksspeed.csv"
  foreach listeTemps [file-type (word ? ",")]
  file-close
  
  
  foreach sort cities
  [
    ask ?
    [
      file-open  "z-out_populations.csv"
      file-print ""
      file-type (word "City" who ",")
      foreach list-population [file-type (word ?1 ",")]
      file-close
      file-open  "z-out_accessibility.csv"
      file-print ""
      file-type (word "City" who ",")
      foreach list-accessibility [file-type (word ?1 ",")]
      file-close
      file-open  "z-out_attraction.csv"
      file-print ""
      file-type (word "City" who ",")
      foreach list-attraction [file-type (word ?1 ",")]
      file-close
      
      file-open  "z-out_network-info.csv"
      file-print ""
      file-type (word "City" who "," item 0 network1 "," item 1 network1 "," item 0 network2 "," item 1 network2 "," item 0 network3 "," item 1 network3)
      file-close
      
      file-open  "z-out_linksspeed.csv"
      file-print ""
      file-type (word "City" who ",")
      foreach list-mean-linksspeed [file-type (word ?1 ",")]
      file-close
      
    ]
  ]
  

end

to update-networks-info [#city]
  let citiesPop reverse sort [population] of cities
  let myRank (position ([population] of #city) citiesPop) + 1
  
  ifelse (ticks <= 70)[
   ask #city [if (item 0 network1 = "") [ set network1 (list ticks myRank) ]]
    ][
    ifelse (ticks <= 150) [
      ask #city [if (item 0 network2 = "") [ set network2 (list ticks myRank)]]
      ][
      ask #city [if (item 0 network3 = "") [ set network3 (list ticks myRank)]]
      ]
    ]
end
  
;;;-------------------------------------------------------------------------------------------------------------------------

  
@#$#@#$#@
GRAPHICS-WINDOW
267
17
731
502
25
25
8.902
1
10
1
1
1
0
0
0
1
-25
25
-25
25
0
0
1
ticks
30.0

BUTTON
7
66
70
110
NIL
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
7
19
70
64
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

INPUTBOX
190
20
257
80
myseed
31
1
0
Number

INPUTBOX
110
173
163
233
speed1
5
1
0
Number

CHOOSER
75
19
180
64
city-growth-model
city-growth-model
"Gibrat" "coevolution"
1

SLIDER
3
173
107
206
lottery-power
lottery-power
0
10
3
0.1
1
NIL
HORIZONTAL

MONITOR
738
171
805
216
mean pop
mean [population] of cities
0
1
11

PLOT
738
14
911
160
Histogramme_poplation (20 classes)
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" "set-histogram-num-bars 20\nset-plot-x-range 0 (max [population] of cities)\nset-plot-pen-interval ((max [population] of cities) / 20)"
PENS
"default" 1.0 1 -16777216 true "" "histogram ([population] of cities)"

INPUTBOX
163
173
214
233
speed2
20
1
0
Number

INPUTBOX
215
173
265
233
speed3
75
1
0
Number

PLOT
915
15
1096
160
System Population
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
"default" 1.0 0 -16777216 true "" "plot sum [population] of cities"

MONITOR
808
171
872
216
min pop
min [population] of cities
0
1
11

MONITOR
875
171
943
216
max pop
max [population] of cities
0
1
11

PLOT
738
228
948
384
shimbel/population
log (population)
Shimbel
1.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 2 -16777216 true "" "clear-plot ask cities [plotxy log population 10 accessibility]"

BUTTON
190
81
257
114
my-seed!
random-seed myseed
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
743
399
868
444
% mean annual growth
((sum [population] of cities / 5490390 ) ^ (1 / (ticks - 1800)) - 1 ) * 100
3
1
11

TEXTBOX
9
139
266
181
----------------------------------------------------------------\nNETWORK GROWTH Parameters
11
0.0
1

TEXTBOX
9
262
266
304
----------------------------------------------------------------\nGIBRAT Model Parameters
11
0.0
1

TEXTBOX
4
348
271
390
-----------------------------------------------------------------\nCOEVOLUTION Model Parameters
11
0.0
1

CHOOSER
75
66
180
111
Network-growth
Network-growth
"scenario" "coevolution"
1

SLIDER
5
294
128
327
gibrat-mean
gibrat-mean
0
0.02
0.01
0.001
1
NIL
HORIZONTAL

SLIDER
127
294
250
327
gibrat-std
gibrat-std
0
0.03
0.01
0.001
1
NIL
HORIZONTAL

SLIDER
3
211
108
244
IS
IS
0
20
12
1
1
NIL
HORIZONTAL

SLIDER
131
384
255
417
beta
beta
0
3
1.1
0.1
1
NIL
HORIZONTAL

SLIDER
6
384
130
417
lambda
lambda
0
0.015
0.01
0.001
1
NIL
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

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
0
Rectangle -7500403 true true 151 225 180 285
Rectangle -7500403 true true 47 225 75 285
Rectangle -7500403 true true 15 75 210 225
Circle -7500403 true true 135 75 150
Circle -16777216 true false 165 76 116

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
Polygon -7500403 true true 135 285 195 285 270 90 30 90 105 285
Polygon -7500403 true true 270 90 225 15 180 90
Polygon -7500403 true true 30 90 75 15 120 90
Circle -1 true false 183 138 24
Circle -1 true false 93 138 24

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
  <experiment name="experiment" repetitions="1" runMetricsEveryStep="false">
    <setup>setup
random-seed myseed</setup>
    <go>go</go>
    <metric>max [population] of cities</metric>
    <enumeratedValueSet variable="speed1">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="speed2">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="speed3">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="myseed">
      <value value="153"/>
      <value value="152"/>
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

@#$#@#$#@
0
@#$#@#$#@
