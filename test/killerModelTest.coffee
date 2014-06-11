{Sudoku, Cell, Killer, Region} = require '../src/killerModel'

chai = require 'chai'
chai.should()
json = require 'jsonify'

A_VALID_4x4_GRID = [
  1,2,3,4,
  3,4,1,2,
  2,3,4,1,
  4,1,2,3
]

describe "Sudoku", ->

  describe "construction", ->

    it "should allow access to cells by row and column", ->
      sudoku = new Sudoku A_VALID_4x4_GRID
      sudoku.cellAt(0,0).value.should.equal 1
      sudoku.cellAt(3,3).value.should.equal 3

    it "should also, of course, set the right row and column values", ->
      sudoku = new Sudoku A_VALID_4x4_GRID
      for row in [0...sudoku.size]
        for col in [0...sudoku.size]
          cell = sudoku.cellAt row, col
          cell.row.should.equal row
          cell.col.should.equal col

    it "should round trip values nicely", ->
      new Sudoku(A_VALID_4x4_GRID).values().join('').should.equal A_VALID_4x4_GRID.join('')

    it "should like square squares", ->
      new Sudoku [1]
      new Sudoku A_VALID_4x4_GRID

    it "should dislike non-squares", ->
      ( -> new Sudoku [1,2] ).should.throw "That's not a valid square you bozo"

    it "should dislike non-square squares", ->
      ( -> new Sudoku [1,2,3,4] ).should.throw "That's not a valid square square you bozo"

    it "should compute its size as the square root of the number of cells", ->
      new Sudoku([1]).size.should.equal 1
      new Sudoku(A_VALID_4x4_GRID).size.should.equal 4

    it "should compute its root as the square root of the size", ->
      new Sudoku([1]).root.should.equal 1
      new Sudoku(A_VALID_4x4_GRID).root.should.equal 2

    it "should generate a list of valid values", ->
      sudoku = new Sudoku A_VALID_4x4_GRID
      sudoku.validValues.join(',').should.equal '1,2,3,4'

    it "should complain if any of the input values are not valid", ->
      new Sudoku [1]
      ( -> new Sudoku [2] ).should.throw "Invalid value '2' at row 0 column 0"


  describe "blocks", ->

    sudoku = new Sudoku [
      1,2,3,4,
      3,4,1,2,
      2,3,4,1,
      4,1,2,3
    ]

    it "should do rows", ->
      for expected,index in ['1,2,3,4', '3,4,1,2', '2,3,4,1', '4,1,2,3']
        sudoku.rows[index].values().join(',').should.equal expected

    it "should do columns", ->
      for expected,index in ['1,3,2,4', '2,4,3,1', '3,1,4,2', '4,2,1,3']
        sudoku.cols[index].values().join(',').should.equal expected

    it "should do boxes", ->
      for expected,index in ['1,2,3,4', '3,4,1,2', '2,3,4,1', '4,1,2,3']
        sudoku.boxes[index].values().join(',').should.equal expected

    it "should do sums for all blocks and they should all be the same", ->
      for blockType in ['rows', 'cols', 'boxes']
        for index in [0..3]
          sudoku[blockType][index].sum().should.equal 10

    it "should complain if any of the blocks contain duplicates", ->
      bad = [
        1,2,3,4
        2,3,4,1
        3,4,1,2
        4,1,2,3
      ]
      ( -> new Sudoku bad ).should.throw "Duplicate value '2' at row 1 column 0"

    it "should do entries", ->

      sudoku = new Sudoku A_VALID_4x4_GRID
      sudoku.cellAt(0,0).enter 1
      sudoku.cellAt(0,1).enter 2
      sudoku.rows[0].entries().join(',').should.equal '1,2'

    it "should be incomplete unless all cells have valid (distinct) entries", ->

      sudoku = new Sudoku A_VALID_4x4_GRID
      sudoku.cellAt(0, 0).enter 1
      sudoku.cellAt(0, 1).enter 2
      sudoku.cellAt(0, 2).enter 3
      sudoku.rows[0].isComplete().should.equal false

      sudoku.cellAt(0, 3).enter 3
      sudoku.rows[0].isComplete().should.equal false

      sudoku.cellAt(0, 3).enter 3
      sudoku.cellAt(0, 3).enter 4
      sudoku.rows[0].isComplete().should.equal true

    it "should be complete when all cells have valid entries (whereby valid means not necessarily the same as the underlying value)", ->

      sudoku = new Sudoku A_VALID_4x4_GRID
      sudoku.cellAt(1, col).enter(col + 1) for col in [0..3]

      sudoku.cellAt(1,0).value.should.not.equal sudoku.cellAt(1,0).entry()
      sudoku.rows[1].isComplete().should.equal true

  describe "cell movement", ->

    sudoku = new Sudoku A_VALID_4x4_GRID

    move_and_expect_cell = (start_row, start_column, movement, end_row, end_column) ->
      start_cell = sudoku.cellAt start_row, start_column
      end_cell = start_cell[movement]()
      end_cell.row.should.equal end_row
      end_cell.col.should.equal end_column

    it "should go up, down, left and right when it can", ->
      move_and_expect_cell 1, 1, 'up',    0, 1
      move_and_expect_cell 1, 1, 'down',  2, 1
      move_and_expect_cell 1, 1, 'left',  1, 0
      move_and_expect_cell 1, 1, 'right', 1, 2

    move_and_expect_undefined = (start_row, start_column, movement) ->
      start_cell = sudoku.cellAt start_row, start_column
      end_cell = start_cell[movement]()
      (end_cell is undefined).should.be.true

    it "should not go up, down, left or right when it can't", ->
      move_and_expect_undefined 0, 1, 'up'
      move_and_expect_undefined 3, 1, 'down'
      move_and_expect_undefined 1, 0, 'left'
      move_and_expect_undefined 1, 3, 'right'

  describe "cells", ->

    sudoku = new Sudoku A_VALID_4x4_GRID

    it "should be able to convert back to cell index", ->
      sudoku.cellAt(0,0).index().should.equal 0
      sudoku.cellAt(0,1).index().should.equal 1
      sudoku.cellAt(1,0).index().should.equal 4
      sudoku.cellAt(3,3).index().should.equal 15

    it "should recognise contiguous cells", ->
      sudoku.cellAt(0,0).isNextTo(sudoku.cellAt(0,1)).should.equal true
      sudoku.cellAt(0,0).isNextTo(sudoku.cellAt(1,0)).should.equal true
      sudoku.cellAt(0,0).isNextTo(sudoku.cellAt(1,1)).should.equal false
      sudoku.cellAt(0,0).isNextTo(sudoku.cellAt(0,2)).should.equal false

    describe "entries", ->

      makeCell = () ->
        sudoku = new Sudoku A_VALID_4x4_GRID
        sudoku.cellAt 1, 1

      it "should start out empty", ->
        makeCell().entriesAsString().should.equal ''

      it "should accept an entry", ->
        cell = makeCell()
        cell.enter 1
        cell.entriesAsString().should.equal '1'

      it "should accept another entry", ->
        cell = makeCell()
        cell.enter 1
        cell.enter 2
        cell.entriesAsString().should.equal '12'

      it "should toggle entered values", ->
        cell = makeCell()
        cell.enter 1
        cell.enter 2
        cell.enter 1
        cell.entriesAsString().should.equal '2'

      it "should force entry if the force flag is set", ->
        cell = makeCell()
        cell.enter 1
        cell.enter 2
        cell.enter 1, true
        cell.entriesAsString().should.equal '1'

      it "should just ignore invalid entries", ->
        sudoku = new Sudoku A_VALID_4x4_GRID
        cell = sudoku.cellAt 0, 0
        cell.enter '5'
        cell.entriesAsString().should.equal ''

      describe "entry", ->

        it "should be undefined if no entries", ->
          cell = makeCell()
          (cell.entry() is undefined).should.equal true

        it "should be undefined if more than one entry", ->
          cell = makeCell()
          cell.enter 2
          cell.enter 3
          (cell.entry() is undefined).should.equal true

        it "should be the entered value if there is only one of these", ->
          cell = makeCell()
          cell.enter 2
          cell.entry().should.equal 2

      describe "hasPreordainedEntry", ->

        it "should be false if no entries", ->
          cell = makeCell()
          cell.hasPreordainedEntry().should.equal false

        it "should be false if more than one entry", ->
          cell = makeCell()
          cell.enter value for value in [1..4]
          cell.hasPreordainedEntry().should.equal false

        it "should be true if the sole entered value is also the 'correct' value", ->
          cell = makeCell()
          cell.enter cell.value
          cell.hasPreordainedEntry().should.equal true

      describe "availableValues", ->

        it "should have only 1 available value (its own) where there are no nulls in play", ->
          cell = makeCell()
          cell.availableValues().length.should.equal 1
          cell.availableValues()[0].should.equal cell.value

        it "should have all available values where there are only nulls in play", ->
          sudoku = new Sudoku [0...16].map -> null
          sudoku.cellAt(1, 1).availableValues().join('').should.equal '1234'

  describe "completion", ->

    it "should start off incomplete", ->
      sudoku = new Sudoku [1]
      sudoku.isComplete().should.equal false

    it "should be complete when all blocks report complete", ->
      sudoku = new Sudoku [1]
      cell = sudoku.cellAt(0, 0)
      cell.enter 1
      sudoku.isComplete().should.equal true

  describe "completion with 'preordained' values", ->

    it "should start off incomplete", ->
      sudoku = new Sudoku A_VALID_4x4_GRID
      sudoku.isCompleteWithPreordainedEntries().should.equal false

    it "should be complete when all blocks report complete", ->
      sudoku = new Sudoku A_VALID_4x4_GRID
      for cell in sudoku.cells
        cell.hasPreordainedEntry().should.equal false
        cell.enter cell.value
        cell.hasPreordainedEntry().should.equal true
      sudoku.isComplete().should.equal true
      sudoku.isCompleteWithPreordainedEntries().should.equal true

  describe "JSON friendly persistence", ->

    describe "toObject", ->

      it "should reflect the sudoku values and entries in a stringy kinda way", ->
        sudoku = new Sudoku A_VALID_4x4_GRID
        sudoku.toObject().values.should.equal '1,2,3,4,3,4,1,2,2,3,4,1,4,1,2,3'
        sudoku.toObject().entries.should.equal ',,,,,,,,,,,,,,,'

      it "should capture entries at a point in time", ->
        sudoku = new Sudoku A_VALID_4x4_GRID
        sudoku.cellAt(0,0).enter 1
        sudoku.cellAt(0,0).enter 2
        sudoku.toObject().entries.should.equal '12,,,,,,,,,,,,,,,'

    describe "fromObject", ->

      it "should be possible to create a new Sudoku from a JSON object", ->
        obj =
          values: '1,2,3,4,3,4,1,2,2,3,4,1,4,1,2,3'
          entries: '12,,,,,,,,,,,,,,,'
        sudoku = Sudoku.fromObject obj
        sudoku.cellAt(0,0).value.should.equal 1
        sudoku.cellAt(0,0).entriesAsString().should.equal '12'

      it "should be possible to round trip to object from object", ->
        sudoku = new Sudoku A_VALID_4x4_GRID
        sudoku.cellAt(0,0).enter 1
        sudoku.cellAt(0,0).enter 2
        clone = Sudoku.fromObject sudoku.toObject()
        sudoku.toObject().values.should.equal clone.toObject().values
        sudoku.toObject().entries.should.equal clone.toObject().entries

      it "should be possible to round trip via json as well", ->
        sudoku = new Sudoku A_VALID_4x4_GRID
        sudoku.cellAt(0,0).enter 1
        sudoku.cellAt(0,0).enter 2
        sudokuAsJsonString = json.stringify sudoku.toObject()
        clone = Sudoku.fromObject json.parse(sudokuAsJsonString)
        sudoku.toObject().values.should.equal clone.toObject().values
        sudoku.toObject().entries.should.equal clone.toObject().entries

  describe "change and undo / redo", ->

    sudoku = null
    cell = null

    beforeEach ->
      sudoku = new Sudoku A_VALID_4x4_GRID
      cell = sudoku.cellAt 0, 0
      sudoku.changeListener =
        numChanges: 0
        changed: (sudoku) -> @numChanges++

    describe "change listener", ->

      it "should call the listener every time there is a change", ->
        cell.enter 1
        cell.enter 2
        sudoku.changeListener.numChanges.should.equal 2

      it "should call the listener every time there is a change (and only if there is a change)", ->
        cell.enter 1, true
        cell.enter 1, true
        cell.enter 'banana'
        sudoku.changeListener.numChanges.should.equal 1

      it "should not explode if there is no change listener", ->
        sudoku.changeListener = undefined
        cell.enter 1
        cell.enter 2

    describe "undo / redo", ->

      undoAndExpect = (expected) ->
        sudoku.undo()
        cell.entriesAsString().should.equal expected

      redoAndExpect = (expected) ->
        sudoku.redo()
        cell.entriesAsString().should.equal expected

      it "should be able to undo and redo previous entries (and not explode if there is nothing to do)", ->
        cell.enter value for value in [1,2,3]
        cell.entriesAsString().should.equal '123'
        undoAndExpect '12'
        undoAndExpect '1'
        undoAndExpect ''
        undoAndExpect ''
        redoAndExpect '1'
        redoAndExpect '12'
        redoAndExpect '123'
        redoAndExpect '123'
        undoAndExpect '12'
        redoAndExpect '123'

      it "should still undo/redo correctly for forced entries", ->
        cell.enter value, true for value in [1,2,3]
        cell.entriesAsString().should.equal '3'
        undoAndExpect '2'
        redoAndExpect '3'
        undoAndExpect '2'
        undoAndExpect '1'
        undoAndExpect ''
        undoAndExpect ''
        redoAndExpect '1'

      it "should reset history jumping whenever there is an explicit entry ", ->
        cell.enter value for value in [1,2,3]
        cell.entriesAsString().should.equal '123'
        undoAndExpect '12'
        cell.enter 4, true
        redoAndExpect '4'
        redoAndExpect '4'
        undoAndExpect '12'
        redoAndExpect '4'

