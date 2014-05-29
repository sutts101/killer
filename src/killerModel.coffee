class Sudoku

  constructor: (values) ->

    @size = Math.sqrt(values.length)
    throw new Error "That's not a valid square you bozo" unless Math.round(@size) is @size
    @root = Math.sqrt @size
    throw new Error "That's not a valid square square you bozo" unless Math.round(@root) is @root

    @validValues = [0...@size].map (value) => value + 1

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
        throw new Error "Invalid value '#{values[index]}' at row #{row} column #{col}" unless values[index] in @validValues
        cell = new Cell this, row, col, values[index]
        @cells.push cell
        @rows[row].push cell
        @cols[col].push cell
        boxIndex = (Math.floor(row / @root) * @root) + Math.floor(col / @root)
        @boxes[boxIndex].push cell


  cellAt: (row, col) -> @cells[(row * @size) + col]

class CellBlock

  constructor: -> @cells = []

  push: (cell) ->
    throw new Error "Duplicate value '#{cell.value}' at row #{cell.row} column #{cell.col}" if cell.value in @values()
    @cells.push cell

  values: -> @cells.map (cell) => cell.value

  sum: -> @values().reduce (x,y) -> x + y

class Cell

  constructor: (@sudoku, @row, @col, @value) -> @entries = []

  isNextTo: (cell) ->
    rowDiff = Math.abs(@row - cell.row)
    colDiff = Math.abs(@col - cell.col)
    (rowDiff is 1 and colDiff is 0) or (rowDiff is 0 and colDiff is 1)

  up:    -> @sudoku.cellAt @row - 1, @col
  down:  -> @sudoku.cellAt @row + 1, @col
  left:  -> @sudoku.cellAt @row,     @col - 1 unless @col == 0
  right: -> @sudoku.cellAt @row,     @col + 1 unless @col >= (@sudoku.size - 1)

  enter: (value) ->
    if value in @sudoku.validValues
      if value in @entries
        @entries = @entries.filter (e) -> e isnt value
      else
        @entries.push value

  entriesAsString: () ->
    @entries.join ''

  toString: -> "#{@row},#{@col}:#{@value}"

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
    if @cells.length is 0
      @cells.push cell
    else
      for existing in @cells
        if existing.isNextTo(cell)
          @cells.push cell
          return
      throw new Error "Non-contiguous cell (#{cell.row},#{cell.col}) pushed to region you bozo"

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