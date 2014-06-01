$(document).ready ->
  canvas = new window.KillerCanvas document.getElementById('killer')
  canvas.model Generator.generateKiller Generator.generateSudoku 3
