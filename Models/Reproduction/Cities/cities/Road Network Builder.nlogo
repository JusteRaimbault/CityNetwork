breed [ intersections intersection ]
undirected-link-breed [ tertiary-roads tertiary-road ]
undirected-link-breed [ primary-roads primary-road ]

intersections-own [
   x
   y
   original-xcor
   original-ycor

   temp-id
   ]

;links-own [ primary-road? ]

globals [
  ideal-segment-length

  ; mouse interaction
  last1
  last2
  last-link
  mouse-clicked?
  ]

to setup-grid
  ca
  set ideal-segment-length world-width / (road-network-size + 1)
  let n 0
  create-intersections road-network-size * road-network-size
  [
    set y (floor (n / road-network-size))
    set x (n mod road-network-size)
    set xcor min-pxcor - 0.5 + (world-width ) * (x + 1) / (road-network-size + 1)
    set ycor min-pycor - 0.5 + (world-height ) * (y + 1) / (road-network-size + 1 )
    set n (n + 1)
  ]
  finish-setup
end

to setup-radial
  ca
  set ideal-segment-length world-width / (road-network-size + 1)
  let current-radius ideal-segment-length
  let current-theta 0
  let current-perimeter 2 * PI * current-radius
  while  [ current-radius < world-width * sqrt(2) / 2 ]
  [
    create-intersections 1
    [
      let done? false
      while [ not done? ]
      [
        if( current-theta >= 359)
        [
          set current-radius current-radius + ideal-segment-length
          set current-perimeter 2 * current-radius * PI
          set current-theta 0 ; (current-theta mod 360)

          if (current-radius >= world-width * sqrt(2) / 2)
          [ set done? true ]
        ]
        set heading current-theta
        if (can-move? (current-radius + 1))
        [
          fd current-radius
          set done? true
        ]
        set current-theta current-theta + 360 / (floor (current-perimeter / ideal-segment-length ))
      ]
    ]
  ]
  finish-setup
end

to finish-setup
  ask intersections
  [
    set original-xcor xcor
    set original-ycor ycor
    update-node-visual
  ]
  ask intersections [
    create-tertiary-roads-with other intersections in-radius (ideal-segment-length * 1.1 )
    [
      update-link-visual
    ]
  ]
  set last1 nobody
  set last2 nobody
  set last-link nobody
  set mouse-clicked? false

  display
end

to update-link-visual
  ifelse (breed = primary-roads)
  [
    set color sky
    set thickness ideal-segment-length / 8
  ]
  [
    set color gray - 1
    set thickness ideal-segment-length / 16
  ]
  if (self = last-link)
  [
    set color red + 1
  ]
end

to update-node-visual
    set shape "square"
    set color gray
    set size ideal-segment-length / 3
end

to perturb
  ask intersections
  [
    rt random 360
    fd 0.03 * ideal-segment-length
  ]
  display
end


to straighten
  ask intersections
  [
    facexy original-xcor original-ycor
    fd 0.03 * distancexy original-xcor original-ycor
  ]
  display
end

to sparsify
  if (not any? tertiary-roads)
    [ stop ]
  ask n-of (floor ((count links) * 0.01) + 1) tertiary-roads
  [
    if ( [ count my-links ] of end1 > 2 and [ count my-links ] of end2 > 2)
    [ die ]
  ]
  display
end

to densify
  ask n-of (floor ((count intersections) * 0.05) + 1) intersections
  [
    ;let somebody one-of min-n-of 10 ( other intersections ) [ distance myself ]
    let nearby-intersections (turtle-set link-neighbors ([ link-neighbors ] of link-neighbors))
    let candidates intersections with [ not member? self nearby-intersections ]
    if (count candidates < 5)
     [ stop ]
    let somebody one-of min-n-of 5 ( candidates ) [ distance myself ]
    if (somebody != nobody)
    [
      ;if (not any? link-neighbors with [ member? self [link-neighbors] of somebody ])
      ;[
        create-tertiary-road-with somebody
        [
           update-link-visual
           ;; abort if we are creating a road link that crosses another road link
           if (any? other links with [ crossed? self myself ])
             [ die ]
        ]
      ;]
    ]
  ]
  display
