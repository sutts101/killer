{Sudoku, Cell, Killer, Region} = require '../src/killerModel'

chai = require 'chai'
chai.should()

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

    it "should recognise contiguous cells", ->
      sudoku = new Sudoku A_VALID_4x4_GRID
      sudoku.cellAt(0,0).isNextTo(sudoku.cellAt(0,1)).should.equal true
      sudoku.cellAt(0,0).isNextTo(sudoku.cellAt(1,0)).should.equal true
      sudoku.cellAt(0,0).isNextTo(sudoku.cellAt(1,1)).should.equal false
      sudoku.cellAt(0,0).isNextTo(sudoku.cellAt(0,2)).should.equal false

    describe "entries", ->

      makeCell = () ->
        sudoku = new Sudoku A_VALID_4x4_GRID
        cell = sudoku.cellAt 1, 1

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

      it "should just ignore invalid entries", ->
        sudoku = new Sudoku A_VALID_4x4_GRID
        cell = sudoku.cellAt 0, 0
        cell.enter '5'
        cell.entriesAsString().should.equal ''

describe "Killer", ->

  describe "constructor (unhappy path)", ->

    it "should complain if length of regions array does not match that of values array", ->
      ( -> new Killer [1], [1,2] ).should.throw "Incorrect number of regions you bozo"

  describe "constructor (happy path)", ->

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

    killer = new Killer values, regions

    it "should create 8 regions", ->
      killer.regions.length.should.equal 8

    describe "region (integration context)", ->

      it "should sum the values of the contained cells", ->
        killer.regions[0].sum().should.equal 8
        killer.regions[7].sum().should.equal 5

describe "Region", ->

  MOCK_VALID_SUDOKU = {size: 4, root: 2}

  describe "sum", ->

    it "should be the sum of the values of the contained cells", ->
      region = new Region('whatever')
      region.push new Cell MOCK_VALID_SUDOKU, 0, 0, 3
      region.push new Cell MOCK_VALID_SUDOKU, 0, 1, 4
      region.sum().should.equal 7

  describe "contains", ->

    cell1 = new Cell MOCK_VALID_SUDOKU, 0, 0, 1
    cell2 = new Cell MOCK_VALID_SUDOKU, 0, 1, 2
    cell3 = new Cell MOCK_VALID_SUDOKU, 0, 1, 3
    region = new Region 'whatever'
    region.push cell1
    region.push cell2

    it "should know whether a cell is contained or not", ->
      region.contains(cell1).should.be.true
      region.contains(cell2).should.be.true
      region.contains(cell3).should.be.false


  describe "well formed", ->

    it "should complain if a non-contiguous cell is pushed", ->
      region = new Region 'whatever'
      region.push new Cell MOCK_VALID_SUDOKU, 1, 1, 1
      region.push new Cell MOCK_VALID_SUDOKU, 2, 1, 2
      region.push new Cell MOCK_VALID_SUDOKU, 2, 0, 3
      region.push new Cell MOCK_VALID_SUDOKU, 3, 3, 4
      ( -> region.validate() ).should.throw 'Non-contiguous cell (3,3) pushed to region you bozo'

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

      9,10,14,    14,15,16,   16,12,13
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

    sudoku = new Sudoku incompleteModel
