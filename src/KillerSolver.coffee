{Sudoku, Cell, Killer, Region, Generator} = require '../src/killerModel'
{SumCalculator} = require '../src/sumCalculator'
_ = require 'lodash'

class KillerSolver

  @solve = (killer) ->

    start = new Date().getTime()

    calc = new SumCalculator killer.size

    guess = (cells, index) ->
      cell = cells[index]
      if cell?
        possibleRegionValues = _.flatten calc.calculate cell.region.sum(), cell.region.cells.length, cell.region.entries()
        possibleValues = _.intersection cell.availableEntries(), possibleRegionValues
        for entry in possibleValues
          cell.enter entry
          guess cells, index + 1
          cell.enter entry
      else if killer.isCompleteDisregardingValues()
        console.log killer.entries().join ','

    for region in killer.regions
      region.validValues = _.flatten calc.calculate(region.sum(), region.cells.length)

    cellsSortedByGuessabilityOfRegion = []
    for region in (_.sortBy killer.regions, (r) -> r.validValues.length)
      cellsSortedByGuessabilityOfRegion.push cell for cell in region.cells
    guess cellsSortedByGuessabilityOfRegion, 0

    end = new Date().getTime()
    console.log "Duration: #{end - start} ms"

values = [2, 4, 3, 1, 1, 3, 2, 4, 4, 2, 1, 3, 3, 1, 4, 2]
regions = [0, 1, 2, 3, 0, 1, 2, 3, 13, 13, 14, 14, 13, 13, 14, 14]
killer = new Killer values, regions

killer = Generator.generateKiller Generator.generateSudoku 3

solver = KillerSolver.solve killer

