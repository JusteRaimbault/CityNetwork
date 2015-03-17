extensions [cities profiler]

__includes [
 "building.nls"
 "commercial.nls"
 "developers.nls"
 "dirty.nls"
 "displays.nls"
 "generic.nls"
 "grids.nls"
 "import-gis.nls"
 "import-road-network.nls"
 "industrial.nls"
 "output.nls"
 "paint-attributes.nls"
 "parks.nls"
 "pioneers.nls"
 "primary-road-extenders.nls"
 "primary-roads.nls"
 "residential.nls"
 "road-display.nls"
 "roads.nls"
 "seeds.nls"
 "speculators.nls"
 "statistics.nls"
 "terrain-display.nls"
 "terrain.nls"
 "tertiary-road-connectors.nls"
 "tertiary-road-extenders.nls"
 "tertiary-roads.nls"
]

globals [
  CITY-POPULATION
  CITY-LAND-COVER
  CENTER-X
  CENTER-Y
  NUMBER-OF-OWNED-PATCHES

  Number-of-Images
  My-Random-Seed ;; for bach runs to record their random seed
  My-Run-Number

  do-timing? ;; boolean flag determining if we tack and print timing data or not
  elapsed ;; intermediate timing values kept here
  benchmark-result
]

to init-output-capture
  set Number-of-Images 0
  ifelse ( capture-movie? )
  [
    if (Output-FileName != "")
    [ while [ movie-status != "No movie." ]
      [ movie-cancel
      ]
      movie-start word Output-Filename ".mov"
      movie-set-frame-rate 5
    ]
  ]
  [ while [ movie-status != "No movie." ]
    [ movie-cancel
    ]
  ]
end

to Save-Output
  if (Output-Filename != "")
  [ if (Capture-Movie?)
    [ Show-Terrain
      movie-grab-view
    ]
    if (Capture-Screen-Shots?)
    [ Show-Default
      export-view (word (Output-Filename) "-" Number-of-Images ".png")
      Show-Density-Histogram
      export-view (word (Output-Filename) "-Density-" Number-of-Images ".png")
;      grab-one-of-every-image (word output-filename "-" Number-of-Images)
      set Number-of-Images (Number-of-Images + 1)
    ]

  ]
end

to-report find-city-center
  let owned-patches patches with [owner != nobody]
  let city-pop sum [population] of buildings
  let x (sum [parcel-density * pxcor] of owned-patches ) / city-pop
  let y (sum [parcel-density * pycor] of owned-patches ) / city-pop
  report patch-at x y
end

;to add-me-to-city-population
;  set CITY-POPULATION (CITY-POPULATION + parcel-density)
;  set CENTER-X (CENTER-X + (parcel-density * pxcor))
;  set CENTER-Y (CENTER-Y + (parcel-density * pycor))
;end
;
;to take-me-from-city-population
;  set CENTER-X (CENTER-X - (parcel-density * pxcor))
;  set CENTER-Y (CENTER-Y - (parcel-density * pycor))
;  set CITY-POPULATION (CITY-POPULATION - parcel-density)
;  if (CITY-POPULATION < 0 )
;  [ set CENTER-X 0
;    set CENTER-Y 0
;    set CITY-POPULATION 0
;  ]
;end

to startup
    set do-timing? false
    SET-TERRAIN-GLOBALS
    level-terrain
    ask start-seeds [ die ]
    make-default-seed
    Reset
end

to Reset
    set do-timing? false
    set elapsed (list)
    reset-ticks
    ask turtles with [ breed != start-seeds ] [ die ]

    set pins-primaries []
    ;set pins-tertiaries []
    get-pins-water-boundaries

    set AVG-ELEVATION WATER-LEVEL
    set CENTER-X 0
    set CENTER-Y 0
    set CITY-POPULATION 0
    set CITY-LAND-COVER 0
    set DEBUG false

    clear-all-plots

    find-dist-to-water
    find-water-gradient
    clear-all-buildings
    clear-roads

    create-residential-class
    create-commercial-class
    create-industrial-class
    make-park-class
    init-dirty-bits
    init-residential-developers
    init-commercial-developers
    init-industrial-developers
    init-park-developers

    find-dev-from-grid
    divy-turtles-among-seeds

    let temp 0
    ask patches
    [ set residential-frequency 0
      set commercial-frequency 0
      set industrial-frequency 0
      set reserved false
      set temp site-worth RESIDENTIAL self
      set temp site-worth COMMERCIAL self
      set temp site-worth INDUSTRIAL self
    ]
    Show-Running-Display
    find-dev-from-grid
