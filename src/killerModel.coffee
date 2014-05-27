class Sudoku

  constructor: (values) ->

    @size = Math.sqrt(values.length)
    throw new Error "That's not a valid square you bozo" unless Math.round(@size) is @size
    @root = Math.sqrt @size
    throw new Error "That's not a valid square square you bozo" unless Math.round(@root) is @root

    @cells = []
    @rows = []
    @cols = []
    @boxes = []

    for blockType in ['rows', 'cols', 'boxes']
      for index in [0...@size]
        @[blockType].push new CellBlock

    for row in [0...@size]
      for col in [0...@size]
        index = (row * @size) + col
        cell = new Cell this, index, values[index]
        @cells.push cell
        boxRowIndex = Math.floor(row / @root)
        boxColIndex = Math.floor(col / @root)
        boxIndex = (boxRowIndex * @root) + boxColIndex
        @rows[row].push cell
        @cols[col].push cell
        @boxes[boxIndex].push cell

  cellAt: (row, col) -> @cells[(row * @size) + col]

class CellBlock

  constructor: -> @cells = []

  push: (cell) -> @cells.push cell

  values: -> @cells.map (cell) => cell.value

  sum: -> @values().reduce (x,y) -> x + y

class Cell

  constructor: (@sudoku, @index, @value) ->
    @entries = []

  row: -> Math.floor(@index / @sudoku.size)

  col: -> @index % @sudoku.size

  is_next_to: (cell) -> @col() is cell.col() or @row() is cell.row()

  up:    -> @sudoku.cellAt @row() - 1, @col()
  down:  -> @sudoku.cellAt @row() + 1, @col()
  left:  -> @sudoku.cellAt @row(),     @col() - 1 unless @col() == 0
  right: -> @sudoku.cellAt @row(),     @col() + 1 unless @col() >= (@sudoku.size - 1)

  enter: (value) ->
    if value in @entries
      @entries = @entries.filter (e) -> e isnt value
    else
      @entries.push value

  entriesAsString: () ->
    @entries.join ''

class Killer extends Sudoku

  constructor: (values, regionIds) ->
    super values
    throw new Error "Incorrect number of regions you bozo" unless regionIds.length is @cells.length
    @regions= []
    for regionId,index in regionIds
      row = Math.floor(index / @size)
      col = index % @size
      cell = @cellAt row, col
      region = (@regions.filter (r) -> r.id is regionId)[0]
      unless region
        region = new Region regionId
        @regions.push region
      region.push cell
      cell.region = region

class Region

  constructor: (@id) ->
    @cells = []

  push: (cell) ->
    previous = @cells[@cells.length - 1]
#    throw new Error 'Bozo' if previous # and not previous.is_next_to cell
    @cells.push cell

  sum: () ->
    values = @cells.map (cell) -> cell.value
    values.reduce (x,y) -> x + y

  contains: (cell) ->
    cell in @cells

root = exports ? window
root.Sudoku = Sudoku
root.Cell = Cell
root.Killer = Killer
root.Region = Region