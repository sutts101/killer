class Sudoku

  constructor: (values) ->
    @size = Math.sqrt(values.length)
    throw new Error "That's not a valid square you bozo" unless Math.round(@size) is @size
    @cells = values.map (value,index) => new Cell this, index, value

  cell_at: (row, col) ->
    @cells[(row * @size) + col]

  cell_at_index: (index) ->
    @cells[index]

class Cell

  constructor: (@sudoku, @index, @value) ->

  row: -> Math.floor(@index / @sudoku.size)

  col: -> @index % @sudoku.size

  is_next_to: (cell) -> @col() is cell.col() or @row() is cell.row()

  up:    -> @sudoku.cell_at @row() - 1, @col()
  down:  -> @sudoku.cell_at @row() + 1, @col()
  left:  -> @sudoku.cell_at @row(),     @col() - 1 unless @col() == 0
  right: -> @sudoku.cell_at @row(),     @col() + 1 unless @col() >= (@sudoku.size - 1)

class Killer

  constructor: (@sudoku, regionIds) ->
    throw new Error "Incorrect number of regions you bozo" unless regionIds.length is @sudoku.cells.length
    @regions= []
    for regionId,index in regionIds
      cell = @sudoku.cell_at_index(index)
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

  to_s: ->
    "Region #{@id}: #{@cells}"


root = exports ? window
root.Sudoku = Sudoku
root.Cell = Cell
root.Killer = Killer
root.Region = Region