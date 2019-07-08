globals [raio-bacterias m-active?]
breed[bacterias bacteria]
breed[macrofagos macrofago]
breed[fibrina fib]
undirected-link-breed [link-bacterias link-fibrina]
;; export a 30 frame movie of the view
extensions [vid]

patches-own[
  pdano
]

bacterias-own[
  ancora?
]

macrofagos-own[
  lider?
]

to setup
  ca
  setup-tecido
  setup-bacteria
  setup-macrofago
  reset-ticks
end

to go
  if (one-of bacterias != nobody)[
    ask one-of bacterias[replicacao]
    ;ask one-of bacterias[b-dano]
  ]

  ask macrofagos[m-anda]
  if (m-active? AND one-of macrofagos != nobody)[
    ask bacterias[fabrica-fibrina ]
    ask one-of macrofagos[m-migra]
  ]

  if (gravar?)[
    vid:record-view
  ]
  tick

end



;RELACIONADO A MACROFAGO
to setup-macrofago
  create-macrofagos numero-inicial-macrofagos[
    set lider? false
    set m-active? false
    setxy random-xcor random-ycor
    set shape "macrofago"
    set color blue
  ]
end

to m-anda
  let passo  1

  ifelse (not m-active? OR (one-of bacterias = nobody))[            ;macrofagos no estado resting
    rt random-float 360.0
    fd passo
    if (any? bacterias in-radius m-visao) [
      set lider? true
      set color green
      set m-active? true
    ]
  ][                                ;macrofagos ativos
    ifelse (any? bacterias in-radius m-visao OR lider?) [
      set lider? true
      set color green
      face min-one-of bacterias [distance myself]
      ifelse (any? bacterias-on patch-ahead passo OR any? fibrina-on patch-ahead passo)[
          if (fagocita patch-ahead passo)[
            fd passo
          ]
      ][
        fd passo
      ]

    ][
      let lideres-proximos other macrofagos with [lider? AND distance myself < m-visao]
      ifelse (any? lideres-proximos) [                                                 ;se tem um lider proximo ele o segue
        face min-one-of lideres-proximos [distance myself] ;; then face the one closest to myself
        ifelse (any? bacterias-on patch-ahead passo OR any? fibrina-on patch-ahead passo)[
          if (fagocita patch-ahead passo)[
            fd passo
          ]
        ][
          fd passo
        ]
      ][
        rt random-float 360.0
        ifelse (any? bacterias-on patch-ahead passo OR any? fibrina-on patch-ahead passo)[
          if (fagocita patch-ahead passo)[
            fd passo
          ]
        ][
          fd passo
        ]

      ]
    ]
  ]
end

to m-migra
  if (random 100 < taxa-m-mig)[
    hatch 1 [
      set lider? false
      rt random 360.0
      setxy random-xcor random-ycor
      set shape "macrofago"
      set color blue
    ]
  ]
end

to-report fagocita[inimigo ]
  if (random 100 < taxa-m-fag)[
    ask turtles-on inimigo [die]
    report true
  ]
  report false

end

;RELACIONADO A BACTERIA
to setup-bacteria
  let x random-pxcor
  let y random-pycor
  set raio-bacterias 0.5
  create-bacterias 1 [
    set ancora? true
    set shape "bacteria"
    set color yellow
    setxy x y
  ]
  ask bacterias [
    hatch numero-inicial-bacteria[
      set color red
      set ancora? false
      b-anda
    ]
  ]
  set raio-bacterias raio-bacterias + 0.5
  ask bacterias [rt random-float 360.0]

end


to replicacao
  if ancora?[
    set color yellow
    if (random 100 < taxa-de-replicacao AND count bacterias < 100)[
      ask one-of bacterias with [ancora?][
        hatch 2[
          set color red
          set ancora? false
          b-anda
        ]
        set raio-bacterias raio-bacterias + 0.05
      ]
    ]
  ]

end

to b-anda
  if not ancora? [
    rt random-float 360.0
    fd random-float raio-bacterias
  ]
end

to b-dano
  if (random 100 < taxa-dano)[
      set pdano pdano + 1
     ; set pcolor pcolor - pdano
      set pcolor scale-color (pink) (pdano / 10) 5 0
      set plabel pdano
     ; if (pcolor <= pink AND pcolor >= pink + 5)
     ; [set pcolor red]
  ]
end

to fabrica-fibrina
;;  ask neighbors[sprout 1 [set shape "x"]]
  if (random 100 < 20)[
    ask patches in-radius 1.4[
      sprout-fibrina 1 [
        set shape "x" set color lime - 2
      ]
    ]
    liga
  ]
  ask fibrina[                              ;;gambiarra pra tirar a fibrina que ficou em cima das bacterias
    if any? bacterias-here[
      die
    ]
    if any? macrofagos-here[
      ask macrofagos-here[die]
    ]
  ]

end

to liga
  if (one-of fibrina != nobody)[
    ask fibrina[if (count my-links > 2) [ask one-of my-links [die]]]
    ask fibrina[
      let proximos min-n-of 2 other fibrina[distance myself]
      if (count my-links < 2)[
        if (disponivel proximos)[
          create-links-with proximos
        ]
      ]
    ]
  ]
end

to-report disponivel [proximos]
  let disp true
  ask proximos[ifelse (count my-links > 2) [set disp false][set disp true]]
  report disp
end


;RELACIONADO A TECIDO

to setup-tecido
  ask patches[
    set pdano 0
    set plabel pdano
    set pcolor pink + 3.5
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
284
10
721
448
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
-16
16
-16
16
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

SLIDER
739
87
960
120
numero-inicial-bacteria
numero-inicial-bacteria
0
100
29.0
1
1
NIL
HORIZONTAL

MONITOR
321
465
426
510
NIL
raio-bacterias
17
1
11

SLIDER
739
120
960
153
taxa-de-replicacao
taxa-de-replicacao
0
100
48.0
1
1
NIL
HORIZONTAL

SLIDER
1013
87
1260
120
numero-inicial-macrofagos
numero-inicial-macrofagos
0
100
2.0
1
1
NIL
HORIZONTAL

SLIDER
739
153
960
186
taxa-dano
taxa-dano
0
100
38.0
1
1
NIL
HORIZONTAL

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
15
219
161
252
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
15
187
161
220
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

BUTTON
802
429
865
462
link
liga
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
30
155
140
188
gravar?
gravar?
0
1
-1000

SLIDER
1013
120
1258
153
m-visao
m-visao
0
15
15.0
1
1
NIL
HORIZONTAL

SLIDER
1080
177
1252
210
taxa-m-mig
taxa-m-mig
0
100
47.0
1
1
NIL
HORIZONTAL

PLOT
794
333
994
483
Quantidade
Tempo
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"bacterias" 1.0 0 -2674135 true "" "plot count bacterias"
"macrofagos" 1.0 0 -13345367 true "" "plot count macrofagos"

SLIDER
1083
252
1255
285
taxa-m-fag
taxa-m-fag
0
100
100.0
1
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

bacteria
true
1
Polygon -16777216 true false 120 15 136 8 163 9 177 11 201 24 213 46 217 65 215 93 212 125 204 151 203 170 208 191 217 223 217 245 211 269 199 284 169 292 137 291 112 280 93 246 84 189 82 142 85 105 91 66 106 34 111 23
Polygon -2674135 true true 120 15 136 8 163 9 177 11 201 24 213 46 217 65 215 93 212 125 204 151 203 170 208 191 217 223 217 245 211 269 199 284 169 292 137 291 112 280 93 246 84 189 82 142 85 105 91 66 106 34 111 23

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
