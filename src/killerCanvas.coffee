#{Sudoku, Cell, Killer, Region} = require 'killerModel'

class KillerCanvas

  constructor: (@canvas) ->
    @size = @canvas.width
    console.log "The canvas ain't square you bozo - this won't render very well" unless canvas.width is canvas.height

    @region_inset = 5

    @ctx = canvas.getContext "2d"
    @_drawGridLines 9, 'black', 1
    @_drawGridLines 3, 'black', 3

    @canvas.addEventListener 'mousemove', @_mouseMove
    window.addEventListener 'keydown', @_keyPress, false
    @canvas.addEventListener 'keydown', @_keyPress, true

    @focusCell = null

  model: (@killer) ->
    @sudoku = @killer.sudoku
    @redraw()

  redraw: () =>
    console.log "redrawing..."
    @ctx.setLineDash [1000]
    @ctx.fillStyle = "#EEEEEE"
    @ctx.fillRect 0, 0, @size, @size
    @_drawGridLines @sudoku.size, 'black', 1
    @_drawGridLines Math.sqrt(@sudoku.size), 'black', 3
    @_drawRegions()
    @_drawRegionSums()
    @_drawFocus()
    @_drawEntries()

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
    @ctx.strokeStyle = 'green'
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
    @ctx.fillStyle = "green"
    @ctx.font = "12px Arial"
    @ctx.textBaseline = 'top'
    for region in @killer.regions
      cell = region.cells[0]
      x = (cell.col() * (@size / @sudoku.size)) + @region_inset + 3
      y = (cell.row() * (@size / @sudoku.size)) + @region_inset + 3
      @ctx.fillText(cell.region.sum(), x, y);

  _drawFocus: () ->
    if @focusCell?
      x1 = ((@focusCell.col() + 0) * (@size / @sudoku.size)) + (3 * @region_inset)
      y1 = ((@focusCell.row() + 0) * (@size / @sudoku.size)) + (3 * @region_inset)
      x2 = ((@focusCell.col() + 1) * (@size / @sudoku.size)) - (3 * @region_inset)
      y2 = ((@focusCell.row() + 1) * (@size / @sudoku.size)) - (3 * @region_inset)
      @ctx.fillStyle = "yellow"
      @ctx.fillRect x1, y1, x2-x1, y2-y1

  _drawEntries: () ->
    @ctx.fillStyle = "darkblue"
    @ctx.textBaseline = 'middle'
    for row in [0...@sudoku.size]
      for col in [0...@sudoku.size]
        cell = @sudoku.cell_at row, col
        if cell.entries.length > 0
          if cell.entries.length is 1
            @ctx.font = "30px Arial"
          else if cell.entries.length > 4
            @ctx.font = "10px Arial"
          else
            @ctx.font = "15px Arial"
          x = (col + 0.5) * (@size / @sudoku.size) - (@ctx.measureText(cell.entriesAsString()).width / 2)
          y = (row + 0.5) * (@size / @sudoku.size)
          @ctx.fillText(cell.entriesAsString(), x, y);


  _mouseMove: (evt) =>
    rect = @canvas.getBoundingClientRect()
    x = evt.clientX - rect.left
    y = evt.clientY - rect.top
    row = Math.floor (y * (@sudoku.size / @size))
    col = Math.floor (x * (@sudoku.size / @size))
    cell = @sudoku.cell_at row, col
    if cell isnt @focusCell
      @focusCell = cell
      @redraw()

  _keyPress: (evt) =>
    if @focusCell?
      value = String.fromCharCode(evt.keyCode)
      if evt.keyCode in [49..57]
        @focusCell.enter value
        @redraw()


root = exports ? window
root.KillerCanvas = KillerCanvas
