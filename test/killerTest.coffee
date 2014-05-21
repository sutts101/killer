{Sudoku, Cell, Killer, Region} = require '../src/killer'

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

  describe 'well formed', ->

    xit 'should complain if a non-contiguous cell is pushed', ->
      region = new Region('whatever')
      region.push(new Cell {size: 9}, 0, 1)
      ( -> region.push(new Cell {size: 9}, 3, 1)).should.throw 'Non-contiguous cell pushed to region you bozo'
