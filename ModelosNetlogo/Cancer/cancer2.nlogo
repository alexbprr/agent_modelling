globals [raio cancercellst0 vesselst0 maxncancercells maxncells energyconst lifeconst energylimit tissuecolor vesselcolor

 time cycle-finish-time behind-schedule times-scheduled frame-duration delta-t stop-running
 world-geometry mean-x mean-y mean-z plotting-commands histogram-plotting-commands
 behaviour-procedure-numbers behaviour-names internal-the-other
 button-command radian need-to-clear-drawing
 observer-commands
 objects-with-something-to-do
 maximum-plot-generations plot-generation
 prototypes total-time
 update-patch-attributes-needed
 state-restored-after-setup
 temp
]
breed[cancercells cancercell]
breed[nutrients nutrient]
breed[vegfs vegf]
breed [objects object]
breed [pens pen]
extensions [vid];; export a 30 frame movie of the view

turtles-own [
 scheduled-behaviours behaviours-at-tick-start current-behaviours current-behaviour behaviour-removals rules
 kind dead previous-xcor previous-ycor previous-heading dirty
 my-x
 my-next-x my-next-x-set
 my-y
 my-next-y my-next-y-set
 my-heading
 my-next-heading my-next-heading-set
 ]

patches-own[
  pvessel
]

cancercells-own[
  ancora?
  energy
  lifetime
  state
]

nutrients-own[
  quantity
]

vegfs-own [
  quantity
]

to-report vector_dot_product [v1 v2]
  report (first v1 * first v2) + (last v1 * last v2)
end

to-report vector_length [v1]
  report (sqrt(first v1 * first v1 + last v1 * last v1))
end

to setup
  ca
  setup-tissue
  setup-cancercells
  setup-vessels
  reset-ticks
end

to setup-tissue
  set tissuecolor 18
  ask patches[
    set pvessel 0
    set pcolor tissuecolor
  ]
end

to setup-cancercells
  set maxncancercells 30
  set energyconst 10
  set lifeconst 40
  set energylimit 3
  set cancercellst0 10

  ;let x random-pxcor
  ;let y random-pycor
  let x 0
  let y 0
  set raio 0.2
  create-cancercells 1 [
    set ancora? true
    set shape "cell"
    set color 124
    setxy x y
    set energy energyconst
    set lifetime lifeconst
    set state "active"
  ]
  ask cancercells [
    hatch cancercellst0 [
      set shape "cell"
      set color 124
      set ancora? false
      let xinc (random-normal (- raio) raio) ;random-normal
      let yinc (random-normal (- raio) raio)
      ;user-message ("xinc " xinc)
      ;user-message ("yinc " yinc)
      show xinc
      show yinc
      setxy xcor + xinc ycor + yinc
    ]
  ]
  ;set raio raio + 0.5
  ask cancercells [ rt random-float 360 ]
end

to setup-vessels
  set vesselcolor 15
  set vesselst0 10
  ask n-of vesselst0 patches [
    set pvessel 1
    set pcolor vesselcolor
  ]
end

to setup-vessels2
  set vesselcolor 15
  ;set vesselst0 5
  ask patch -3 -3 [
    set pvessel 1
    set pcolor vesselcolor
  ]
  ask patch -3 3 [
    set pvessel 1
    set pcolor vesselcolor
  ]
  ask patch 3 -3 [
    set pvessel 1
    set pcolor vesselcolor
  ]
  ask patch 3 3 [
    set pvessel 1
    set pcolor vesselcolor
  ]
end

;Cancer cells procedures
to replication
  if (count turtles-here < maxncancercells ) [
  if (random-float 1 < 0.05 * energy) [
    hatch 1[
      set shape "cell"
      set color 124
      let xinc (random-normal (- raio) raio)
      let yinc (random-normal (- raio) raio)
      setxy xcor + xinc ycor + yinc
      rt random 360
      set energy energyconst
      set lifetime lifeconst
      set state "active"
    ]
  ]
  ask self [set energy energy - 2]
  ]
end

