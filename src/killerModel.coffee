do -> Array::shuffle ?= ->
  for i in [@length-1..1]
    j = Math.floor Math.random() * (i + 1)
    [@[i], @[j]] = [@[j], @[i]]
  @

class Sudoku

  constructor: (values) ->

    @size = Math.sqrt(values.length)
    throw new Error "That's not a valid square you bozo" unless Math.round(@size) is @size
    @root = Math.sqrt @size
    throw new Error "That's not a valid square square you bozo" unless Math.round(@root) is @root

    @validValues = [0...@size].map (value) => value + 1

    @cells = []
    @blocks = []
    @rows = []
    @cols = []
    @boxes = []

    for blockType in ['rows', 'cols', 'boxes']
      for index in [0...@size]
        block = new CellBlock
        @blocks.push block
        @[blockType].push block

    for row in [0...@size]
      for col in [0...@size]
        index = (row * @size) + col
        throw new Error "Invalid value '#{values[index]}' at row #{row} column #{col}" unless values[index] in @validValues or values[index] is null
        cell = new Cell this, row, col, values[index]
        @cells.push cell
        @rows[row].push cell
        @cols[col].push cell
        boxIndex = (Math.floor(row / @root) * @root) + Math.floor(col / @root)
        @boxes[boxIndex].push cell

  cellAt: (row, col) -> @cells[(row * @size) + col]

  cellAtIndex: (index) -> @cells[index]

  values: -> @cells.map (cell) => cell.value

  isComplete: ->
    for block in @blocks
      return false unless block.isComplete()
    true

  isCompleteWithPreordainedEntries: ->
    return false unless @isComplete()
    for cell in @cells
      return false unless cell.hasPreordainedEntry()
    true

  toObject: ->
    {
      values: @values().join ','
      entries: (@cells.map (cell) -> cell.entriesAsString()).join ','
    }

  applyEntriesFromObject: (obj) ->
    for entry,index in obj.entries.split(',')
      for i in [0..entry.length]
        @cellAtIndex(index).enter parseInt(entry.charAt(i))

  @fromObject: (obj) ->
    values = obj.values.split(',').map (s) -> parseInt(s)
    sudoku = new Sudoku values
    sudoku.applyEntriesFromObject obj
    sudoku

class CellBlock

  constructor: -> @cells = []

  push: (cell) ->
    throw new Error "Duplicate value '#{cell.value}' at row #{cell.row} column #{cell.col}" if cell.value in @values() and cell.value isnt null
    @cells.push cell
    cell.blocks.push this

  values: -> @cells.map (cell) => cell.value

  sum: -> @values().reduce (x,y) -> x + y

  entries: ->
    entries = []
    for cell in @cells
      entries.push cell.entry() if cell.entry()?
    entries

  isComplete: ->
    entrySet = @cells.map (cell, index) -> index + 1
    for cell in @cells
      entry = cell.entry()
      return false unless entry?
      entrySet = entrySet.filter (v) -> v isnt entry
    return entrySet.length is 0

class Cell

  constructor: (@sudoku, @row, @col, @value) ->
    @entries = []
    @blocks = []

  index: -> (@row * @sudoku.size) + @col

  isNextTo: (cell) ->
    rowDiff = Math.abs(@row - cell.row)
    colDiff = Math.abs(@col - cell.col)
    (rowDiff is 1 and colDiff is 0) or (rowDiff is 0 and colDiff is 1)

  up:    -> @sudoku.cellAt @row - 1, @col
  down:  -> @sudoku.cellAt @row + 1, @col
  left:  -> @sudoku.cellAt @row,     @col - 1 unless @col == 0
  right: -> @sudoku.cellAt @row,     @col + 1 unless @col >= (@sudoku.size - 1)

  enter: (value, force = false) ->
    if value in @sudoku.validValues
      if force
        @entries = [value]
      else if value in @entries
        @entries = @entries.filter (e) -> e isnt value
      else
        @entries.push value

  entriesAsString: () -> @entries.join ''

  entry: -> @entries[0] if @entries.length is 1

  hasPreordainedEntry: -> @entry() is @value

  availableValues: ->
    allValues = @sudoku.validValues[0..@sudoku.validValues.length]
    for block in @blocks
      for cell in block.cells
        unless cell is this
          allValues = allValues.filter (e) -> e isnt cell.value
    allValues

  availableEntries: ->
    allValues = @sudoku.validValues[0..@sudoku.validValues.length]
    for block in @blocks
      for cell in block.cells
        unless cell is this
          allValues = allValues.filter (e) -> e isnt cell.entry()
    allValues

  toString: -> "#{@row},#{@col}:#{@value}"

