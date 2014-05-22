#{Sudoku, Cell, Killer, Region} = require 'killer'

$(document).ready ->

  Sudoku = window.Sudoku
  Killer = window.Killer

  canvas = document.getElementById "killer"

  size = canvas.width
  console.log "The canvas ain't square you bozo - this won't render very well" unless canvas.width is canvas.height

  ctx = canvas.getContext "2d"

  ctx.fillStyle = "#EEEEEE"
  ctx.fillRect 0, 0, size, size

  drawRegions = (killer) ->
    for row in [0...sudoku.size]
      for col in [0...sudoku.size]
        cell = sudoku.cell_at row, col
        x = col * (size / sudoku.size)
        y = row * (size / sudoku.size)
        ctx.fillStyle = cell.region.background
        ctx.fillRect x, y, size / sudoku.size, size / sudoku.size
        if cell is cell.region.cells[0]
          drawRegionSum cell

  drawRegionSum = (cell) ->
    ctx.fillStyle = "#EEEEEE"
    ctx.font = "12px Arial"
    ctx.textBaseline = 'top'
    x = (cell.col() * (size / sudoku.size)) + 5
    y = (cell.row() * (size / sudoku.size)) + 5
    ctx.fillText(cell.region.sum(), x, y);


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
    ctx.fillStyle = "#EEEEEE"
    ctx.font = "30px Arial"
    ctx.textBaseline = 'middle'
    for row in [0...sudoku.size]
      for col in [0...sudoku.size]
        cell = sudoku.cell_at row, col
        value = cell.value
        x = (col + 0.5) * (size / sudoku.size) - (ctx.measureText(value).width / 2)
        y = (row + 0.5) * (size / sudoku.size)
        ctx.fillText(value, x, y);




  sudoku = new Sudoku [
    1,2,3,4
    3,4,1,2
    2,1,4,3
    4,3,2,1
  ]

  killer = new Killer sudoku, [
    1,1,2,2
    3,3,4,4
    5,5,6,6
    5,7,7,6
  ]

  create_colors = (num_colors) ->
    range = [0...num_colors]
    scale = chroma.scale ['blue', 'green']
    domain = scale.domain range
    palette = []
    push = (index) -> palette.push domain(index).hex()
    for index in range when index % 2 is 0 then push index
    for index in range when index % 2 is 1 then push index
    console.log palette
    palette

  colors = create_colors killer.regions.length
  for region,index in killer.regions
    region.background = colors[index % colors.length]

  drawRegions killer

  drawGridLines Math.sqrt(sudoku.size), '#000000'
  drawGridLines sudoku.size, '#DDDDDD'

  drawValues sudoku