;Only occurs if there is a cancer cell alive
to consume_nutrient
  ;Verify if patch-here has at least one cancer cell and a nutrient
  ;let c count turtles-here ;Number of cancer cells in current patch
  let n nutrients-on patch-here
  if (any? n) [
    ask one-of n [ die ]
    ask self [
      set energy energy + 5
      ;set lifetime lifetime + 10
    ]
  ]
end

to aging
  ask self [
    set lifetime lifetime - 1
    if (lifetime = 0) [
      set color 1
      set state "dead"
    ]
    set energy energy - 1
  ]
end

to move
  let my self
  ;random-seed 2394
  if (energy > energylimit)[
    if (any? patches in-radius 1 with [count nutrients > 0]) [
      let p one-of patches in-radius 1 with [count nutrients > 0]
      ask p [
        let x1 pxcor
        let y1 pycor
        output-print x1
        output-print y1
      ]
      if-else (p != nobody) [
        ask self [
          move-to p
        ]
      ]
      [
        rt random-float 360
        fd 0.02
      ]
      set energy energy - 1
    ]
  ]
end

;Produz uma substância que induz o crescimento de vasos sanguíneos (vegf = Vascular Endothelial Growth Factor)
to produce_vegf
  if (energy < energylimit) [
    ask patch-here [
      sprout-vegfs 1 [
        setxy pxcor pycor
        rt random-float 360
        fd 0.02
        set color 39
        set shape "dot"
      ]
    ]
    set energy energy - 1
  ]
end

to update_color
  if-else (energy <= energylimit)
    [set color 126 set state "inactive"]
    [set color 124 set state "active"]
end

;Nutrients procedures
to nutrient_arrival
  ask patches with [pvessel = 1] [
    sprout-nutrients 2 [
      set shape "dot"
      set color 45
    ]
  ]
end

to nutrient_diffusion
  ;Pick patch with less nutrients
  let p one-of neighbors with-min[count nutrients]
  let x1 [pxcor] of p
  let y1 [pycor] of p
  ;let v (list x1 y1)
  ;let u (list xcor ycor)
  ;let vlen vector_length[v]
  ;let angle 45
  ;set heading towardsxy x1 y1
  facexy x1 y1
  fd 1.0
end

to nutrient_decay
  let random-fraction random-float 1.0
  if (random-fraction <= 0.05) [ die ]
end

to vegf_diffusion
  let p one-of neighbors with-min[count vegfs]
  let x1 [pxcor] of p
  let y1 [pycor] of p
  facexy x1 y1
  fd 0.8
end

to vegf_decay
  let random-fraction random-float 1.0
  if (random-fraction <= 0.20) [ die ]
end

to create_vessel
  let p one-of neighbors with [pvessel = 1]
  if (p != nobody) [
    let random-fraction random-float 1.0
    if (random-fraction <= 0.10) [
      ask patch-here [
        set pvessel 1
        set pcolor vesselcolor
      ]
      ask self [die]
    ]
  ]
end

to update_patches_colors
  if-else (pvessel = 1)[ set pcolor vesselcolor]
  [set pcolor tissuecolor]
end

;Main event loop
to go
  ;random-seed 1003
  ask cancercells[if (state != "dead") [aging]]
  ask cancercells[if (state != "dead") [consume_nutrient]]
  ask cancercells[if (state != "dead") [replication]]
  ask cancercells[if (state != "dead") [move]]
  ask cancercells[if (state != "dead") [update_color]]
  ask cancercells[if (state != "dead") [produce_vegf]]

  nutrient_arrival
  ask nutrients[nutrient_diffusion]
  ask nutrients[nutrient_decay]

  ask vegfs[ hide-turtle ]
  ask vegfs[vegf_diffusion]
  ;every 5 [
    ask vegfs[create_vessel]
  ;]
  ask vegfs[vegf_decay]

  ask patches[update_patches_colors]

  ;if (gravar?)[
   ; vid:record-view
  ;]
  tick
end




