#{Sudoku, Cell, Killer, Region} = require 'killer'

$(document).ready ->

  Sudoku = window.Sudoku
  Killer = window.Killer

  sudoku = new Sudoku [

    1,2,3,  4,5,6,  7,8,9
    4,5,6,  7,8,9,  1,2,3
    7,8,9,  1,2,3,  4,5,6

    2,3,1,  5,6,4,  8,9,7
    5,6,4,  8,9,7,  2,3,1
    8,9,7,  2,3,1,  5,6,4

    3,1,2,  6,4,5,  9,8,7
    6,5,4,  9,7,8,  3,1,2
    9,8,7,  3,1,2,  6,4,5

  ]

  killer = new Killer sudoku, [

     1, 1, 2,    2, 3, 4,    4, 5, 5
     1, 6, 6,    7, 7, 7,    8, 8, 5
     9,10,11,   11,11,11,   11,12,13

     9,10,14,   14,15,16,   16,12,13
    14,14,14,   14,15,16,   16,16,16
    17,18,18,   15,15,15,   19,19,20

    17,18,21,   21,21,21,   21,19,20
    17,18,22,   23,21,24,   25,19,20
    22,22,22,   23,21,24,   25,25,25

  ]

  region_inset = 5

  canvas = document.getElementById "killer"

  size = canvas.width
  console.log "The canvas ain't square you bozo - this won't render very well" unless canvas.width is canvas.height

  ctx = canvas.getContext "2d"

  draw_grid_lines = (numberOfGridLines, strokeStyle, lineWidth) ->
    ctx.strokeStyle = strokeStyle
    ctx.lineWidth = lineWidth
    ctx.beginPath()
    for index in [0..numberOfGridLines]
      x = y = Math.floor index * (size / numberOfGridLines)
      ctx.moveTo x, 0
      ctx.lineTo x, size
      ctx.moveTo 0, y
      ctx.lineTo size, y
    ctx.stroke()
    ctx.closePath()


  draw_regions = (killer) ->
    ctx.strokeStyle = 'blue'
    ctx.setLineDash [1]
    ctx.lineWidth = 1
    ctx.beginPath()
    for row in [0...sudoku.size]
      for col in [0...sudoku.size]
        cell = sudoku.cell_at row, col
        x1 = ((col + 0) * (size / sudoku.size)) + region_inset
        y1 = ((row + 0) * (size / sudoku.size)) + region_inset
        x2 = ((col + 1) * (size / sudoku.size)) - region_inset
        y2 = ((row + 1) * (size / sudoku.size)) - region_inset
        draw_region_line = (x1, y1, x2, y2) ->
          ctx.moveTo x1, y1
          ctx.lineTo x2, y2
        more = (cell, movement) ->
          if cell.region.contains cell[movement]()
            (2 * region_inset)
          else
            0
        unless cell.region.contains cell.up()
          draw_region_line x1 - more(cell, 'left'), y1, x2 + more(cell, 'right'), y1
        unless cell.region.contains cell.right()
          draw_region_line x2, y1 - more(cell, 'up'), x2, y2 + more(cell, 'down')
        unless cell.region.contains cell.down()
          draw_region_line x1 - more(cell, 'left'), y2, x2 + more(cell, 'right'), y2
        unless cell.region.contains cell.left()
          draw_region_line x1, y1 - more(cell, 'up'), x1, y2 + more(cell, 'down')
    ctx.stroke()
    ctx.closePath()

  draw_region_sums = (killer) ->
    ctx.fillStyle = "blue"
    ctx.font = "12px Arial"
    ctx.textBaseline = 'top'
    for region in killer.regions
      cell = region.cells[0]
      x = (cell.col() * (size / sudoku.size)) + region_inset + 3
      y = (cell.row() * (size / sudoku.size)) + region_inset + 3
      ctx.fillText(cell.region.sum(), x, y);


  ctx.fillStyle = "#EEEEEE"
  ctx.fillRect 0, 0, size, size

  draw_grid_lines sudoku.size, 'black', 1
  draw_grid_lines Math.sqrt(sudoku.size), 'black', 3
  draw_regions killer
  draw_region_sums killer