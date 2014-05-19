class Sudoku

  constructor: (values) ->
    @size = Math.sqrt(values.length)
    throw new Error "That's not a valid square you bozo" unless Math.round(@size) is @size
    @cells = []
    for index in [0...values.length]
      @cells.push new Cell(this, index, values[index])

  cell_at: (row, col) ->
    @cells[(row * @size) + col]

  cell_at_index: (index) ->
    @cells[index]

class Cell

  constructor: (@sudoku, @index, @value) ->

  to_s: ->
    "#{@index}:#{@value}"


class Killer

  constructor: (@sudoku, regionsArray) ->
    @regions = []
    for index in [0...regionsArray.length]
      cell = @sudoku.cell_at_index(index)
      regionId = regionsArray[index]
      if regionId is @regions.length + 1
        region = new Region(regionId)
        @regions.push region
      region = @regions[regionId-1]
      region.push cell
      cell.region = region

class Region

  constructor: (@id) ->
    @cells = []

  push: (cell) ->
    @cells.push cell

  sum: () ->
    values = @cells.map (cell) -> cell.value
    values.reduce (x,y) -> x + y

  to_s: ->
    "Region #{@id}: #{@cells}"


root = exports ? window
root.Sudoku = Sudoku
root.Cell = Cell
root.Killer = Killer
root.Region = Region