; The following are NetLogo library procedures and reporters used by the BehaviourComposer
; New BSD license
; See http://modelling4all.org
; Authored by Ken Kahn; Last updated 16 January 2017 to be compatible with NetLogo 6.0

to start [globals-not-to-be-initialised]
 ;initialise globals-not-to-be-initialised
 ;the-model globals-not-to-be-initialised
 ;finish-setup
 ;create-pens 1 ; for drawing lines
 ;ask pens [hide-turtle]
end

to setup2
  setup-except []
end

to setup-except [globals-not-to-be-initialised]
 start globals-not-to-be-initialised
 set total-time 0
 if go-until (delta-t - .000001) []  ; ignore result
 ;ask objects [initialise-previous-state]
end

to initialise [globals-not-to-be-initialised]
 let saved-global-values map runresult globals-not-to-be-initialised
 if-else maximum-plot-generations > 0
    [if-else plot-generation <= maximum-plot-generations
        [let next-plot-generation plot-generation + 1
         ; clear all but plots and output
         clear-patches
         clear-drawing
         clear-turtles
         clear-globals
         set plot-generation next-plot-generation]
        [clear-all
         set plot-generation 0]]
    [clear-all]
 ;; restore the value of any variables in globals-not-to-be-initialised
 let i 0
 while [i < length globals-not-to-be-initialised]
       [let variable item i globals-not-to-be-initialised
        let value item i saved-global-values
        if (not is-number? value and not is-boolean? value and not is-list? value) [set value (word "\"" value "\"")]
        run (word "set " variable " " value)
        set i i + 1]
 reset-timer
 set time -1
 set times-scheduled []
 set behind-schedule 0
 set plotting-commands []
 set histogram-plotting-commands []
 set button-command ""
 set radian 57.29577951308232
 set need-to-clear-drawing false
 set observer-commands []
 set stop-running false
 if delta-t = 0 [set delta-t 1] ; give default value if none given
 if frame-duration = 0 [set frame-duration delta-t]
 if world-geometry = 0 [set world-geometry 1]
 ;ask-every-patch [ [] -> initialise-patch-attributes ]
 reset-ticks
end

to initialise-object
 set scheduled-behaviours []
 set current-behaviours []
 set behaviour-removals []
 set rules []
 set dead false
 ;initialise-attributes
end

to finish-setup
 ; faster than ask objects since doesn't shuffle
 set objects-with-something-to-do objects
 ;let ignore1 objects with [update-attributes]
 ask objects with [rules != []] [run-rules]
 ;update-all-turtle-states
 set time 0
end

to go2
 reset-timer ; reset timer so pause and resume don't have leftover time
 if go-until -1
    [set stop-running false ; so it can be started up again
     stop]
    set total-time total-time + timer
end

to setup-only-if-needed
  if times-scheduled = 0 [setup]
end

to-report go-until [stop-time]
 ; this is run by the 'go' button and runs the scheduled events and updates the turtle states and plots
 setup-only-if-needed
 if observer-commands != []
    [run-observer-commands]
 if-else times-scheduled = []
   ; following uses a hack to avoid the overhead of ask shuffling the agent set
   [set objects-with-something-to-do objects with [rules != []]
    ask objects-with-something-to-do [run-rules] ; nothing scheduled but rules may be triggered by time
    ; rules may have added behaviours or set 'dead' so can't re-use objects-with-something-to-do
    ask objects [finish-tick]
    if observer-commands != []
       [run-observer-commands]
    set time time + frame-duration]
   [if-else time <= 0
      [set cycle-finish-time first times-scheduled]
      [set cycle-finish-time cycle-finish-time + frame-duration]
     if stop-time > 0 [set cycle-finish-time stop-time]
     while [times-scheduled != [] and first times-scheduled <= cycle-finish-time]
       [; nothing happening so skip ahead to next event
        set time first times-scheduled
        set times-scheduled but-first times-scheduled
        set objects-with-something-to-do objects with [scheduled-behaviours != [] or rules != []]
        ask objects-with-something-to-do [start-tick]
        ; above may have added behaviours or set 'dead' so can't re-use objects-with-something-to-do
        ask objects [finish-tick]
        if observer-commands != []
           [run-observer-commands]
        if need-to-clear-drawing
           [clear-drawing
            set need-to-clear-drawing false]]]
 if observer-commands != []
    [run-observer-commands]
 ;update-all-turtle-states
 ;if update-patch-attributes-needed [ask-every-patch [ [] -> update-patch-attributes ]]
 tick-advance time - ticks
 run-plotting-commands
 report not any? objects = 0 or stop-running or (stop-time > 0 and time >= stop-time)