end

to start-timing
   if ( do-timing? ) [ set elapsed fput timer elapsed ]
end

to report-timing [ lab ]
   if ( do-timing? ) [
     carefully
       [ let val first elapsed
         set elapsed but-first elapsed
         __stdout (word "TIMING:" lab ":" ( precision ( timer - val ) 5 ) )
       ]
       [ __stdout (sentence "ERROR" lab "No elapsed timing value available.") ]
   ]
end

to Go
    enable-seeds
    start-timing
    if ( Build-Tertiary-Roads )
    [ generate-tertiary-roads ]
    report-timing "Build tertiary roads"

    start-timing
    if ( Build-Primary-Roads )
    [ create-primary-roads ]
    report-timing "Build primary roads"


    if ( Build-Developments )

    [
      start-timing
      ; this computes the desireability of patches for development
      ; depending on the global average residential elevation
      ; -- because this is run "per patch", we only want to
      ;  update the values occasionally.
      if ( ticks mod 10 = 0)
      [
        HACK-update-average-residential-elevation
      ]
      ask residential-developers
      [
        developmental-search RESIDENTIAL
      ]
      report-timing "Build residential"

      start-timing
      ask commercial-developers
      [
        developmental-search COMMERCIAL
      ]
      report-timing "Build commercial"

      start-timing
      ask industrial-developers
      [
        developmental-search INDUSTRIAL
      ]
      report-timing "Build industrial"

      start-timing
      ask park-developers
      [
        develop-parks
      ]
      report-timing "Build parks"

    ]
    if ( Watch-Display? )
    [ Show-Running-Display ]
    if (ticks mod 100 = 0)
    [ Save-Output
    ]
    if ( ticks mod 200 = 0 )
    [ ask patches [ set patch-seen-before 0 ]
      ask buildings [ set building-seen-before 0 ]
      ask buildings [ fill-remaining-holes self ]
    ]
    ;ask commercial-developers [debug-print patch-here + " : " + who + " " + ifelse-value(owner-of patch-here = nobody)[patch-seen-before][building-seen-before-of owner-of patch-here]]
    ;ask patches with [selected] [set selected false]
    tick
    update-plots
end

to update-plots
  set-current-plot "Populations"
  set-current-plot-pen "residential"
  plot [global-population] of RESIDENTIAL
  set-current-plot-pen "commercial"
  plot [global-population] of COMMERCIAL
  set-current-plot-pen "industrial"
  plot [global-population] of INDUSTRIAL

  set-current-plot "Land Coverage"
  set-current-plot-pen "residential"
  plot [global-land-cover] of RESIDENTIAL
  set-current-plot-pen "commercial"
  plot [global-land-cover] of COMMERCIAL
  set-current-plot-pen "industrial"
  plot [global-land-cover] of INDUSTRIAL
  set-current-plot-pen "parks"
  plot [global-land-cover] of PARK
end

;; this is a very simple benchmark, which probably only captures some of the performance
;; ~Forrest (6/4/2007)
to benchmark
  ;; old method- get past the first part, to where stuff is happening
  ;ca
  ;startup
  ;repeat 50 [ go ]

  import-world "benchmark_world.csv"
  wait 1.0
  reset-timer
  repeat 10 [ go ]
  set benchmark-result timer
end

;; convenience procedure, just to get a quick idea of the performance.
;; -- it starts with an imported world with a medium level of development,
;;    and then runs benchmark on it.
to run-5-benchmarks
  print "each run, import benchmark_world.csv, run 10 ticks"

  ;; first one is a throw-away -- we don't record it
  benchmark
  print (word "(throw-away first run: " benchmark-result)
  let timing-data []
  repeat 5 [
    benchmark
    print benchmark-result
    set timing-data fput benchmark-result timing-data
  ]
  print (word "Mean of 5 = " (mean timing-data))
end

to do-profiling
  set Watch-Display? false
  repeat 20 [ go ]
  profiler:reset
  profiler:start
  repeat 20 [ go ]
  profiler:stop
  print profiler:report
end


@#$#@#$#@
GRAPHICS-WINDOW
1
10
614
644
100
100
3.0
1
10
1
1
1
0
0
0
1
-100
100
-100
100
1
1
1
ticks

