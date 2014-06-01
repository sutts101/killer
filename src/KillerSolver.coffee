{Sudoku, Cell, Killer, Region, Generator} = require '../src/killerModel'

class KillerSolver

  constructor: (@killer) ->
    console.log "Hi"
    @guess 0

  guess: (index) ->
    cell = @killer.cells[index]
    if cell?
      for entry in cell.availableEntries()
        cell.enter entry
        if @killer.isCompleteDisregardingValues()
          console.log @killer.entries().join ','
        @guess index + 1
        cell.enter entry


values = [2, 4, 3, 1, 1, 3, 2, 4, 4, 2, 1, 3, 3, 1, 4, 2]
regions = [0, 1, 2, 3, 0, 1, 2, 3, 13, 13, 14, 14, 13, 13, 14, 14]
killer = new Killer values, regions
killer = Generator.generateKiller Generator.generateSudoku 3
solver = new KillerSolver killer