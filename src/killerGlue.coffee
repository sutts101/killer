#{Killer} = require 'killerModel'
#{KillerGenerator} = require 'killerGenerator'
#{KillerCanvas} = require 'killerCanvas'


$(document).ready ->

  values = [

    1,2,3,  4,5,6,  7,8,9
    4,5,6,  7,8,9,  1,2,3
    7,8,9,  1,2,3,  4,5,6

    2,3,1,  5,6,4,  8,9,7
    5,6,4,  8,9,7,  2,3,1
    8,9,7,  2,3,1,  5,6,4

    3,1,2,  6,4,5,  9,7,8
    6,4,5,  9,7,8,  3,1,2
    9,7,8,  3,1,2,  6,4,5

  ]

  regions = [

     1, 1, 2,   2, 3, 4,    4, 5, 5
     1, 6, 6,   3, 3, 3,    8, 8, 5
     9,10,11,  11,11,11,   11,12,13

     9,10,14,  15,15,16,   16,12,13
    14,14,14,  14,15,16,   16,16,16
    17,18,18,  15,15,15,   19,19,20

    17,18,21,  21,21,21,   21,19,20
    17,18,22,  23,21,24,   25,19,20
    22,22,22,  23,21,24,   25,25,25

  ]

  Killer = window.Killer
  KillerCanvas = window.KillerCanvas
  KillerGenerator = window.KillerGenerator

  killer = new Killer values, regions

  killerGenerator = new KillerGenerator()
  killer = killerGenerator.generate killer


  canvas = new KillerCanvas document.getElementById('killer')
  canvas.model killer
