
extensions[nw table]


globals[
  
  ;;;;;;;;;;;;;;
  ;; Headless vars (widgets in non-headless mode)
  ;;;;;;;;;;;;;;
  
  ;; setup
  initial-centers
  mixture-proba-diffusion
  centers-distribution
  max-sampling-bw-centrality
  grid-size
  
  ;;runtime
  max-new-centers-number
  neigh-type
  random-center-number?
  lambda
  beta
  
  
  ;; new centers at current step
  new-centers
  
  ;; note : random spatial distrib :
  ; patches in fixed order to have rigorous drawing of proba ?
  ; (note that shuffling in agentset should not perturbate if exactly random)
  ;  -> test that ... OK
  
  
]

; centers
breed[centers center]

;nw nodes
breed[nodes node]

;roads
undirected-link-breed[roads road]

turtles-own [
  node-bw-centrality 
]


centers-own[
  weight
  neigh-nodes
]

roads-own[
  ;variable to be used by nw primitives
  road-length 
  bw-centrality
  ; same for more generic link procedure
  edge-length
  
]

patches-own [
  ;; land-value :  general variable common to all models
  land-value
  
  ; proba for distrib of centers in case of single nw evol ; exponential proba distrib
  exp-proba
  
  ;;;;;;;
  ;; co-dev model variables
  ;;;;;;;
  
  ; proba for distrib of centers in case of co-development ("luti")
  ;   --> simple discrete choice model : P(i) = exp(\beta (\lanbda * access - density))/exp(sum(...))
  ;        with params : \beta : DC dispersion param ; \lambda : compromise density / transportation
  luti-proba
  
  ;; accessibility
  ;;  --> defined as betw-centrality, but can be distance to centers or to nw (Alsonso model)
  accessibility
  
  ;;density : N-centers / S
  density
  
  
  
]
;;;;;;;;;;;;;;;;;;;
;; additional agentset function
;;;;;;;;;;;;;;;;;;;



;;remove a particular agent from agentset
;; dirty in complexity ! (goes through all agents)
;;  Returned type is that of the agentset (logical)
to-report remove-from-agentset [agent agentset]
  if agentset = nobody [report nobody]
  report agentset with [self != agent]
end;;Euclidian distance calculation utilities functions



;turtle or patch procedure reporting the distance to a given link
to-report distance-to-link [l]
  let x1 0 let y1 0 let x2 0 let y2 0 let e1 0 let e2 0 let x 0 let y 0
  ask l [set e1 end1 set e2 end2]
  ifelse is-turtle? self [set x xcor set y ycor][set x pxcor set y pycor]
  ask e1[set x1 xcor
  set y1 ycor]
  ask e2 [set x2 xcor
  set y2 ycor]
  let m1m sqrt (((x1 - x ) ^ 2) + ((y1 - y) ^ 2))
  let m2m sqrt (((x2 - x ) ^ 2) + ((y2 - y) ^ 2))
  let m1m2 sqrt (((x1 - x2 ) ^ 2) + ((y1 - y2) ^ 2))
  if m1m = 0 or m2m = 0 [report 0]
  if m1m2 = 0 [report m1m]
  let cost1 (((x - x1)*(x2 - x1)) + ((y - y1)*(y2 - y1)))/(m1m * m1m2)
  let cost2 (((x - x2)*(x1 - x2)) + ((y - y2)*(y1 - y2)))/(m2m * m1m2)
  
  if cost1 < 0 [report m1m]
  if cost2 < 0 [report m2m]
  report m1m * sqrt abs (1 - (cost1 ^ 2))
end





;link procedure which calculates the distance to a given point
to-report distance-to-point [x y]
  let x1 0 let y1 0 let x2 0 let y2 0
  ask end1[set x1 xcor
  set y1 ycor]
  ask end2 [set x2 xcor
  set y2 ycor]
  let m1m sqrt (((x1 - x ) ^ 2) + ((y1 - y) ^ 2))
  let m2m sqrt (((x2 - x ) ^ 2) + ((y2 - y) ^ 2))
  let m1m2 sqrt (((x1 - x2 ) ^ 2) + ((y1 - y2) ^ 2))
  if m1m = 0 or m2m = 0 [report 0]
  if m1m2 = 0 [report m1m]
  let cost1 (((x - x1)*(x2 - x1)) + ((y - y1)*(y2 - y1)))/(m1m * m1m2)
  let cost2 (((x - x2)*(x1 - x2)) + ((y - y2)*(y1 - y2)))/(m2m * m1m2)
  
  if cost1 < 0 [report m1m]
  if cost2 < 0 [report m2m]
  report m1m * sqrt abs (1 - (cost1 ^ 2))