CC-WINDOW
5
1267
1145
1362
Command Center
0

BUTTON
1023
656
1108
709
Reset
Reset\ninit-output-capture
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL

BUTTON
118
648
207
739
Go
Go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL

SLIDER
623
569
827
602
CONNECTION-RADIUS
CONNECTION-RADIUS
1
20
16
1
1
NIL
HORIZONTAL

SLIDER
623
499
827
532
MANHATTAN-RATIO
MANHATTAN-RATIO
0
10
1.4
0.1
1
NIL
HORIZONTAL

SLIDER
622
640
724
673
X-SCALE
X-SCALE
2
10
10
1
1
NIL
HORIZONTAL

SLIDER
726
640
828
673
Y-SCALE
Y-SCALE
2
10
10
1
1
NIL
HORIZONTAL

SLIDER
623
604
724
637
DEV-X
DEV-X
0
20
20
1
1
NIL
HORIZONTAL

SLIDER
727
604
827
637
DEV-Y
DEV-Y
0
20
20
1
1
NIL
HORIZONTAL

SLIDER
623
534
827
567
MAX-ROAD-CONCENTRATION
MAX-ROAD-CONCENTRATION
0
1
0.4
0.05
1
NIL
HORIZONTAL

BUTTON
757
281
884
314
NIL
Inc-DEV-X
T
1
T
OBSERVER
NIL
NIL
NIL
NIL

BUTTON
759
318
884
351
NIL
Inc-DEV-Y
T
1
T
OBSERVER
NIL
NIL
NIL
NIL

BUTTON
888
281
1006
314
NIL
Dec-DEV-X
T
1
T
OBSERVER
NIL
NIL
NIL
NIL

BUTTON
888
318
1006
351
NIL
Dec-DEV-Y
T
1
T
OBSERVER
NIL
NIL
NIL
NIL

BUTTON
756
354
883
387
NIL
Inc-RATIO
T
1
T
OBSERVER
NIL
NIL
NIL
NIL

BUTTON
888
355
1006
388
NIL
Dec-RATIO
T
1
T
OBSERVER
NIL
NIL
NIL
NIL

BUTTON
757
390
883
423
NIL
Inc-CONCENTRATION
T
1
T
OBSERVER
NIL
NIL
NIL
NIL

BUTTON
887
390
1007
423
NIL
Dec-CONCENTRATION
T
1
T
OBSERVER
NIL
NIL
NIL
NIL

BUTTON
1010
281
1124
314
NIL
Set-DEV-X
T
1
T
OBSERVER
NIL
NIL
NIL
NIL

BUTTON
1010
318
1124
351
NIL
Set-DEV-Y
T
1
T
OBSERVER
NIL
NIL
NIL
NIL

BUTTON
1010
355
1123
388
NIL
Set-RATIO
T
1
T
OBSERVER
NIL
NIL
NIL
NIL

BUTTON
1011
390
1124
423
NIL
Set-CONCENTRATION
T
1
T
OBSERVER
NIL
NIL
NIL
NIL

BUTTON
757
426
884
459
NIL
Inc-ELEVATION
T
1
T
OBSERVER
NIL
NIL
NIL
NIL

BUTTON
889
426
1006
459
NIL
Dec-ELEVATION
T
1
T
OBSERVER
NIL
NIL
NIL
NIL

BUTTON
1010
425
1125
458
NIL
Set-ELEVATION
T
1
T
OBSERVER
NIL
NIL
NIL
NIL

SLIDER
800
10
1004
43
GROUND-LEVEL
GROUND-LEVEL
0
255
84
1
1
NIL
HORIZONTAL

SLIDER
800
45
1004
78
WATER-LEVEL
WATER-LEVEL
0
255
80
1
1
NIL
HORIZONTAL

SLIDER
624
10
796
43
BRUSH-RADIUS
BRUSH-RADIUS
0
20
3
1
1
NIL
HORIZONTAL

CHOOSER
624
46
796
91
BRUSH-TYPE
BRUSH-TYPE
"Round" "Square"
0

BUTTON
625
279
753
312
NIL
Show-DEV-X
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL

BUTTON
626
316
752
349
NIL
Show-DEV-Y
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL

BUTTON
626
352
752
385
NIL
Show-RATIO
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL

BUTTON
624
389
753
422
NIL
Show-CONCENTRATION
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL

BUTTON
623
426
751
459
NIL
Show-Terrain
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL

BUTTON
2
741
207
774
NIL
Show-Running-Display
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL

BUTTON
1011
45
1120
91
NIL
Clear-Roads
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL

CHOOSER
1
647
115
692
RUNNING-DISPLAY
RUNNING-DISPLAY
"None" "Default" "Terrain" "Roads" "Density" "Density Histogram" "Zoned Density" "Age" "Last Updated" "Residential Worth" "Commercial Worth" "Industrial Worth" "Developer Frequencies"
1

SLIDER
623
464
724
497
MIN-DISTANCE
MIN-DISTANCE
1
20
10
1
1
NIL
HORIZONTAL

SLIDER
729
464
827
497
MAX-DISTANCE
MAX-DISTANCE
1
20
15
1
1
NIL
HORIZONTAL

BUTTON
623
98
751
131
NIL
Show-MIN-DISTANCE
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL

BUTTON
625
134
751
167
NIL
Show-MAX-DISTANCE
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL

BUTTON
754
97
882
130
NIL
Inc-MIN-DISTANCE
T
1
T
OBSERVER
NIL
NIL
NIL
NIL

BUTTON
754
133
882
166
NIL
Inc-MAX-DISTANCE
T
1
T
OBSERVER
NIL
NIL
NIL
NIL

BUTTON
885
97
1002
130
NIL
Dec-MIN-DISTANCE
T
1
T
OBSERVER
NIL
NIL
NIL
NIL

BUTTON
885
134
1003
167
NIL
Dec-MAX-DISTANCE
T
1
T
OBSERVER
NIL
NIL
NIL
NIL

BUTTON
1006
99
1120
132
NIL
Set-MIN-DISTANCE
T
1
T
OBSERVER
NIL
NIL
NIL
NIL

BUTTON
1007
134
1122
167
NIL
Set-MAX-DISTANCE
T
1
T
OBSERVER
NIL
NIL
NIL
NIL

SLIDER
938
499
1127
532
ELEVATION-ROAD-CONST
ELEVATION-ROAD-CONST
0
2
0.4
0.05
1
NIL
HORIZONTAL

SLIDER
936
608
1128
641
MIN-CHANGE-IN-WORTH
MIN-CHANGE-IN-WORTH
0
2
0
0.025
1
NIL
HORIZONTAL

BUTTON
1011
10
1120
44
NIL
level-terrain
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL

CHOOSER
1
694
115
739
OVERLAY-DISPLAY
OVERLAY-DISPLAY
"None" "Terrain-Boundaries" "Speculator Boundaries" "Owners" "Seen Before" "Show Reserved" "Show Grid"
0

SLIDER
938
462
1126
495
MAX-DIST-ALONG-P.R.
MAX-DIST-ALONG-P.R.
0
80
50
1
1
NIL
HORIZONTAL

SLIDER
937
537
1127
570
DESIRED-ELEVATION
DESIRED-ELEVATION
0
20
10
1
1
NIL
HORIZONTAL

BUTTON
830
495
936
528
NIL
Draw-Primary
T
1
T
OBSERVER
NIL
NIL
NIL
NIL

SLIDER
936
573
1127
606
CONSIDER-LOWER-FREQ
CONSIDER-LOWER-FREQ
0
1
0.8
0.01
1
NIL
HORIZONTAL

PLOT
379
649
591
814
Populations
time
population
0.0
10.0
0.0
10.0
true
true
PENS
"Residential" 1.0 0 -1184463 true
"Commercial" 1.0 0 -2674135 true
"Industrial" 1.0 0 -13345367 true

INPUTBOX
4
824
138
904
min-industrial-parcel-size
64
1
0
Number

INPUTBOX
138
824
271
904
max-industrial-parcel-size
96
1
0
Number

INPUTBOX
4
904
138
984
min-commercial-parcel-size
5
1
0
Number

INPUTBOX
138
904
271
984
max-commercial-parcel-size
20
1
0
Number

INPUTBOX
4
984
138
1064
min-residential-parcel-size
5
1
0
Number

INPUTBOX
138
984
271
1064
max-residential-parcel-size
10
1
0
Number

INPUTBOX
271
824
453
904
initial-industrial-building-density
1
1
0
Number

