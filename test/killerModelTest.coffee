{Sudoku, Cell, Killer, Region} = require '../src/killerModel'

chai = require 'chai'
chai.should()

describe 'Sudoku', ->

  describe 'constructor', ->

    it 'should like squares', ->
      new Sudoku [1,2,3,4]

    it 'should dislike non-squares', ->
      ( -> new Sudoku [1,2,3] ).should.throw "That's not a valid square you bozo"

    it 'should compute its size as the square root of the number of cells', ->
      new Sudoku([1,2,3,4]).size.should.equal 2

  describe 'grid', ->

    sudoku = new Sudoku [
      1,2,3,
      4,5,6,
      7,8,9
    ]

    describe 'cell_at', ->

      it 'should allow access by row and column (both zero-based for now)', ->
        sudoku.cell_at(0,0).value.should.equal 1
        sudoku.cell_at(1,0).value.should.equal 4
        sudoku.cell_at(2,2).value.should.equal 9

    describe 'cell_at_index', ->

      it 'should allow access by array index', ->
        sudoku.cell_at_index(0).value.should.equal 1
        sudoku.cell_at_index(3).value.should.equal 4
        sudoku.cell_at_index(8).value.should.equal 9

    describe 'cell movement', ->

      move_and_expect_cell = (start_row, start_column, movement, end_row, end_column) ->
        start_cell = sudoku.cell_at start_row, start_column
        end_cell = start_cell[movement]()
        end_cell.row().should.equal end_row
        end_cell.col().should.equal end_column

      it "should go up, down, left and right when it can", ->
        move_and_expect_cell 1, 1, 'up',    0, 1
        move_and_expect_cell 1, 1, 'down',  2, 1
        move_and_expect_cell 1, 1, 'left',  1, 0
        move_and_expect_cell 1, 1, 'right', 1, 2

      move_and_expect_undefined = (start_row, start_column, movement, end_row, end_column) ->
        start_cell = sudoku.cell_at start_row,start_column
        end_cell = start_cell[movement]()
        (end_cell is undefined).should.be.true

      it "should not go up, down, left or right when it can't", ->
        move_and_expect_undefined 0, 1, 'up'
        move_and_expect_undefined 2, 1, 'down'
        move_and_expect_undefined 1, 0, 'left'
        move_and_expect_undefined 1, 2, 'right'

describe 'Cell', ->

  it 'should know its row based on index and size of the sudoku grid', ->
    new Cell( {size: 9},  0, 2).row().should.equal 0
    new Cell( {size: 9},  8, 2).row().should.equal 0
    new Cell( {size: 9},  9, 2).row().should.equal 1
    new Cell( {size: 9}, 19, 2).row().should.equal 2

  it 'should know its column based on index and size of the sudoku grid', ->
    new Cell( {size: 9},  0, 2).col().should.equal 0
    new Cell( {size: 9},  8, 2).col().should.equal 8
    new Cell( {size: 9},  9, 2).col().should.equal 0
    new Cell( {size: 9}, 19, 2).col().should.equal 1

  it 'should recognise contiguous cells', ->
    cells = [1,2,3,4].map (value,index) -> new Cell({size: 2}, index, value)
    cells[0].is_next_to(cells[1]).should.equal true
    cells[0].is_next_to(cells[2]).should.equal true
    cells[0].is_next_to(cells[3]).should.equal false
    cells[1].is_next_to(cells[0]).should.equal true
    cells[2].is_next_to(cells[0]).should.equal true
    cells[3].is_next_to(cells[0]).should.equal false


describe 'Killer', ->

  describe 'constructor (unhappy path)', ->

    it 'should complain if regions array does not match values array', ->
      ( -> new Killer new Sudoku([1,2,3,4]), [1,2,3] ).should.throw "Incorrect number of regions you bozo"

  describe 'constructor (happy path)', ->

    sudoku = new Sudoku [
      1,2,3,4,
      2,3,4,1,
      3,4,1,2,
      4,1,2,3
    ]

    killer = new Killer sudoku, [
      1,1,2,2,
      3,3,4,4,
      5,5,6,6,
      7,7,8,8
    ]

    it 'should create 8 regions', ->
      killer.regions.length.should.equal 8

    describe 'region (integration context)', ->

      it 'should sum the values of the contained cells', ->
        killer.regions[0].sum().should.equal 3
        killer.regions[1].sum().should.equal 7

describe 'Region', ->

  describe 'sum', ->

    it 'should be the sum of the values of the contained cells', ->
      region = new Region('whatever')
      region.push(new Cell {size: 4}, 0, 3)
      region.push(new Cell {size: 9}, 1, 4)
      region.sum().should.equal 7

  describe "contains", ->

    cell1 = new Cell {size: 4}, 0, 3
    cell2 = new Cell {size: 4}, 1, 3
    cell3 = new Cell {size: 4}, 2, 3
    region = new Region 'whatever'
    region.push cell1
    region.push cell2

    it "should know whether a cell is contained or not", ->
      region.contains(cell1).should.be.true
      region.contains(cell2).should.be.true
      region.contains(cell3).should.be.false


  describe 'well formed', ->

    xit 'should complain if a non-contiguous cell is pushed', ->
      region = new Region('whatever')
      region.push(new Cell {size: 9}, 0, 1)
      ( -> region.push(new Cell {size: 9}, 3, 1)).should.throw 'Non-contiguous cell pushed to region you bozo'