describe "Killer", ->

  it "should complain if length of regions array does not match that of values array", ->
    ( -> new Killer [1], [1,2] ).should.throw "Incorrect number of regions you bozo"

  values = [
    4,1,2,3
    3,2,4,1,
    1,4,3,2,
    2,3,1,4
  ]

  regions = [
    1,1,2,2,
    1,3,4,2,
    5,5,6,6,
    7,7,8,8
  ]

  it "should be able to round trip region ids", ->
    killer = new Killer values, regions
    killer.regionIds().join('').should.equal regions.join ''

  it "should create 8 regions", ->
    killer = new Killer values, regions
    killer.regions.length.should.equal 8

  it "should set the regions up correctly such that region sums are as they should be", ->
    killer = new Killer values, regions
    killer.regions[0].sum().should.equal 8
    killer.regions[7].sum().should.equal 5

  it "should start out incomplete", ->
    killer = new Killer values, regions
    killer.isComplete().should.equal false

  it "should recognise completion", ->
    killer = new Killer values, regions
    cell.enter cell.value for cell in killer.cells
    killer.isComplete().should.equal true

  it "should do toObject() to return an object with string representation of cages as well as values and entries", ->
    killer = new Killer values, regions
    killer.toObject().values.should.equal '4,1,2,3,3,2,4,1,1,4,3,2,2,3,1,4'
    killer.toObject().entries.should.equal ',,,,,,,,,,,,,,,'
    killer.toObject().regions.should.equal '1,1,2,2,1,3,4,2,5,5,6,6,7,7,8,8'

  it "should be possible to create a new Killer from a JSON object", ->
    obj =
      values: '4,1,2,3,3,2,4,1,1,4,3,2,2,3,1,4'
      entries: '12,,,,,,,,,,,,,,,'
      regions: '1,1,2,2,1,3,4,2,5,5,6,6,7,7,8,8'
    cell = Killer.fromObject(obj).cellAt 0, 0
    cell.value.should.equal 4
    cell.entriesAsString().should.equal '12'
    cell.region.id.should.equal 1

