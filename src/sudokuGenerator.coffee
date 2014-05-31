{Sudoku,SudokuStringifier} = require '../src/killerModel'

createRandomSudoku = (root) ->

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
  gottaStartSomewhere = new Sudoku [0...numCells].map (i) -> null
  return worker gottaStartSomewhere, 0

start = new Date().getTime()
result = createRandomSudoku 3
end = new Date().getTime()
console.log SudokuStringifier.stringify result
console.log "Completed in #{end - start} ms"