$(document).ready ->
  canvas = new window.KillerCanvas document.getElementById('killer')
  newGame = ->
    tricksiness = parseFloat $('#tricksiness').val()
    sudoku = Generator.generateSudoku 3
    killer = Generator.generateKiller sudoku, tricksiness
    canvas.model killer
  $('#newGame').click -> newGame()
  $('#tricksiness').change -> newGame()
  newGame()