end


;report a turtle on the projection of point x y on the calling link
to-report projection-of [x y]
  let x1 0 let y1 0 let x2 0 let y2 0
  ask end1[set x1 xcor
  set y1 ycor]
  ask end2 [set x2 xcor
  set y2 ycor]
  let m1m sqrt (((x1 - x ) ^ 2) + ((y1 - y) ^ 2))
  let m2m sqrt (((x2 - x ) ^ 2) + ((y2 - y) ^ 2))
  let m1m2 sqrt (((x1 - x2 ) ^ 2) + ((y1 - y2) ^ 2))
  if m1m = 0 or m1m2 = 0 [report end1]
  if m2m = 0 [report end2]
  let cost1 (((x - x1)*(x2 - x1)) + ((y - y1)*(y2 - y1)))/(m1m * m1m2)
  let cost2 (((x - x2)*(x1 - x2)) + ((y - y2)*(y1 - y2)))/(m2m * m1m2)
    
  let mq 0 let xx 0 let yy 0 let m1q 0
  
  ifelse cost1 < 0 [
     report end1

  ]
  [
  ifelse cost2 < 0 [
     report end2

  ]
  [set mq m1m * sqrt abs (1 - (cost1 ^ 2))
   set m1q sqrt ((m1m ^ 2) - (mq ^ 2))  
   set xx x1 + m1q * (x2 - x1) / m1m2
   set yy y1 + m1q * (y2 - y1) / m1m2
   
   if count turtles-on patch xx yy = 0 [
     ask patch xx yy [sprout 1 [
       setxy xx yy
       ]
     ]
   ]
  report one-of turtles-on patch xx yy
   ]
  ]
  
end



;;same as projection but doesn't pose the problem of killing the turtle or not (which survived sometimes anyway, why? -> because internally created? lost the pointer? :(...)
to-report coord-of-projection-of [x y]
  let x1 0 let y1 0 let x2 0 let y2 0
  ask end1[set x1 xcor
  set y1 ycor]
  ask end2 [set x2 xcor
  set y2 ycor]
  let m1m sqrt (((x1 - x ) ^ 2) + ((y1 - y) ^ 2))
  let m2m sqrt (((x2 - x ) ^ 2) + ((y2 - y) ^ 2))
  let m1m2 sqrt (((x1 - x2 ) ^ 2) + ((y1 - y2) ^ 2))
  if m1m = 0 or m1m2 = 0 [report end1]
  if m2m = 0 [report end2]
  let cost1 (((x - x1)*(x2 - x1)) + ((y - y1)*(y2 - y1)))/(m1m * m1m2)
  let cost2 (((x - x2)*(x1 - x2)) + ((y - y2)*(y1 - y2)))/(m2m * m1m2)
    
  let mq 0 let xx 0 let yy 0 let m1q 0
  
  ifelse cost1 < 0 [
     report list [xcor] of end1 [ycor] of end1

  ]
  [
  ifelse cost2 < 0 [
     report list [xcor] of end2 [ycor] of end2

  ]
  [set mq m1m * sqrt abs (1 - (cost1 ^ 2))
   set m1q sqrt ((m1m ^ 2) - (mq ^ 2))  
   set xx x1 + m1q * (x2 - x1) / m1m2
   set yy y1 + m1q * (y2 - y1) / m1m2
   
   report list xx yy
   ]
  ]
  
end



;;;;;;;;;;;;;;;;;;;
;; Utilities "specific" to CA sprawl model, rather generic however
;;;;;;;;;;;;;;;;;;;

;;  Issues with breeds --> again in specific model














;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Link Utilities
;;;;;;;;;;;;;;;;;;;;;;;;;;




;;Get the "print" of a link
;;ie the patches he intersects
;; @reports list of patches intersecting link
to-report footprint
  ;;difficult, because can intersect small pieces of patch
  ;;and therefore "jump" over one if makes regular jumps
  ;;why not make very small regarding patch-size
  ;;pb: will it not be to long to compute ?
  ;;ok, take compromise, function will not be "exact"
  let e2 end2 let res []
  ask end1 [
    let obj [patch-here] of e2
    hatch 1 [
      set heading towards e2
      let current-patch patch-here
      while [current-patch != obj][
        ;;can't be blocked at one side of the world
        ;;because would be on finish !
        fd 0.05
        if patch-here != current-patch [set res lput current-patch res set current-patch patch-here]
      ]
      die
    ]
  ]
  report res
