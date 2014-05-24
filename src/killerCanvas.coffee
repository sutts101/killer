#{Sudoku, Cell, Killer, Region} = require 'killerModel'

class KillerCanvas

  constructor: (@canvas) ->
    @size = @canvas.width
    console.log "The canvas ain't square you bozo - this won't render very well" unless canvas.width is canvas.height

    @region_inset = 5

    @ctx = canvas.getContext "2d"
    @_drawGridLines 9, 'black', 1
    @_drawGridLines 3, 'black', 3

  model: (@killer) ->
    @sudoku = @killer.sudoku
    @redraw()

  redraw: () =>
    @ctx.fillStyle = "#EEEEEE"
    @ctx.fillRect 0, 0, @size, @size
    @_drawGridLines @sudoku.size, 'black', 1
    @_drawGridLines Math.sqrt(@sudoku.size), 'black', 3
    @_drawRegions()
    @_drawRegionSums()

  _drawGridLines: (numberOfGridLines, strokeStyle, lineWidth) =>
    @ctx.strokeStyle = strokeStyle
    @ctx.lineWidth = lineWidth
    @ctx.beginPath()
    for index in [0..numberOfGridLines]
      x = y = Math.floor index * (@size / numberOfGridLines)
      @ctx.moveTo x, 0
      @ctx.lineTo x, @size
      @ctx.moveTo 0, y
      @ctx.lineTo @size, y
    @ctx.stroke()
    @ctx.closePath()

  _drawRegions: ->
    @ctx.strokeStyle = 'blue'
    @ctx.setLineDash [1]
    @ctx.lineWidth = 1
    @ctx.beginPath()
    for row in [0...@sudoku.size]
      for col in [0...@sudoku.size]
        cell = @sudoku.cell_at row, col
        x1 = ((col + 0) * (@size / @sudoku.size)) + @region_inset
        y1 = ((row + 0) * (@size / @sudoku.size)) + @region_inset
        x2 = ((col + 1) * (@size / @sudoku.size)) - @region_inset
        y2 = ((row + 1) * (@size / @sudoku.size)) - @region_inset
        line = (x1, y1, x2, y2) =>
          @ctx.moveTo x1, y1
          @ctx.lineTo x2, y2
        more = (cell, movement) =>
          if cell.region.contains cell[movement]()
            (2 * @region_inset)
          else
            0
        unless cell.region.contains cell.up()
          line x1 - more(cell, 'left'), y1, x2 + more(cell, 'right'), y1
        unless cell.region.contains cell.right()
          line x2, y1 - more(cell, 'up'), x2, y2 + more(cell, 'down')
        unless cell.region.contains cell.down()
          line x1 - more(cell, 'left'), y2, x2 + more(cell, 'right'), y2
        unless cell.region.contains cell.left()
          line x1, y1 - more(cell, 'up'), x1, y2 + more(cell, 'down')
    @ctx.stroke()
    @ctx.closePath()

  _drawRegionSums: () ->
    @ctx.fillStyle = "blue"
    @ctx.font = "12px Arial"
    @ctx.textBaseline = 'top'
    for region in @killer.regions
      cell = region.cells[0]
      x = (cell.col() * (@size / @sudoku.size)) + @region_inset + 3
      y = (cell.row() * (@size / @sudoku.size)) + @region_inset + 3
      @ctx.fillText(cell.region.sum(), x, y);

root = exports ? window
root.KillerCanvas = KillerCanvas