describe "Region", ->

  MOCK_VALID_SUDOKU = {size: 4, root: 2, validValues: [1,2,3,4], changed: ->}

  it "should know whether a cell is contained or not", ->

    cell1 = new Cell MOCK_VALID_SUDOKU, 0, 0, 1
    cell2 = new Cell MOCK_VALID_SUDOKU, 0, 1, 2
    cell3 = new Cell MOCK_VALID_SUDOKU, 0, 1, 3
    region = new Region 'whatever'
    region.push cell1
    region.push cell2

    region.contains(cell1).should.be.true
    region.contains(cell2).should.be.true
    region.contains(cell3).should.be.false

  it "should complain if a non-contiguous cell is pushed", ->

    region = new Region 'whatever'
    region.push new Cell MOCK_VALID_SUDOKU, 1, 1, 1
    region.push new Cell MOCK_VALID_SUDOKU, 2, 1, 2
    region.push new Cell MOCK_VALID_SUDOKU, 2, 0, 3
    region.push new Cell MOCK_VALID_SUDOKU, 3, 3, 4
    ( -> region.validate() ).should.throw "Non-contiguous cell 3,3:4 pushed to region 'whatever' you bozo"

  it "should test incompleteness based on sum of region and nothing else", ->

    region = new Region 'whatever'
    region.push new Cell MOCK_VALID_SUDOKU, 1, 1, 2
    region.push new Cell MOCK_VALID_SUDOKU, 2, 1, 3

    region.sum().should.equal 5
    region.isComplete().should.equal false

    region.cells[0].enter 1
    region.cells[1].enter 4
    region.isComplete().should.equal true