end


;;;;;;;;
;; reports a two-item list of x and y coordinates, or an empty
;; list if no intersection is found
;; © Code copied from NL examples
to-report intersection-with-link [t1 t2]
  if [xcor] of [end1] of t1 = [xcor] of [end2] of t1 and [ycor] of [end1] of t1 = [ycor] of [end2] of t1 [report []]
  if [xcor] of [end1] of t2 = [xcor] of [end2] of t2 and [ycor] of [end1] of t2 = [ycor] of [end2] of t2 [report []]
  let m1 [tan (90 - link-heading)] of t1
  let m2 [tan (90 - link-heading)] of t2
  ;; treat parallel/collinear lines as non-intersecting
  if m1 = m2 [ report [] ]
  ;; is t1 vertical? if so, swap the two turtles
  if abs m1 = tan 90
  [
    ifelse abs m2 = tan 90
      [ report [] ]
      [ report intersection-with-link t2 t1 ]
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
      report list x y
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
  report list x (m1 * x + c1)
end

;;© NL Examples
to-report x-within? [x]  ;; turtle procedure
  report abs (link-xcor - x) <= abs (link-length / 2 * sin link-heading)
end

;;© NL Examples
to-report y-within? [y]  ;; turtle procedure
  report abs (link-ycor - y) <= abs (link-length / 2 * cos link-heading)
end

;;© NL Examples
to-report link-xcor
  report ([xcor] of end1 + [xcor] of end2) / 2
end

;;© NL Examples
to-report link-ycor
  report ([ycor] of end1 + [ycor] of end2) / 2
end;;agentset/list functions

to-report to-list [agentset]
  let res []
  ask agentset [
    set res lput self res 
  ]
  report res
end


;;list to agentset - beware, O(n_agents*length(list))
;;ok
;;should it be in TypeUtilities.nls ?
to-report to-agentset [l]
  if length l = 0 [report nobody]
  if is-turtle? first l [report turtles with [member? self l]]
  if is-patch? first l [report patches with [member? self l]]
  if is-link? first l [report links with [member? self l]]
end



;; normalised norm-p of a vector
;; in this file because applies on a list

to-report norm-p [p l]
  let res 0
  let n length l
  foreach l [set res res + (? ^ p)]
  report (res / n) ^ (1 / p)
end


;;sequence function
to-report seq [from t by]
  let res [] let current-val from let n 0
  ifelse by = 0 [set n t][set n (floor ((t - from)/ by) + 1)]
  repeat n [
     set res lput current-val res
     set current-val current-val + by
  ]
  report res
end

to-report rep [element times]
  let res [] repeat times [set res lput element res] report res
end

to-report incr-item [i l val]
  report replace-item i l (item i l + val)
end


to-report concatenate [lists]
  let res []
  foreach lists [
    foreach ? [
      set res lput ? res 
    ] 
  ]  
  report res
end



;;;;;;;;;;
;; generalized min,max,sum
;;;;;;;;;;

; note : would be better to report \infty for gen-min (generally used for comparisons) but does not exists
to-report gen-min [l]
  ifelse length l = 0 [
    report 0
  ][
     report min l
  ]
end

to-report gen-max [l]
  ifelse length l = 0 [
    report 0
  ][
     report max l
  ]
end

to-report gen-sum [l]
  ifelse length l = 0 [
    report 0
  ][
     report sum l
  ]
end

to-report gen-mean [l]
  ifelse length l = 0 [
    report 0
  ][
     report mean l
  ]
end;;;;;;;;;;;;;;;;;;;;;;
;; Generic NW functions
;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;
;; Connexify nw following std algo 
;;
;; Uses all turtles and links
;;;;;;;;;;;;
to connexify-global-network
  nw:set-context turtles roads
  let clusters nw:weak-component-clusters
  
  while [length clusters > 1] [
    let c1 first clusters
    let mi sqrt (world-width ^ 2 + world-height ^ 2) ;biggest possible distance
    ; rq : obliged to go through all pairs in nw. the same as merging clusters and taking closest point
    ; second alternative is less dirty in writing but as merging is O(n^2), should be longer.
    let mc1 nobody let mc2 nobody
    foreach but-first clusters [
       let c2 ?
       ask c1 [ask c2 [let d distance myself if d < mi [set mi d set mc1 myself set mc2 self]]]
    ]
    ask mc1 [create-road-with mc2 [new-road]]
    set clusters nw:weak-component-clusters
  ]
  
end;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Basic Stat functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;

; histogram retrieving count list
; nbreaks = number of segments
; reports counts
to-report hist [x nbreaks]
  ifelse x != [] [
  let counts rep 0 nbreaks
  let m min x let ma max x
  foreach x [
    let index floor ((? - m)/(ma - m)*(nbreaks - 1))
    set counts replace-item index counts (item index counts + 1)
  ]
  
  report counts
  ][
    report []
  ]
end

;;;;;;;;;;;;;;;;;;;;
;; center procedures
;;;;;;;;;;;;;;;;;;;;

;;create a new center and reports it
to-report new-center
  let c nobody
  
  ;; random drawing procedure is selected in subproc
  let coords random-coords
  
  create-centers 1 [
    ; random weight \in [0,1]
    set weight random-float 1
    set neigh-nodes []
    set shape "circle" set color blue
    set size (5 + weight) * 2 / patch-size set hidden? false
    setxy first coords last coords
    set c self
  ]
  report c
end


to-report random-coords
  ; draws random coordinates
  ; according to a given proba distrib
  
  if centers-distribution = "uniform"[
     ; uniform spatial distribution
     report (list random-xcor random-ycor)
  ]
  
  if centers-distribution = "exp-mixture" [
    ; use patch variable proba set at setup
    ; as precised in globals, not directly exact
    let s 0 let p random-float 1 let res []
    ask patches [
      if length res = 0 [
        set s s + exp-proba
        if p < s [set res (list pxcor pycor)] 
      ]
    ]
    
    ; add a random noise \in [-0.5,0.5] as generated corrdinates will only be integers
    set res (list (first res + random-float 1 - 0.5) (last res + random-float 1 - 0.5))
    
    report res
  ]
  
  
  if centers-distribution = "luti" [
     ; co-evolution of land-use and network
     ; here proba depend on local patch values, computed before as a feedback from network and previous land values
     ; DEBUG ;report (list random-xcor random-ycor)
      
     ; P(i) = exp(\beta * land-value)/ sum (exp(\beta * land-value))  for each patch
      let s 0 let p random-float 1 let res []
      let K  sum [exp (beta * land-value)] of patches
      ask patches [
       if length res = 0 [
        set s s + (exp (beta * land-value) / K)
        if p < s [set res (list pxcor pycor)] 
      ]
    ]
    
    ; add a random noise \in [-0.5,0.5] as generated corrdinates will only be integers
    set res (list (first res + random-float 1 - 0.5) (last res + random-float 1 - 0.5))
    
    report res
      
  ]
  
end


; center procedure that reports network nodes in neigh with a given definition
to-report direct-neighbor-nodes
    if neigh-type = "closest" [
      report (other turtles) with-min [distance myself]
    ]
    
    if neigh-type = "shared" [
    ; do neighborhood computation by hand
    let c self
    
    ; search only on links not already linked ?
    ;  -> no because leads to crossing roads as a point on the other side of the road may be considered as neighbor
    ;     better report real neighs and not link later 
    let p other turtles ; with [not link-neighbor? myself]
    
    let n []
    ask p [
      let p0 self
      ; r0 = d(P_0,C)
      let r0 distance c
      let neigh? true
      ask (other p)[
        set neigh? (neigh? and ((distance p0 > r0) or (distance c > r0)))
      ]
      if neigh? [set n lput p0 n]
    ]
    
    ; report as agentset
    report to-agentset n
    ]
end


; procedure called at the creation of new centers,
; but before applying barycenter/neighborhood algorithm
;    -> additional rule not developed in initial reference ; but at least a similar one has been implemented to obtain such shapes.
to-report connect-to-network
  let res []
  
  ; to be exact, has to check all links as criteria an nodes is not enough to determine closest links (can be arbitrary close to a link with arbitrary far extremities, even in "regular" nw ? )
  let r0 distance one-of (other turtles) with-min [distance myself] ; dirty in O(n2)
  
  ; coord list of closest projection on a link if exists
  ; if empty, used as boolean marker
  let c []
  ; potential new extremities in the case of connection to network
  let pot-extremities []
  let closest-link one-of links with-min [distance-to-point ([xcor] of myself) ([ycor] of myself)] ; can be nobody
  if closest-link != nobody [
    ask closest-link [
      if distance-to-point ([xcor] of myself) ([ycor] of myself) < r0 [
         ; in that case a new node will be created, coords can be memorized to hatch later (link cannot create turtle)
         ; and ask current link to DIE
         set c coord-of-projection-of ([xcor] of myself) ([ycor] of myself)
         set pot-extremities (list end1 end2)
         die
      ]
    ]
  ]
  
  set res pot-extremities
  
  ; if projection was found to exist (== corrds are not empty), link center to the network
  if length c > 0 [
     ; new intersection
     hatch 1 [
       ; make it move to good location
       setxy first c last c
       ;linked by new road
       create-road-with myself [new-road]
       ; and extremities of old link
       create-road-with first pot-extremities [new-road]
       create-road-with last pot-extremities [new-road]
       
     ]
  ]
  
  
  report res
  
end


;;;;;;;;;;;;;;;;;;;;;;;
;; indicator functions
;;;;;;;;;;;;;;;;;;;;;;;



;; total nw length
to-report network-length
  report sum [link-length] of roads
end

;; approx nw diameter
;;  ( computed on random fraction of nw, for computational reasons with large nw)
to-report network-diameter
  report get-approximate-diameter
end

;; single run for experiment
;;

to go-experiment
  
  ; for now fixed maxiteration
  repeat 50 [
    go
  ]
  
  ;; then reporters called from OMole
  
  
end;;;;;;;;;;;;;;;;;;
;; main
;;;;;;;;;;;;;;;;;;




;; go for one time step
to go
  
  ; first update land values variables
  evolve-land-values
  
  ; construct new centers
  construct-new-centers
  
  ; evolve network
  evolve-network
  
  ; update viz
  update-visualization
  
  tick
end



to evolve-land-values
  ;output-print "updating land values"
  
  
  ; other cases : value proportional to proba, does not evolve
  if centers-distribution = "luti" [
  
    ;; update land value vars : density and accessibility
    ;; grid is given by patches
    
    ;; density
    ;;  note : patch size is arbitrary, normalize var after
    ask patches [set density count centers-here] let ma max [density] of patches ask patches [set density density / ma]
  
  
    ;; accessibility
    ;; need to update bw centralities
    setup-nw-analysis
    compute-node-bw-centrality
    set ma max [node-bw-centrality] of turtles
    ask patches [set accessibility gen-mean [node-bw-centrality] of turtles-here / (max list ma 1)]
    
    ;; update value
    ask patches [set land-value lambda * accessibility + (1 - lambda) * (1 - density)]
    
    ;; diffuse land value to obtain sort of smoothing
    repeat 10 [diffuse land-value 0.5]
    
  ]

end


to construct-new-centers
  
  ; hide centers (to hightlight new after)
  ask centers [set hidden? true]
  
  ; random new centers number
  let new-centers-number 0
  ifelse random-center-number?[set new-centers-number 1 + (random max-new-centers-number)][set new-centers-number max-new-centers-number]
  
  set new-centers []
  ; assume each are drawn independantly according to a given spatial proba distribution
  repeat new-centers-number[
     set new-centers lput new-center new-centers
  ]
  set new-centers to-agentset new-centers ; dirty in complexity :/
  
  
  
end

to evolve-network
  ;output-print "evolving nw"
  
  let nodes-to-connect []
  ; for each new center, find neighbor nodes
  ask new-centers [
    
     ; supplementary rule : if new center is closer from nw than another node, connects it perpendicularly
     ; complexity
     ;  -> returns nodes that are indeed neighs but that should not be connected because center perp. connected to the network
     let not-neighs connect-to-network
    
     ; find neighbors ; checking of neigh condition here is detailed in direct-neighbor-nodes function
     set neigh-nodes direct-neighbor-nodes with [not link-neighbor? myself]
     ; remove potential extremities of old link
     foreach not-neighs [set neigh-nodes remove-from-agentset ? neigh-nodes]
     ;show neigh-nodes
     if neigh-nodes != nobody [
       ask neigh-nodes [
         set nodes-to-connect lput self nodes-to-connect
       ]
     ]
  ]
  
  ; remove duplicates from nodes to connect
  ; then connects each to corresponding centers
  set nodes-to-connect remove-duplicates nodes-to-connect
  
  ;show nodes-to-connect
  
  
  foreach nodes-to-connect [
     ; find centers such that ? \in neigh-nodes
     ; connect node to weighted barycenter of these
     ; then connect new node to each (induces local tree-like structure)
     let current-centers-to-connect new-centers with [neigh-nodes != nobody and member? ? neigh-nodes]
     ifelse count current-centers-to-connect = 1 [
        ask one-of current-centers-to-connect [create-road-with ? [new-road]]
     ][
       let x-bar sum ([weight * xcor] of current-centers-to-connect) / sum ([weight] of current-centers-to-connect)
       let y-bar sum ([weight * ycor] of current-centers-to-connect) / sum ([weight] of current-centers-to-connect)
       ;create barycenter and connects it
       create-nodes 1 [
         setxy x-bar y-bar set hidden? true
         create-road-with ? [new-road]
         create-roads-with current-centers-to-connect [new-road]
       ]
     ]
  ]
  
  
  
  
  ;; supplementary connexification step
  connexify-global-network
  
  
end
  


;; Network analysis function

to setup-nw-analysis
  ; set context
  nw:set-context turtles roads
  
  ; reinitialize specific variables
  ask roads [
    set road-length link-length
    set bw-centrality 0
  ]
  
  ask turtles [set node-bw-centrality 0]
  
end


;;;
;; Gets proxy of nw diameter
to-report get-approximate-diameter
  let res 0
  ask n-of min list count centers max-sampling-bw-centrality centers [
    ask n-of min list (count centers - 1) max-sampling-bw-centrality other centers [
      let d nw:weighted-distance-to myself "road-length"
      if d != false [
        set res max list res d 
      ]
    ]
  ]
  report res
end


to compute-road-bw-centrality
  ; dirty, computed two times
  
  ; nw too big to compute on all pairs
  ; take random samples, should be a good proxy (cv speed ?)
  
  ask n-of min list count centers max-sampling-bw-centrality centers [
    ask n-of min list (count centers - 1) max-sampling-bw-centrality other centers [
      let p nw:weighted-path-to myself "road-length"
      if p != false [
        foreach p [
          ask ? [
            set bw-centrality (bw-centrality + 1)
          ]
        ]
      ]
    ] 
  ]
  
  ; set thicnkess
  ask roads [
    set thickness (bw-centrality / (count centers) ^ 2)
  ]
end


to compute-node-bw-centrality
  ; dirty, computed two times
  
  ; nw too big to compute on all pairs
  ; take random samples, should be a good proxy (cv speed ?)
  
  ask n-of min list count centers max-sampling-bw-centrality centers [
    ask n-of min list (count centers - 1) max-sampling-bw-centrality other centers [
      let p nw:turtles-on-weighted-path-to myself "road-length"
      if p != false [
        foreach p [
          ask ? [
            set node-bw-centrality (node-bw-centrality + 1)
          ]
        ]
      ]
    ] 
  ]
end




;; procedure to check if some roads are crossing in the overall nw
to-report crossing-roads?
  ; do it fastest way through list
  let l to-list links
  let n length l
  let i 0
  let res []
  repeat (n - 1) [
    let t1 item i l let t2 item (i + 1) l
    if intersection-with-link t1 t2 != [] [set res lput (list t1 t2) res]
    set i i + 1
  ]
  report res
  
end







;;;;;;;;;;;;;;;;;
;; triangulation functions
;;;;;;;;;;;;;;;;;

;;
;; Requires nw, table extensions loaded
;; Utils : ListUtilities
;;

;; get weak pavage of a plan
;;   i.e. returns all closed polygons created by a graph.
;; 
;;   OK proven, as all paths between two vertices will be taken
to-report pavage [vertices edges]
  
  ;; set network
  nw:set-context vertices edges
  ask edges [set edge-length link-length]
  
  ;; init table for storing polygons as lists
  ;; (needs a set storage as recurrences will appear)
  let polygons table:make
  
  ;; algo :
  ;;   for each link, iterate other paths between extremities, not including the link (need to check minimality condition)
  
  ;; need to get diameter of the graph first
  ;; as weighting value equivalent to infinity
  ;; no easy way to get it ?!! dirty dirty
  let l-vertices to-list vertices let n length l-vertices let i 0 let diameter 0
  repeat (n - 1)[let j (i + 1) repeat (n - i - 1)[ask item i l-vertices [set diameter max (list diameter nw:weighted-distance-to (item j l-vertices) "edge-length")] set j j + 1] set i (i + 1)]
  ;show diameter
  ; diameter is exactly the longest path in graph
  
  
  ask edges [
;    ; reinitialize edge-length
;    ask other edges [set edge-length link-length]
;    ; and "supress" itself
;    set edge-length 100 * diameter
;    
;    ; try with one single shortest path (not exact)
;    let e2 end2 ask end1 [let p nw:weighted-path-to e2 "edge-length" if not member? myself p [
;        set p lput myself p
;        let r []
;        foreach p [set r lput (list ([[who] of end1] of ? ) ([[who] of end2] of ? ) ) r]
;        set r sort-by [(first ?1 < first ?2) or (first ?1 = first ?2 and last ?1 < last ?2)] r
;        table:put polygons r r
;        
;        ]
;    ]
    
    ;; exact algo : use marker to set context of network (reset for each edge ? at each internal iteration !) ; and ask both edges to consume links putting iteratively markers on each

;    
  ]
  
  ;; we return keys of hashtable, corresponding exactly to found polygons
  report table:keys polygons
  
end


;; report x y coordinates of barycenters of list of provided polygons
to-report barycenters [polygons]
  let res []
  ; first recreates polygons as agentsets
  let p []
  foreach polygons [let l [] foreach ? [ set l lput (turtle last ?) (lput turtle (first ?) l) ] set p lput to-agentset remove-duplicates l p]
  
  foreach p [
    set res lput (list ((sum [xcor] of ?) / count ?)  ((sum [ycor] of ?) / count ?)) res
  ]
  report res
end



to-report interior-patches [polygon]
  let res []
  ; first recreates polygons as agentsets
  let l-vertices [] let l-edges [] foreach polygon [ set l-vertices lput (turtle last ?) (lput turtle (first ?) l-vertices) set l-edges lput (road first ? last ?) l-edges]
  let vertices to-agentset remove-duplicates l-vertices
  let edges to-agentset l-edges
  let barycenter nobody crt 1 [setxy sum [xcor] of vertices / count vertices sum [ycor] of vertices / count vertices set barycenter self]
  let l-interior []
  ask patches [
    let p self
    sprout 1 [
        create-road-with barycenter [
          let inside? true
          ask edges [
            set inside? (inside? and intersection-with-link self myself = [])
          ]
          if inside? [set l-interior lput p l-interior]
          die
        ]
        die
      ]
  ]
  
  ask barycenter  [die]
  show l-interior
  report to-agentset l-interior
end


to test-pavage
;  let coords barycenters pavage turtles links
;  foreach coords [
;    crt 1 [setxy first ? last ? set color yellow set size 2] 
;  ]

  ;; test interiors and overall accuracity
  foreach pavage turtles links [
    let i interior-patches ?
    if i != nobody [ask i [ 
      set pcolor red
    ]
    ]
  ]

end





;;;;;;;;;;;;;;;;;;;;;
;; roads procedures
;;;;;;;;;;;;;;;;;;;;;
to new-road
  set thickness 0.05 set color green
end





;; partial setup procedure for openmole call
;;  (agents are killed anyway ?)
to setup-config
  if centers-distribution = "exp-mixture" [
    setup-exp-mixture
  ]
  
  if centers-distribution = "luti" [
    setup-luti 
  ]
  
end
;;;;;;;;;;;;
;; setup functions
;;;;;;;;;;;;



;; setup world size and grid (patch size etc)
to setup-world
  ; constant values : patch-size * npatches-y = 600 ; patch-size * npatches-x = 800 [change hardcoded values to change fixed width and height]
  set-patch-size 600 * grid-size / 100
  resize-world 0 (800 / patch-size) 0 (600 / patch-size)

end


to setup-exp-mixture
  
    ; set gaussian mixture probability distribution
    ; start from number of centers with max proba
    ; and diffuse around.
    ; Not gaussian but exponential, as power decrease in radius from initial cell.
    ask patches [set exp-proba 0]
    ask n-of initial-centers patches [
      set exp-proba 1
    ]
    repeat 100 [
      diffuse exp-proba mixture-proba-diffusion
    ]
    ; normalize proba
    let ma sum [exp-proba] of patches
    ask patches [set exp-proba exp-proba / ma]
    
    ; color patches following proba
    let mi min [exp-proba] of patches set ma max [exp-proba] of patches
    ask patches [set pcolor scale-color red exp-proba mi ma]
    
    ; setup land-values
    ask patches [set land-value exp-proba]
    
end


;; setup for the luti model
;;  ; Q : option for gis-based initial config ?
to setup-luti
  
  ; uniform initial land values
  ask patches [set land-value 0]
  
  ; random initial config -> use initial centers var
  repeat initial-centers [
     let c new-center
  ]
  
  ;; connect them by connexifying
  connexify-global-network
  
end
  ;;;;;;;;;;
;; specific setup procedure
;;;;;;;;;;


to setup
  ca
  reset-ticks

  ; setup globals for headless mode
  show "Setting up globals"
  setup-globals

  show "World"
  setup-world
  
  show "Config"
  setup-config
  
end

;; default values to run in headless mode
to setup-globals
  set initial-centers 2
  set mixture-proba-diffusion 0.8
  set centers-distribution "luti"
  set max-sampling-bw-centrality 200
  set grid-size 3
  
  ;;runtime
  set max-new-centers-number 2
  set neigh-type "shared"
  set random-center-number? false
  set lambda 0.5
  set beta 10
  
  
end

;; setup parameters during openmole experiments
to setup-experiment [l b]
  show (word "Running with params : lambda = " l " - beta = " b)
  reset-ticks
  setup-globals setup-config
  set lambda l set beta b
end
;;;;;;;;;;;
;; Visualization functions
;;;;;;;;;;;


to update-visualization
  
  ;; patches values
  let ma max [land-value] of patches let mi min [land-value] of patches
  if ma > mi [ask patches [set pcolor scale-color red land-value mi ma]]
  
  ;; bw centrality of links
  ;setup-nw-analysis
  ;compute-road-bw-centrality
  
  
end




@#$#@#$#@
GRAPHICS-WINDOW
19
10
839
653
-1
-1
18.0
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
44
0
33
0
0
1
ticks
30.0

SLIDER
905
136
1124
169
_max-new-centers-number
_max-new-centers-number
0
20
2
1
1
NIL
HORIZONTAL

CHOOSER
1001
23
1158
68
_centers-distribution
_centers-distribution
"uniform" "exp-mixture" "luti"
2

BUTTON
1180
244
1243
277
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
1106
245
1172
278
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

PLOT
905
285
1065
405
Degree distrib
NIL
log (k)
0.0
10.0
0.0
10.0
true
false
"" "set-plot-pen-mode 1\nhistogram [ln max (list 1 count road-neighbors)] of turtles"
PENS
"pen-0" 1.0 0 -7500403 true "" ""

MONITOR
908
415
967
460
centers
count centers
17
1
11

MONITOR
972
415
1029
460
roads
count roads
17
1
11

BUTTON
909
472
1022
505
bw-centrality
setup-nw-analysis\ncompute-road-bw-centrality\nupdate-plots
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
913
515
1073
635
bw-centrality ranking
NIL
NIL
0.0
1.0
0.0
1.0
true
false
"" "set-plot-pen-mode 1\n;set-histogram-num-bars 20000\n;histogram [bw-centrality] of roads\n;set-plot-x-range 0 100\n;let i 1\n;let h (hist ([ln bw-centrality] of roads with [bw-centrality > 0]) 100)\n;set-plot-y-range 0 max h\n;foreach h [\n;  plotxy (ln i) ?\n;  set i i + 1\n;]"
PENS
"default" 1.0 0 -16777216 true "" ""

SWITCH
1132
129
1351
162
_random-center-number?
_random-center-number?
0
1
-1000

CHOOSER
907
172
1045
217
_neigh-type
_neigh-type
"closest" "shared"
1

SLIDER
898
33
997
66
_initial-centers
_initial-centers
0
10
2
1
1
NIL
HORIZONTAL

BUTTON
922
248
985
281
NIL
go
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
783
76
993
109
_mixture-proba-diffusion
_mixture-proba-diffusion
0
1
0.8
0.1
1
NIL
HORIZONTAL

BUTTON
1031
472
1101
505
crossings
show length crossing-roads?
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
1069
284
1229
404
l(N)
nodes
nw length
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plotxy (count turtles) (network-length)"

TEXTBOX
903
14
1053
32
Setup\n
11
0.0
1

TEXTBOX
904
113
968
131
Runtime
11
0.0
1

SLIDER
999
72
1091
105
_grid-size
_grid-size
0
20
2.9
0.1
1
NIL
HORIZONTAL

SLIDER
1229
28
1468
61
_max-sampling-bw-centrality
_max-sampling-bw-centrality
0
500
300
1
1
NIL
HORIZONTAL

OUTPUT
1189
552
1415
673
10

SLIDER
1181
189
1273
222
_lambda
_lambda
0
1
0.9
0.05
1
NIL
HORIZONTAL

SLIDER
1276
189
1368
222
_beta
_beta
0
100
75
1
1
NIL
HORIZONTAL

TEXTBOX
1181
175
1331
193
Luti-params
11
0.0
1

TEXTBOX
1229
10
1379
28
Indicators
11
0.0
1

@#$#@#$#@
## WHAT IS IT?

Street NW growth geometrical model, from [Barthelemy, Flammini 2008],[Barthelemy, Flammini 2009].

## HOW IT WORKS

See paper.

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