INPUTBOX
271
904
453
984
initial-commercial-building-density
1
1
0
Number

INPUTBOX
271
984
453
1064
initial-residential-building-density
1
1
0
Number

SWITCH
211
760
372
793
Capture-Movie?
Capture-Movie?
1
1
-1000

SWITCH
211
727
372
760
Capture-Screen-Shots?
Capture-Screen-Shots?
1
1
-1000

INPUTBOX
211
647
372
727
Output-Filename
results
1
0
String

SLIDER
623
675
827
708
GRID-ANGLE
GRID-ANGLE
-45
45
0
1
1
Degrees
HORIZONTAL

SWITCH
118
782
208
815
SimCity?
SimCity?
0
1
-1000

BUTTON
832
604
933
637
NIL
Erase-Buildings
T
1
T
OBSERVER
NIL
NIL
NIL
NIL

BUTTON
831
531
933
564
NIL
Erase-Roads
T
1
T
OBSERVER
NIL
NIL
NIL
NIL

BUTTON
832
677
1001
710
link-primary-road-to-world-edge
link-primary-road-to-world-edge [ patch-here ] of world-reference-seed
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL

SLIDER
6
1121
204
1154
number-of-industrial-developers
number-of-industrial-developers
0
20
5
1
1
NIL
HORIZONTAL

SLIDER
6
1154
204
1187
number-of-commercial-developers
number-of-commercial-developers
0
20
5
1
1
NIL
HORIZONTAL

SLIDER
6
1187
204
1220
number-of-residential-developers
number-of-residential-developers
0
20
5
1
1
NIL
HORIZONTAL

SLIDER
212
1108
420
1141
number-of-tertiary-road-extenders
number-of-tertiary-road-extenders
1
20
8
1
1
NIL
HORIZONTAL

SLIDER
212
1141
420
1174
number-of-tertiary-road-connectors
number-of-tertiary-road-connectors
1
20
20
1
1
NIL
HORIZONTAL

SLIDER
212
1174
420
1207
number-of-primary-road-extenders
number-of-primary-road-extenders
0
10
5
1
1
NIL
HORIZONTAL

TEXTBOX
13
1075
205
1115
These sliders initialize the number of building developers upon a Reset.
11
0.0
0

TEXTBOX
215
1075
419
1105
These sliders initialize the number of road developers upon a reset.
11
0.0
0

BUTTON
625
244
753
277
NIL
Show-GRID-ANGLE
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL

BUTTON
756
244
881
277
NIL
Inc-GRID-ANGLE
T
1
T
OBSERVER
NIL
NIL
NIL
NIL

BUTTON
887
244
1003
277
NIL
Dec-GRID-ANGLE
T
1
T
OBSERVER
NIL
NIL
NIL
NIL

BUTTON
1008
244
1123
277
NIL
Set-GRID-ANGLE
T
1
T
OBSERVER
NIL
NIL
NIL
NIL

BUTTON
474
970
700
1003
find-deviations-from-grid
find-dev-from-grid
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL

BUTTON
625
170
751
203
NIL
Show-X-SCALE
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL

BUTTON
754
170
883
203
NIL
Inc-X-SCALE
T
1
T
OBSERVER
NIL
NIL
NIL
NIL

BUTTON
625
206
751
239
NIL
Show-Y-SCALE
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL

BUTTON
754
206
883
239
NIL
Inc-Y-SCALE
T
1
T
OBSERVER
NIL
NIL
NIL
NIL

BUTTON
886
170
1004
203
NIL
Dec-X-SCALE
T
1
T
OBSERVER
NIL
NIL
NIL
NIL

BUTTON
887
206
1004
239
NIL
Dec-Y-SCALE
T
1
T
OBSERVER
NIL
NIL
NIL
NIL

BUTTON
1008
171
1123
204
NIL
Set-X-SCALE
T
1
T
OBSERVER
NIL
NIL
NIL
NIL

BUTTON
1009
206
1124
239
NIL
Set-Y-SCALE
T
1
T
OBSERVER
NIL
NIL
NIL
NIL

BUTTON
718
716
853
749
NIL
Show-Residential-Honey
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL

BUTTON
718
749
853
782
NIL
Show-Commercial-Honey
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL

BUTTON
718
782
853
815
NIL
Show-Industrial-Honey
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL

BUTTON
853
716
987
749
NIL
Inc-Residential-Honey
T
1
T
OBSERVER
NIL
NIL
NIL
NIL