end

to run-observer-commands
  let commands observer-commands
  set observer-commands []
  ; run each command without ANY commands pending
  forEach commands [ [?1] -> run ?1 ]
end

to run-plotting-commands
 forEach plotting-commands [ [?1] -> if is-agent? first ?1 [ask first ?1 [update-plot item 1 ?1 runresult item 2 ?1 runresult item 3 ?1]] ]
 forEach histogram-plotting-commands [ [?1] -> if is-agent? first ?1 [ask first ?1 [update-histogram item 1 ?1 item 2 ?1 item 3 ?1]] ]
end

to update-plot [name-of-plot x y]
 if time >= 0
  [set-current-plot name-of-plot
   plotxy x y]
end

to update-histogram [name-of-plot population-reporter value-reporter]
 if time >= 0
  [set-current-plot name-of-plot
   histogram [runresult value-reporter] of runresult population-reporter]
end

;; behaviours are represented by a list:
;; scheduled-time behaviour-name
;; behaviours are kept in ascending order of the scheduled-time

to remove-behaviour-now [name]
 set scheduled-behaviours remove-behaviour-from-list name scheduled-behaviours
end

to do-every [interval actions]
 ; does it now and schedules the next occurrence interval ticks in the future
 ; schedules first in case action updates the current-behaviour variable
 if-else not is-number? interval or interval <= 0
   [user-message (word "Can only repeat something a positive number of times. Not " interval " " actions)]
   [if-else time < 0
      [insert-behaviour 0 (list (list actions interval))]
      [do-every-internal interval actions]]
end

to do-every-internal [interval actions]
 insert-behaviour time + interval (list (list actions interval))
 run-procedure actions
end

to do-every-dynamic [interval-reporter actions]
 insert-behaviour time + run-result interval-reporter (list (list actions interval-reporter))
 run-procedure actions
end

to do-repeatedly [repeat-count actions]
 ; runs actions repeat-count times
 ; if a non-integer uses the remainder as the odds of doing the action one additional time
 repeat round repeat-count [run actions]
 let extra repeat-count - round repeat-count
 if extra > 0 and extra >= random-float 1
    [run actions]
end

to start-tick
 set behaviours-at-tick-start scheduled-behaviours
 set current-behaviours scheduled-behaviours
 set scheduled-behaviours []
 while [current-behaviours != []]
       [let simulation-time first first current-behaviours
        if-else simulation-time > time
          [set scheduled-behaviours merge-behaviours scheduled-behaviours current-behaviours
           set current-behaviours []] ; stop this round
          [set current-behaviour first current-behaviours
           forEach but-first current-behaviour run-procedure
           set current-behaviour 0
           ; procedure may have reset current-behaviours to []
           if current-behaviours != []
              [set current-behaviours but-first current-behaviours]]]
 if rules != [] [run-rules]
 if behaviour-removals != []
    [forEach behaviour-removals
        [ [?1] -> ask first ?1 [remove-behaviour-now item 1 ?1] ]
     set behaviour-removals []]
end

to finish-tick
 ; this should happen after all objects have run start-tick
 ;let ignore update-attributes
 if dead [die]
end

to-report all-of-kind [kind-name]
 report objects with [kind = kind-name]
end

to-report all-others
 report objects with [self != myself and not hidden?]
end

to run-rules
 let current-rules rules
 set rules []
 ; so can remove a rule below while still going down the list
 ;; could add error handling below
 forEach current-rules
    [ [?1] -> if-else runresult first ?1
       [run first but-first ?1
        if item 2 ?1
           ; is a 'whenever' rule so put it back on the list of rules
           [set rules fput ?1 rules]]
       [set rules fput ?1 rules] ]
