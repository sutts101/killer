#{Sudoku,Killer,SudokuStringifier} = require '../src/killerModel'

do -> Array::shuffle ?= ->
  for i in [@length-1..1]
    j = Math.floor Math.random() * (i + 1)
    [@[i], @[j]] = [@[j], @[i]]
  @

class KillerGenerator

  generate: (sudoku) ->
    @_refine new Killer sudoku.values(), sudoku.values().map (value, index) => index

  _refine: (killer) ->
    regionsWithOnlyOneCell = killer.regions.filter (r) => r.cells.length is 1
    if regionsWithOnlyOneCell.length > 0
      regionToKill = regionsWithOnlyOneCell[Math.floor(Math.random() * regionsWithOnlyOneCell.length)]
      cellToRelocate = regionToKill.cells[0]
      cellToBecomeNeighbour = @_findValidMergeTarget cellToRelocate
      if cellToBecomeNeighbour?
        values = killer.values()
        regions = killer.regionIds()
        regions[cellToRelocate.index()] = cellToBecomeNeighbour.region.id
        killer = @_refine new Killer values, regions
    killer

  _findValidMergeTarget: (cellToRelocate) ->
    directions = ['up', 'right', 'left', 'down'].shuffle()
    for direction in directions
      cellToBecomeNeighbour = cellToRelocate[direction]()
      if cellToBecomeNeighbour?
        valuesAlreadyInRegion = cellToBecomeNeighbour.region.cells.map (cell) => cell.value
        if valuesAlreadyInRegion.indexOf(cellToRelocate.value) is -1
          return cellToBecomeNeighbour
    return null

root = exports ? window
root.KillerGenerator = KillerGenerator
