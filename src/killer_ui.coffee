#{Sudoku, Cell, Killer, Region} = require 'killer'

$(document).ready ->

  canvas = document.getElementById "killer"

  size = canvas.width
  console.log "The canvas ain't square you bozo - this won't render very well" unless canvas.width is canvas.height

  ctx = canvas.getContext "2d"

  ctx.fillStyle = "#EEEEEE"
  ctx.fillRect 0, 0, size, size

  drawGridLines = (numberOfGridLines, strokeStyle) ->
    ctx.strokeStyle = strokeStyle
    ctx.beginPath
    for index in [0..numberOfGridLines]
      x = y = Math.floor index * (size / numberOfGridLines)
      ctx.moveTo x, 0
      ctx.lineTo x, size
      ctx.moveTo 0, y
      ctx.lineTo size, y
    ctx.stroke();

  drawValues = (sudoku) ->
    ctx.fillStyle = "#0000FF"
    ctx.font = "30px Arial"
    ctx.textBaseline = 'middle'
    for row in [0...sudoku.size]
      for col in [0...sudoku.size]
        cell = sudoku.cell_at row, col
        value = cell.value
        x = (col + 0.5) * (size / sudoku.size) - (ctx.measureText(value).width / 2)
        y = (row + 0.5) * (size / sudoku.size)
        ctx.fillText(value, x, y);

  Sudoku = window.Sudoku

  sudoku = new Sudoku [
    1,2,3,4,
    3,4,1,2
    2,1,4,3
    4,3,1,2
  ]

  drawGridLines Math.sqrt(sudoku.size), '#000000'
  drawGridLines sudoku.size, '#DDDDDD'

  drawValues sudoku


