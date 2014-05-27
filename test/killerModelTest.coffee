{Sudoku, Cell, Killer, Region} = require '../src/killerModel'

chai = require 'chai'
chai.should()

A_VALID_4x4_GRID = [
  1,2,3,4,
  2,3,4,1,
  3,4,1,2,
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

    it 'should do sums for all blocks and they should all be the same', ->
      for blockType in ['rows', 'cols', 'boxes']
        for index in [0..3]
          sudoku[blockType][index].sum().should.equal 10

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

describe "Cell", ->

  it "should recognise contiguous cells", ->
    sudoku = new Sudoku A_VALID_4x4_GRID
    sudoku.cellAt(0,0).isNextTo(sudoku.cellAt(0,1)).should.equal true
    sudoku.cellAt(0,0).isNextTo(sudoku.cellAt(1,0)).should.equal true
    sudoku.cellAt(0,0).isNextTo(sudoku.cellAt(1,1)).should.equal false
    sudoku.cellAt(0,0).isNextTo(sudoku.cellAt(0,2)).should.equal false

  describe "entries", ->

    makeCell = () ->
      cell = new Cell {}, 0, 2

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

describe "Killer", ->

  describe "constructor (unhappy path)", ->

    it "should complain if length of regions array does not match that of values array", ->
      ( -> new Killer [1], [1,2] ).should.throw "Incorrect number of regions you bozo"

  describe "constructor (happy path)", ->

    values = [
      4,1,2,3
      3,4,1,2,
      1,2,3,4,
      2,3,4,1,
    ]

    regions = [
      1,1,2,2,
      3,3,4,4,
      5,5,6,6,
      7,7,8,8
    ]

    killer = new Killer values, regions

    it "should create 8 regions", ->
      killer.regions.length.should.equal 8

    describe "region (integration context)", ->

      it "should sum the values of the contained cells", ->
        killer.regions[0].sum().should.equal 5
        killer.regions[2].sum().should.equal 7

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

    xit "should complain if a non-contiguous cell is pushed", ->
      region = new Region 'whatever'
      region.push new Cell MOCK_VALID_SUDOKU, 1, 1, 1
      region.push new Cell MOCK_VALID_SUDOKU, 2, 1, 2
      region.push new Cell MOCK_VALID_SUDOKU, 2, 0, 3
      ( -> region.push new Cell MOCK_VALID_SUDOKU, 3, 3, 4).should.throw 'Non-contiguous cell (3,3) pushed to region you bozo'