BUTTON
853
749
987
782
NIL
Inc-Commercial-Honey
T
1
T
OBSERVER
NIL
NIL
NIL
NIL

BUTTON
853
782
987
815
NIL
Inc-Industrial-Honey
T
1
T
OBSERVER
NIL
NIL
NIL
NIL

BUTTON
987
716
1127
749
NIL
Dec-Residential-Honey
T
1
T
OBSERVER
NIL
NIL
NIL
NIL

BUTTON
987
749
1127
782
NIL
Dec-Commercial-Honey
T
1
T
OBSERVER
NIL
NIL
NIL
NIL

BUTTON
987
782
1127
815
NIL
Dec-Industrial-Honey
T
1
T
OBSERVER
NIL
NIL
NIL
NIL

BUTTON
833
568
932
601
Erase P. Roads
Erase-Primary-Roads
T
1
T
OBSERVER
NIL
NIL
NIL
NIL

SLIDER
489
1015
682
1048
desired-residential-population
desired-residential-population
0
1
0.5
0.01
1
NIL
HORIZONTAL

SLIDER
489
1048
682
1081
desired-commercial-population
desired-commercial-population
0
1
0.25
0.01
1
NIL
HORIZONTAL

SLIDER
489
1081
682
1114
desired-industrial-population
desired-industrial-population
0
1
0.25
0.01
1
NIL
HORIZONTAL

BUTTON
730
893
847
926
NIL
fill-parcel-holes
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL

BUTTON
740
932
826
965
show %s
show-land-coverage-percentages
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL

SLIDER
688
1015
881
1048
desired-residential-land-cover
desired-residential-land-cover
0
1
0.88
0.01
1
NIL
HORIZONTAL

SLIDER
688
1048
881
1081
desired-commercial-land-cover
desired-commercial-land-cover
0
1
0.08
0.01
1
NIL
HORIZONTAL

SLIDER
688
1081
881
1114
desired-industrial-land-cover
desired-industrial-land-cover
0
1
0.12
0.01
1
NIL
HORIZONTAL

BUTTON
832
642
990
675
NIL
Erase-All-Development
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL

SWITCH
1
780
114
813
Watch-Display?
Watch-Display?
0
1
-1000

PLOT
881
822
1132
972
Land Coverage
time
land coverage
0.0
10.0
0.0
10.0
true
false
PENS
"residential" 1.0 0 -1184463 true
"commercial" 1.0 0 -2674135 true
"industrial" 1.0 0 -13345367 true
"parks" 1.0 0 -10899396 false

BUTTON
475
864
585
897
Create Seed
user-create-seed
T
1
T
OBSERVER
NIL
NIL
NIL
NIL

BUTTON
475
899
585
932
Move Seed
user-move-seed
T
1
T
OBSERVER
NIL
NIL
NIL
NIL

BUTTON
589
865
698
898
Delete Seed
user-delete-seed
T
1
T
OBSERVER
NIL
NIL
NIL
NIL

BUTTON
589
935
699
968
Hide Seeds
hide-seeds
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL

BUTTON
475
934
585
967
Show Seeds
show-seeds
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL

BUTTON
589
899
699
932
Select Ref. Seed
user-select-reference-seed
T
1
T
OBSERVER
NIL
NIL
NIL
NIL

SWITCH
921
1003
1091
1036
Build-Tertiary-Roads
Build-Tertiary-Roads
0
1
-1000

SWITCH
920
1038
1089
1071
Build-Primary-Roads
Build-Primary-Roads
0
1
-1000

SWITCH
921
1107
1136
1140
Independent-Tertiary-Roads
Independent-Tertiary-Roads
0
1
-1000

SWITCH
920
1072
1085
1105
Build-Developments
Build-Developments
0
1
-1000

BUTTON
605
715
715
748
Reserve Land
user-reserve-terrain
T
1
T
OBSERVER
NIL
NIL
NIL
NIL

BUTTON
609
749
715
782
Free Up Land
user-free-terrain
T
1
T
OBSERVER
NIL
NIL
NIL
NIL

BUTTON
603
785
715
818
NIL
show-building-neighbors
T
1
T
OBSERVER
NIL
NIL
NIL
NIL

SLIDER
6
1220
204
1253
number-of-park-developers
number-of-park-developers
0
20
5
1
1
NIL
HORIZONTAL

