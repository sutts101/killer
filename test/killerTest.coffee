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

describe 'Killer', ->

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