end

to insert-behaviour [scheduled-time rest-of-behaviour]
 ; inserts in schedule keeping it sorted by scheduled time
 set times-scheduled insert-ordered scheduled-time times-scheduled
 set scheduled-behaviours insert-behaviour-in-list scheduled-time rest-of-behaviour scheduled-behaviours
end

to-report insert-ordered [new-time times]
  if-else member? new-time times
    [report times]
    [report sort fput new-time times]
end

to-report insert-behaviour-in-list [scheduled-time rest-of-behaviour behaviours]
 ; recursive version took 10% longer
 let earlier-behaviours []
 while [behaviours != []]
    [let current-time first first behaviours
      if current-time = scheduled-time
        [let new-behaviour lput first rest-of-behaviour first behaviours
          report sentence earlier-behaviours fput new-behaviour but-first behaviours]
      if current-time > scheduled-time
        [report sentence earlier-behaviours fput fput scheduled-time rest-of-behaviour behaviours]
     set earlier-behaviours lput first behaviours earlier-behaviours
     set behaviours but-first behaviours]
 report sentence earlier-behaviours (list fput scheduled-time rest-of-behaviour)
end

to-report remove-behaviour-from-list [procedure-name behaviours]
 report map [ [?1] -> remove-behaviour-from-behaviours-at-time-t procedure-name ?1 ] behaviours
end

to-report remove-behaviour-from-behaviours-at-time-t [procedure-name behaviours-at-time-t]
 forEach but-first behaviours-at-time-t ; first is the time -- skip that
   [ [?1] -> if equivalent-micro-behaviour? (ifelse-value is-list? ?1 [first ?1] [?1]) procedure-name
      [report remove ?1 behaviours-at-time-t] ]
 report behaviours-at-time-t
end

to-report equivalent-micro-behaviour? [name-1 name-2]
 if (not is-string? name-1)
    [set name-1 (anonymous-function-to-name name-1)]
 if (not is-string? name-2)
    [set name-2 (anonymous-function-to-name name-2)]
 if (name-1 = name-2) [report true]
 ; ignore serial number since can be multiple occurrences of the same micro-behaviour
 if (substring name-1 0 (length name-1 - 8) = substring name-2 0 (length name-2 - 8)) [report true]
 report false
end

to-report anonymous-function-to-name [f]
  ; extracts the name where the anonymous function was defined
  let s (word f)
  let start-index position " procedure " s
  if (start-index = false) [report s]
  set start-index start-index + length " procedure "
  set s substring s start-index (length s - 1)
  let stop-index position ": " s
  if (stop-index = false) [report s]
  report substring s 0 stop-index
end

to remove-behaviours [behaviours]
 forEach behaviours [ [?1] -> remove-behaviour ?1 ]
end

to remove-behaviour [name]
  set behaviour-removals fput (list self name) behaviour-removals
end

to-report merge-behaviours [behaviours1 behaviours2]
 ; both lists are already sorted
 if behaviours1 = [] [report behaviours2]
 if behaviours2 = [] [report behaviours1]
 if-else first first behaviours1 < first first behaviours2
   [report fput first behaviours1 merge-behaviours but-first behaviours1 behaviours2]
   [report fput first behaviours2 merge-behaviours behaviours1 but-first behaviours2]
end

to-report second [l]
 report first but-first l
end

to-report all-individuals
 report objects with [not hidden?]
end

to ask-every-patch [procedure-name]
 ; a hack but faster since doesn't randomise the patches as ask does
 let ignore patches with [run-false procedure-name]
end

to-report run-false [procedure-name]
 run procedure-name
 report false
end

to-report camera-tracks-centroid
 report world-geometry = 5
end

to-report list-to-agentset [agent-list]
 ; deprecated but kept for backwards compatibility
 report turtle-set agent-list
end