SLIDER
688
1114
881
1147
desired-park-land-cover
desired-park-land-cover
0
1
0.05
0.01
1
NIL
HORIZONTAL

INPUTBOX
438
1133
546
1213
min-park-parcel-size
4
1
0
Number

INPUTBOX
546
1133
655
1213
max-park-parcel-size
50
1
0
Number

SLIDER
696
1166
882
1199
POPULATION-VS-PARK
POPULATION-VS-PARK
0
100
50
1
1
NIL
HORIZONTAL

SLIDER
934
1161
1107
1194
Smoothness-Constraint
Smoothness-Constraint
0
10
6
1
1
NIL
HORIZONTAL

BUTTON
830
461
936
494
import-network
import-road-network-from-file user-file
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL

@#$#@#$#@
VERSION
-------
$Header: /home/cvs/netlogo/models/under\040development/cities/Cities.nlogo,v 1.48 2007-09-24 20:26:57 everreau Exp $


WHAT IT IS
----------
The Cities model allows a user to create a terrain and environment in which a set of builders will create a city.  Users can interrupt the city build and change the environment and then continue the city creation simulation.  The city consists of roads, parcels (sets of patches which are developed as a single unit), and buildings.  Parcels are zoned for specific types of usage, commercial, industrial, residential, or park.

HOW IT WORKS
------------
The user paints parameters onto the terrain, such as elevation, road grid constraints, and "honey" which attracts specific kinds of developers.  The user may also create multiple city seeds, or move the existing one.  The user may also draw primary roads and link them to the edge of the terrain, to simulate the city's major routes.

In addition the user can also set some of these parameters at a global level, affecting all patches.  There are also global variables constraining the number of developers, the ratio of land-use between the development types, minimum parcel sizes for different land uses, and many other factors.

Builders for each type of development, residential, commercial, industrial, and park move through the terrain, grouping patches into parcels and then attempting to "develop" them by putting a new building upon the parcel, or increasing the size of the current building.  Road builders move through the terrain building roads between areas, thus increasing their value.

At any time, the user can stop the model, paint new parameters onto the terrain, free up terrain that has been developed, draw primary roads, or change the land use ratios.  When the model is restarted, builders will respond to these changes.


HOW TO USE IT
-------------
Press GO and developers will begin building the city, starting from the SEED.

The RUNNING-DISPLAY chooser allows you to select a visualization of the terrain.  The Default view shows land use, and density, with lighter colors representing areas of higher density.

The OVER-DISPLAY chooser will augment the chosen display with other information.

The WATCH-DISPLAY switch turns display updates on or off.  When off, the model will run faster because it does not have to update patch colors.  if you have WATCH-DISPLAY off, you may use the SHOW-RUNNING-DISPLAY button to force a display update.

The OUTPUT-FILENAME is the prefix for model snapshots or movies that are captured.  You can turn on snapshot capturing with the CAPTURE-SCREEN-SHOT? switch.  If on, a snapshot of the View Window is saved every 100 ticks.  The snapshot is put into a file starting with OUTPUT-FILENAME, and then a sequence number.  If CAPTURE-MOVIE? is on, then a Quicktime movie is made, capturing a frame at every 100 ticks, and saved to OUTPUT-FILENAME.

In order to create different environments for the developers to work within, you can use the PARAMETER-PAINTING controls to make a terrain map.

DESCRIPTION OF CONTROLS
-----------------------
On the right hand side of the View Window are the PARAMETER-PAINTING Controls.

Below the View window are the model run controls.

PARAMETER PAINTING
-------------------
You "paint" much like a conventional graphics program, pressing the button to apply a brush to the terrain.  The BRUSH-SIZE and BRUSH-TYPE choosers allow you to control the brush dimensions.

BRUSH-RADIUS:  Determines the radius of the brush if a circle, and half the width if a square.

BRUSH-TYPE:  Determines if the brush is circular or square.

SHOW-<PATCH-VARIABLE>:  Shows in a visual manner the distribution of the parameter.  Lighter areas are higher in value.

INC-<PATCH-VARIABLE>:  Increases the value of the parameter according to a feathered filter.

DEC-<PATCH-VARIABLE>:  Decreases the value of the parameter variable according to a feathered filter.

SET-<PATCH-VARIABLE>:  Sets the patches within the brush dimensions to the current slider setting of the parameter.