class Killer extends Sudoku

  constructor: (values, regionIds) ->
    super values
    throw new Error "Incorrect number of regions you bozo" unless regionIds.length is @cells.length
    @regions= []
    for regionId,index in regionIds
      cell = @cellAtIndex index
      region = (@regions.filter (r) -> r.id is regionId)[0]
      unless region
        region = new Region regionId
        @regions.push region
      region.push cell
      cell.region = region

    for region in @regions
      region.validate()

  regionIds: -> @cells.map (cell) => cell.region.id

  entries: -> @cells.map (cell) => cell.entry()

  isComplete: ->
    return false unless super
    for region in @regions
      return false unless region.isComplete()
    true

  toObject: ->
    obj = super
    obj.regions = @regionIds().join ','
    obj

  @fromObject: (obj) ->
    regionIds = obj.regions.split(',').map (s) -> parseInt(s)
    sudoku = Sudoku.fromObject obj
    killer = new Killer sudoku.values(), regionIds
    killer.applyEntriesFromObject obj
    killer

class Region extends CellBlock

  constructor: (@id) -> super()

  validate: ->
    throw new Error "Huh, empty region - how did that happen???" if @cells.length is 0
    if @cells.length > 1
      hasAtLeastOneNeighbour = (cell) =>
        for other in @cells
          return true if other isnt cell and other.isNextTo cell
        false
      for cell in @cells
        throw new Error "Non-contiguous cell #{cell.toString()} pushed to region '#{@id}' you bozo" unless hasAtLeastOneNeighbour cell

  contains: (cell) -> cell in @cells

  isComplete: ->
    runningTotal = 0
    for cell in @cells
      return false unless cell.entry()?
      runningTotal += cell.entry()
    runningTotal is @sum()

class Generator

  @generateSudoku = (root) ->

    returnValidNewSudokuOrNull = (values) ->
      try
        return new Sudoku values
      catch
        return null

    worker = (working, index) ->
      values = working.values()
      cell = working.cellAt Math.floor(index / working.size), index % working.size
      candidates = cell.availableValues()
      while candidates.length > 0
        candidate = candidates[Math.floor(Math.random() * candidates.length)]
        candidates = candidates.filter (e) -> e isnt candidate
        values[index] = candidate
        next = returnValidNewSudokuOrNull values
        if next?
          if (index + 1) is Math.pow(working.size, 2)
            return next
          else
            result = worker next, index+1
            return result if result?

    numCells = Math.pow root, 4
    sudokuWhereAllCellsHaveValueNull = new Sudoku [0...numCells].map (i) -> null
    worker sudokuWhereAllCellsHaveValueNull, 0


  @generateKiller = (sudoku, thresholdForDoubles) ->

    mergeAwaySingleCellRegions = (killer) ->
      regionsWithOnlyOneCell = killer.regions.filter (r) => r.cells.length is 1
      if regionsWithOnlyOneCell.length > 0
        regionToKill = regionsWithOnlyOneCell[Math.floor(Math.random() * regionsWithOnlyOneCell.length)]
        cellToRelocate = regionToKill.cells[0]
        cellToBecomeNeighbour = findValidMergeTarget cellToRelocate
        if cellToBecomeNeighbour?
          values = killer.values()
          regions = killer.regionIds()
          regions[cellToRelocate.index()] = cellToBecomeNeighbour.region.id
          killer = mergeAwaySingleCellRegions new Killer values, regions
      killer

    findValidMergeTarget = (cellToRelocate) ->
      directions = ['up', 'right', 'left', 'down'].shuffle()
      for direction in directions
        cellToBecomeNeighbour = cellToRelocate[direction]()
        if cellToBecomeNeighbour?
          valuesAlreadyInRegion = cellToBecomeNeighbour.region.cells.map (cell) => cell.value
          if valuesAlreadyInRegion.indexOf(cellToRelocate.value) is -1
            return cellToBecomeNeighbour
      return null

    createInitialRegionsArray = ->
      regions = sudoku.cells.map (cell) -> cell
      for region,index in regions
        if regions[index].value?
          # grab the cell
          cell = regions[index]
          # replace in array with region id
          regions[index] = index
          # randomize
          random = Math.random() * 1
          if random >= thresholdForDoubles
            # make a double but do we go up or down?
            if random > (1 - thresholdForDoubles) / 2 and cell.col isnt sudoku.size - 1
              regions[index + 1] = index
            else if cell.row isnt sudoku.size - 1
              regions[index + sudoku.size] = index
      regions

    killerWhereAllRegionsHaveOnlyOneOrTwoCells = new Killer sudoku.values(), createInitialRegionsArray()
    mergeAwaySingleCellRegions killerWhereAllRegionsHaveOnlyOneOrTwoCells

class SudokuStringifier

  @stringify: (sudoku) ->
    out = ""
    for row in [0...sudoku.size]
      for col in [0...sudoku.size]
        out += sudoku.cellAt(row, col).value
        out += '  ' if (col + 1) % sudoku.root is 0
        out += ' ' if col < sudoku.size - 1
      out += '\n' if (row + 1) % sudoku.root is 0
      out += '\n' if row < sudoku.size - 1
    out


root = exports ? window
root.Sudoku = Sudoku
root.Cell = Cell
root.Killer = Killer
root.Region = Region
root.SudokuStringifier = SudokuStringifier
root.Generator = Generator