end

to spread
  spread-intersections intersections
  display
end

to spread-intersections [ the-intersections ]
  layout-spring the-intersections links 0.5 0.05 ideal-segment-length / 5
end

to use-mouse
  let new-choose? false
  if (mouse-clicked? = 0) [ set mouse-clicked? false ]

  if not mouse-clicked? and mouse-down?
  [
    set mouse-clicked? true
    set new-choose? true
  ]
  if mouse-clicked? and not mouse-down?
  [
    set mouse-clicked? false
  ]

  if mouse-clicked?
  [
    if new-choose?
    [
      let newchoice min-one-of intersections [ distancexy mouse-xcor mouse-ycor ]

      ask newchoice [
        if ( distancexy-nowrap mouse-xcor mouse-ycor > (ideal-segment-length / 3) )
          [ set newchoice nobody ]
      ]
      if (newchoice = nobody or newchoice != last1)
      [
        select-node newchoice
      ]
    ]
    if (last1 != nobody)
    [
      ask last1
      [
        let movedx mouse-xcor - xcor
        let movedy mouse-ycor - ycor
        setxy mouse-xcor mouse-ycor
        set original-xcor xcor
        set original-ycor ycor
        if (drag-neighbors-too?)
        [
          ask link-neighbors
          [
            carefully [
              set xcor xcor + movedx / 2
              set ycor ycor + movedy / 2
            ] [] ; don't try to move off the edge of the world
            ask link-neighbors with [ self != last1 ]
            [
              carefully [
                set xcor xcor + movedx / 4
                set ycor ycor + movedy / 4
              ] [] ; don't try to move off the edge of the world
            ]
          ]
        ]
      ]
    ]
  ]
  display
end

to select-node [ newchoice ]
  if (last2 != nobody)
  [
    ask last2 [ update-node-visual ]
  ]
  if (last-link != nobody )
  [
    let old-last-link last-link
    set last-link nobody
    ask old-last-link [ update-link-visual ]
  ]

  set last2 last1
  set last1 newchoice

  if (last2 != nobody) [ set [color] of last2 red + 2 ]
  if (last1 != nobody) [ set [color] of last1 red ]
  if (last2 != nobody and last1 != nobody)
  [
    set last-link [ link-with last2 ] of last1
    if (last-link != nobody) [ set [color] of last-link red + 1 ]
  ]
end

to create-intersection
  let newchoice nobody
  create-intersections 1
  [
    update-node-visual
    setxy mouse-xcor mouse-ycor
    set original-xcor mouse-xcor
    set original-ycor mouse-ycor
    set newchoice self
  ]
  select-node newchoice
end


to delete-intersection
  if (last1 != nobody)
  [
    ask last1 [ die ]
  ]
end

to add-road
  if (last1 != nobody and last2 != nobody)
  [
    ask last1 [
      create-tertiary-road-with last2
      [
        update-link-visual
        set last-link self
        set color red + 1
      ]
    ]
  ]
end

to remove-road
  if (last-link != nobody)
  [
    ask last-link [ die ]
  ]
end

to make-path-primary
  if (last1 != nobody and last2 != nobody)
  [
    ask last1 [
      foreach (__network-shortest-path-links last2 links)
      [
        ask ? [
          if (breed != primary-roads)
            [ set breed primary-roads ]
          update-link-visual
        ]
      ]
    ]
  ]
end

to make-path-tertiary
  if (last1 != nobody and last2 != nobody)
  [
    ask last1 [
      foreach (__network-shortest-path-links last2 primary-roads )
      [
        ask ? [
          set breed tertiary-roads
          update-link-visual
        ]
      ]
    ]
  ]
end

to show-hide-intersections
ask intersections [
 set hidden? not hidden?
 ]
end