to run-procedure [name]
 if-else is-list? name
    [let target-or-frequency item 1 name
     if-else is-number? target-or-frequency
        [do-every-internal target-or-frequency first name]
        [if-else is-agent? target-or-frequency
            [ask target-or-frequency [run first name]]
            [do-every-dynamic target-or-frequency first name] ]]
    [run name]
end
@#$#@#$#@
GRAPHICS-WINDOW
196
16
997
558
-1
-1
13.0
1
10
1
1
1
0
1
1
1
-30
30
-20
20
1
1
1
ticks
30.0

BUTTON
49
62
122
95
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

BUTTON
49
95
122
128
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
19
343
165
376
parar gravacao
if (gravar?)[\n  vid:save-recording \"vid.mp4\" \n]
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
19
310
165
343
iniciar gravacao
if (gravar?)[\n vid:start-recorder\n  vid:record-view ;; show the initial state\n]
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
34
278
144
311
gravar?
gravar?
0
1
-1000

BUTTON
49
128
127
162
Pause
stop
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

cell
true
12
Polygon -5825686 true true 135 75 120 60 105 60 120 60 105 60 90 60 75 60 75 60 60 75 45 90 30 120 30 135 30 135 30 165 60 195 90 210 120 225 150 240 203 235 210 225 240 210 255 165 240 120 225 90 195 75 165 75

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

macrofago
true
9
Polygon -7500403 true false 92 84
Polygon -13791810 true true 247 201 232 238 236 248 231 251 229 252 218 255 215 255 211 255 209 255 201 255 191 255 180 265 181 282 178 288 170 293 163 292 144 293 140 293 135 290 131 287 124 284 120 278 112 270 112 270 107 264 102 260 97 260 93 260 73 256 68 252 55 242 55 239 55 236 58 233 58 230 56 227 56 226 55 222 55 219 50 212 47 210 40 201 38 173
Polygon -7500403 true false 264 126 264 127 264 127 264 132 263 135
Polygon -13791810 true true 58 81 62 75 66 69 76 62 78 61 89 58 92 58 96 58 98 58 106 58 116 58 127 48 136 40 136 40 139 27 144 21 163 20 167 20 172 23 176 26 183 29 187 35 195 43 195 43 200 49 205 53 210 53 214 53 234 57 239 61 252 71 252 74 252 77 249 80 249 83 251 86 251 87 252 91 252 94 257 101 260 103 267 112 268 119
Polygon -13791810 true true 81 238 75 234 69 230 62 220 61 218 58 207 58 204 58 200 58 198 58 190 58 180 36 176 37 165 40 160 27 157 21 152 20 133 20 129 23 124 26 120 29 113 35 109 43 101 43 101 49 96 53 91 53 86 53 82 57 62 61 57 71 44 74 44 77 44 80 47 83 47 86 45 87 45 91 44 94 44 101 39 103 36 112 29 140 27
Polygon -13791810 true true 178 46 215 61 225 57 228 62 229 64 232 75 232 78 232 82 232 84 232 92 232 102 242 113 259 112 265 115 270 123 269 130 270 149 270 153 267 158 264 162 261 169 262 166 256 169 253 171 244 179 243 193 246 199 247 207 233 220 229 225 219 238 216 238 213 238 210 235 207 235 204 237 203 237 199 238 196 238 189 243 187 246 178 253 150 255
Rectangle -13791810 true true 91 66 192 227
Circle -8630108 true false 120 110 114
Circle -8630108 true false 86 102 9
Circle -8630108 true false 148 81 9
Circle -8630108 true false 84 199 3
Circle -8630108 true false 94 131 14
Circle -8630108 true false 133 212 13
Circle -8630108 true false 195 97 14
Circle -8630108 true false 169 49 9
Circle -8630108 true false 106 37 4
Circle -8630108 true false 104 232 2

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
NetLogo 6.0.4
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="experiment" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>count turtles</metric>
    <enumeratedValueSet variable="numero-inicial-macrofagos">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="numero-inicial-bacteria">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="taxa-de-replicacao">
      <value value="31"/>
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