GLOBAL VARIABLES ASSOCIATED WITH TERRAIN
----------------------------------------

GROUND-LEVEL:  Determines the current elevation of the terrain.

WATER-LEVEL:  Determines which elevation is the water level.  Patches with elevations lower than this will be water, above this they are land.


PARAMETERS ASSOCIAED WITH TERRAIN
-------------------------------------
ELEVATION: The elevation of the patch.  See GROUND-LEVEL and WATER-LEVEL.

INDUSTRIAL-HONEY: The higher this value, the more attractive the patch is to industrial developers.

RESIDENTIAL-HONEY: The higher this value, the more attractive the patch is to residential developers.

COMMERCIAL-HONEY: The higher this value, the more attractive the patch is to commercial developers.

PARAMETERS ASSOCIATED WITH ROAD PARAMETERIZATION
------------------------------------------------------

X-SCALE:  Determines the unit grid size in the x dimension.

Y-SCALE:  Determines the unit grid size in the y dimension.

DEV-X:  Determines the number of units of deviation in the +/- direction from the unit grid size in the x dimension.

DEV-Y:  Determines the number of units of deviation in the +/- direction from the unit grid size in the y dimension.

MAX-ROAD-CONCENTRATION:  Determines the maximum road concentration around a road segment.  According to the algorithm, when a road segment is considered for building, the ratio of road patches verses total patches surrounding and including the road segment must be less than the maximum road concentration for further consideration.  A max concentration of 0 will prevent the road network from looping, where a value of 100 will cause very dense road networks, that will eventually result in a solid area of pavement.

MANHATTAN-RATIO:  Perhaps a poor name for what it tries to describe.  When a road segment is considered for connecting two portions of the existing road network together, the ratio of the actual distance it takes to travel between the two points along the road network verses the Manhattan distance between the two points must be greater than this ratio.  Basically, it is a measure of tolerance.  The turtles will tolerate traveling up to a distance of this ratio times the Manhattan distance before it considers building a road.

DESIRED-ELEVATION: The optimum elevation for roads.

ELEVATION-ROAD-CONSTRAINT: The weight given to the DESIRED-ELEVATION for roads.  If it is higher, than roads will be very strongly constrained to the DESIRED-ELEVATION.  If it is low, they are weakly constrained.

MIN-CHANGE-IN-WORTH: The minimum value change in surrounding patches required to justify the building of a road.

CITY EDITING
------------
Cities can be edited at any stage of their development.

DRAW-PRIMARY: When pressed, the mouse can be used to draw a primary road on the terrain.  Hold the mouse button down to start the road, release to finish it.  It is best to move the mouse slowly when drawing.

ERASE-ROADS: Using the current brush size and radius, erase roads from the terrain when the mouse button is pressed.

ERASE P. ROADS: Same as above, but only primary roads.

ERASE-BUILDINDG: Same as above, but erases all buildings

CLEAR ROADS: Removes all roads, leaves other development

LEVEL TERRAIN: Sets all patch elevations to current ground level

ERASE-ALL-DEVELOPMENT: Removed all buildings and roads from the terrain.

LINK-PRIMARY-ROAD-TO-WORLD-EDGE: Makes a new primary road going from the seed or an existing primary road, to the edge of the world.

RESERVE-LAND: Using the current brush size and shape, you can paint areas of the terrain as reserved, preventing that land from being developed on.

FREE UP LAND: Same as above, but removes the reservation.

RESET: Removed all parameters and development from the terrain, returning it to it's original empty, flat state.

EXTENDING THE MODEL
-------------------
New developer types can be added by creating new developer breeds.

NETLOGO FEATURES
----------------
This model drove the development of the __INCLUDES feature, which allows model code to be broken up across several files.  It also uses the NetLogo Extensions API to implement many of it's own procedures in Java.

RELATED MODELS
--------------
The "Urban Suite" models were developed as an introduction to agent-based modeling of cities, of which this model is an example.

CREDITS AND REFERENCES
----------------------
The Cities model was developed as part of the Procedural Modeling of Cities project, under the sponsorship of NSF ITR award 0326542, Electronic Arts & Maxis.

Please see the project web site ( http://ccl.northwestern.edu/cities/ ) for more information.
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
NetLogo 4.0beta6
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
Line -7500403 true 150 150 30 225
Line -7500403 true 150 150 270 225

@#$#@#$#@