to write-to-file [ filename ]
  carefully [ file-delete filename ] [ ]
  if (filename = false)
    [ stop ]
  file-open filename
  file-write count intersections
  file-write count links
  file-write ideal-segment-length

  ; we need to assign nodes consecutive unique id numbers
  ; because some nodes may have died, and who numbers may not be consecutive
  let id-counter 0
  ask intersections
  [
      set temp-id id-counter
      set id-counter id-counter + 1
      file-write xcor
      file-write ycor
  ]
  ask links [
    file-write [temp-id] of end1
    file-write [temp-id] of end2
    file-write (breed = primary-roads)
  ]
  file-close
end

to read-from-file [ filename ]
  if (filename = false)
    [ stop ]

  clear-turtles
  set last1 nobody
  set last2 nobody
  set last-link nobody
  set mouse-clicked? false

  file-open filename
  let num-intersections file-read
  let num-links file-read
  set ideal-segment-length file-read

  let id-counter 0
  repeat num-intersections
  [
    create-intersections 1 [
      set temp-id id-counter
      set id-counter id-counter + 1
      set xcor file-read
      set ycor file-read
      set original-xcor xcor
      set original-ycor ycor
      update-node-visual
    ]
  ]
  repeat num-links
  [
    let id1 file-read
    let id2 file-read
    let primary? file-read
    ask intersections with [ temp-id = id1 ]
    [
      ifelse (primary?)
      [
        create-primary-roads-with intersections with [ temp-id = id2 ]
          [ update-link-visual ]
      ]
      [
        create-tertiary-roads-with intersections with [ temp-id = id2 ]
          [ update-link-visual ]
      ]
    ]
  ]
  file-close
end

to-report crossed? [ link1 link2 ]  ;; report true if given links cross
  let result false
  carefully [
    ;; get nodes into local variables
    let $A [end1] of link1
    let $B [end2] of link1
    let $C [end1] of link2
    let $D [end2] of link2
    ;; if links share a node, report they don't cross
    if $A = $C or $A = $D or $B = $C or $B = $D [ report false ]
    ;; get link headings
    let $ab [towards $B] of $A
    let $cd [towards $D] of $C
    ;; Compare angles between each link and the other link's nodes.
    ;; The xor is true only if nodes are on opposite sides of link.
    ;; If both xor values are true, the links cross.
    set result ( (subtract-headings $ab [towards $C] of $A < 0)
                xor (subtract-headings $ab [towards $D] of $A < 0) )
         and ( (subtract-headings $cd [towards $A] of $C < 0)
                xor (subtract-headings $cd [towards $B] of $C < 0) )
  ]  [
    ; an error can occur if two nodes are at the exact same location.
    ; in such a case we will say there is no crossing.
    set result false
  ]
  report result
end
@#$#@#$#@
GRAPHICS-WINDOW
285
10
724
470
16
16
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
-16
16
-16
16
1
1
1
ticks

CC-WINDOW
5
517
733
612
Command Center
0

BUTTON
35
50
130
83
NIL
setup-grid
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL

SLIDER
35
10
235
43
road-network-size
road-network-size
2
40
20
1
1
NIL
HORIZONTAL

BUTTON
10
150
90
183
NIL
perturb
T
1
T
OBSERVER
NIL
NIL
NIL
NIL

BUTTON
175
150
260
183
NIL
straighten
T
1
T
OBSERVER
NIL
NIL
NIL
NIL

BUTTON
35
110
130
143
NIL
sparsify
T
1
T
OBSERVER
NIL
NIL
NIL
NIL

BUTTON
140
110
235
143
NIL
densify
T
1
T
OBSERVER
NIL
NIL
NIL
NIL

BUTTON
140
50
235
83
NIL
setup-radial
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL

BUTTON
10
230
107
263
NIL
use-mouse
T
1
T
OBSERVER
NIL
NIL
NIL
NIL

BUTTON
10
315
155
348
NIL
delete-intersection
NIL
1
T
OBSERVER
NIL
D
NIL
NIL

BUTTON
435
470
597
503
show/hide intersections
show-hide-intersections
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL

BUTTON
165
315
270
348
NIL
remove-road
NIL
1
T
OBSERVER
NIL
R
NIL
NIL

BUTTON
165
275
270
308
NIL
add-road
NIL
1
T
OBSERVER
NIL
A
NIL
NIL

BUTTON
10
275
155
308
NIL
create-intersection
NIL
1
T
OBSERVER
NIL
C
NIL
NIL

BUTTON
95
150
170
183
NIL
spread
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL

BUTTON
15
457
122
490
save-network
write-to-file user-new-file
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL

BUTTON
140
457
242
490
load-network
read-from-file user-file
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL

TEXTBOX
47
435
267
453
-------------------------------------------
11
0.0
1

TEXTBOX
49
200
275
226
-------------------------------------------
11
0.0
1

SWITCH
110
230
270
263
drag-neighbors-too?
drag-neighbors-too?
1
1
-1000

BUTTON
55
353
212
386
NIL
make-path-primary
NIL
1
T
OBSERVER
NIL
P
NIL
NIL

BUTTON
55
390
212
423
NIL
make-path-tertiary
NIL
1
T
OBSERVER
NIL
T
NIL
NIL

@#$#@#$#@
VERSION
-------
$Header: /home/cvs/netlogo/models/under\040development/cities/Road\040Network\040Builder.nlogo,v 1.11 2007-09-24 20:26:57 everreau Exp $


WHAT IS IT?
-----------
This model is a flexible design tool for creating road networks that may be imported into the CITIES model, which simulates urban growth and land usage patterns.  The CITIES model is capable of growing its own sophisticated road networks, in a rather organic fashion, by having road-builder agents wander the map and create roads where it would be logical to do so.  However, sometimes it is desirable to have more fine-grained control over the road network structure within a city, and this Road Network Builder model serves this purpose.

HOW IT WORKS
------------

A road network is defined by some number of road "intersections", which have physical locations in the world.  These intersection nodes may be connected to other interseciton nodes by roads, which are straight line segments between nodes.  Note, however, that a curvy section of road may be simulated by stringing together several intersection nodes that each have only two roads going out of them.  The intersection nodes can be repositioned either by using automated tools (such as the PERTURB or STRAIGHTEN buttons), or by manually adjusting single nodes using mouse interaction.

Road segments may be designated either primary or tertiary.  Primary roads appear thicker in the visual display, and colored sky blue, rather than gray.

The networks that are created can be saved, and re-loaded for further editing at a future date.  The saved road networks can also be imported into the CITIES model.

HOW TO USE IT
-------------

There are two basic setup patterns for the road network included in this model (though it could be extended to have others).  These are a grid pattern (initiated by the SETUP-GRID button) and a radial hub pattern (initiated by the SETUP-RADIAL button).  The size of the road network is controlled by the ROAD-NETWORK-SIZE slider.  In both patterns, initially all roads are marked as tertiary.  If you wish to have primary roads, you must manually mark them using mouse interaction.

There are several functions that work on the network as a whole.

The PERTURB button causes all of the intersections to jitter randomly.

The STRAIGHTEN button causes all of the intersections to move back toward their original locations.  Some important notes:  1) when nodes are moved manually, the locations they were moved to is considered to be their "original location" 2) when a road network is loaded from a file, the loaded locations are considered to be the original locations.

The SPARSIFY button removes roads randomly from the network, resulting in a more sparse road network.  SPARSIFY will never remove a road that would cause an intersection to become a dead-end -- if you want to do this, you must manually do it with the USE-MOUSE mode.  Also, SPARSIFY will never remove road segments that are marked as primary.

Conversely, the DENSIFY button randomly adds more roads to the road network.  Roads are only added in ways that do not create underpasses/overpasses (i.e. line edge intersections) with existing roads.

The SPREAD button uses a visual graph layout algorithm called "spring layout" that pushes and pulls the intersection nodes as if there were coiled springs in place of the road edges.  Also, all nodes repel all other nodes, to keep them from getting too close to each other.  This often results in smooth and rather pleasing road network formations.  A single click of this button moves the nodes a little bit in the direction of the forces acting on them.