describe "9x9 grids", ->

  it "should all just work for these as well", ->

    values = [

      1,2,3,  4,5,6,  7,8,9
      4,5,6,  7,8,9,  1,2,3
      7,8,9,  1,2,3,  4,5,6

      2,3,1,  5,6,4,  8,9,7
      5,6,4,  8,9,7,  2,3,1
      8,9,7,  2,3,1,  5,6,4

      3,1,2,  6,4,5,  9,7,8
      6,4,5,  9,7,8,  3,1,2
      9,7,8,  3,1,2,  6,4,5

    ]

    regions = [

       1, 1, 2,    2, 3, 4,    4, 5, 5
       1, 6, 6,    3, 3, 3,    8, 8, 5
       9,10,11,   11,11,11,   11,12,13

       9,10,14,   15,15,16,   16,12,13
      14,14,14,   14,15,16,   16,16,16
      17,18,18,   15,15,15,   19,19,20

      17,18,21,   21,21,21,   21,19,20
      17,18,22,   23,21,24,   25,19,20
      22,22,22,   23,21,24,   25,25,25

    ]

    killer = new Killer values, regions

    killer.size.should.equal 9
    killer.root.should.equal 3
    killer.rows[0].values().join('').should.equal '123456789'
    killer.cols[0].values().join('').should.equal '147258369'
    killer.boxes[0].values().join('').should.equal '123456789'
    killer.validValues.join('').should.equal '123456789'
    killer.regions[0].sum().should.equal 7


describe "nulls", ->

  it "should allow nulls so that we can play with it", ->

    incompleteModel = [1,2,3,4]
    incompleteModel.push null for index in [incompleteModel.length..15]

    new Sudoku incompleteModel