To manually interact with individual roads and intersections, click down the USE-MOUSE button to turn on mouse interaction.  Note that several of the buttons that you can use to interact with the network (DELETE-INTERSECTION, CREATE-INTERSECTION, REMOVE-ROAD, ADD-ROAD, MAKE-PATH-PRIMARY, MAKE-PATH-TERTIARY) have keyboard shortcut keys that you can use (shown in the

When USE-MOUSE is turned on, you can click and drag intersection nodes to new locations.  If DRAG-NEIGHBORS-TOO? switch is turned ON, then the nodes that are connected to the node being dragged are also repositioned.

The most recently selected node is colored red, and the second most recently selected node is colored pink.

The DELETE-INTERSECTION button will remove the most recently selected node (the red node), as well as any road segments that connect to it.

The CREATE-INTERSECTION button will create a new intersection node (with no road segments attached to it) somewhere in the world view.  If the mouse cursor is currently positioned inside the world view (which is possible, if you are using the shortcut keys), the new node will appear at the current mouse location.  Otherwise, the location of the new node on the map is somewhat unpredictable.  The new node will beceom the "most recently selected" node, and will be colored red.

The REMOVE-ROAD button removes the road segment (if one exists) between the two most recently selected intersection nodes (the red and pink nodes).

The ADD-ROAD button adds a road segment between the two most recently selected intersection nodes, if one does not already exist.

The MAKE-PATH-PRIMARY button selects a (shortest) path between the two most recently selected nodes (this path may consists of numerous segments, if the two nodes are not adjacent to each other in the network), and changes every road segment on this path to a primary road segment. If there is no path in the network between the selected nodes, then nothing happens.

The MAKE-PATH-TERTIARY button selects a (shortest) path between the two most recently selected nodes.  This path must consist only of primary road segments.  If such a path does not exist, then nothing happens.

The SAVE-NETWORK button allows you to save your current road network as a file.   You will be prompted to choose a file name.  (It is recommended, though not necessary, that you give the file a meaningful extensions, such as "xxxxx.network".)

The LOAD-NETWORK button allows you to load a previously saved road network file.

The "SHOW/HIDE INTERSECTIONS" button toggles whether the intersection nodes are displayed in the world view.  Temporarily hiding the nodes can give a better idea of what the road network actually looks like.


EXTENDING THE MODEL
-------------------
A simple extension to this model would be to include another basic setup pattern (like SETUP-GRID and SETUP-RADIAL).  Start by reading the code for the SETUP-GRID and SETUP-RADIAL procedures, and then design your own.  You may or ma not need to make modifications to the FINISH-SETUP procedure.

Another extension to this model would be to support curvy roads more directly, by changing the link shapes of the roads to a more curvy link shape (see the Link Shapes Editor, under the Tools menu).  In order for this change to also be reflected in the CITIES model, you would need to make changes to the file "import-road-network.nls", to have the turtles that create the road network move in curved patterns on their way to their destination.

NETLOGO FEATURES
----------------
This model makes considerable use of the NetLogo's support for the links agent type.  It uses two different link breeds (one for primary roads, and one for tertiary roads).  It also makes use of one undocumented NetLogo primitive called __network-shortest-path-links, for the convenience of turning a whole path of road primary or tertiary with one click.  The functionality provided by this primitive will likely be officially supported and documented in some future release of NetLogo.

RELATED MODELS
--------------
This model is a companion model, or extension, to the "Cities" model.  For other models that investigate topics related to urban development, see the "Urban Suite" models.

This model is a highly network-based model, and is thus related to several of the Network models in the Models Library, such as Preferential Attachment and Giant Component.

CREDITS AND REFERENCES
----------------------
This model was written by Forrest Stonedahl in 2007, as a tool for developing transportation network structures that could be integrated into the Cities model.

This model was developed as part of the Procedural Modeling of Cities project, under the sponsorship of NSF ITR award 0326542, Electronic Arts & Maxis.

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
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
