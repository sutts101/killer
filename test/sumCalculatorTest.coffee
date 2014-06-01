{SumCalculator} = require '../src/sumCalculator'

chai = require 'chai'
chai.should()

describe 'SumCalculator', ->

  calc = new SumCalculator [1..4]

  it "should do length 1 stuff rather easily", ->
    for number in [1,2,3,4]
      calc.calculate(number, 1).join(',').should.equal "" + number

  it "should do unambiguous length 2 stuff as well", ->
    calc.calculate(3, 2).join(',').should.equal '1,2'
    calc.calculate(7, 2).join(',').should.equal '3,4'

  it "should do unambiguous length 3 stuff as well", ->
    calc.calculate(6, 3).join(',').should.equal '1,2,3'
    calc.calculate(7, 3).join(',').should.equal '1,2,4'
    calc.calculate(8, 3).join(',').should.equal '1,3,4'

  it "should do ambiguous stuff as well as well", ->
    solutions = calc.calculate(5, 2)
    solutions.length.should.equal 2
    solutions[0].join(',').should.equal '1,4'
    solutions[1].join(',').should.equal '2,3'

  it "should not be able to solve unsolvable things", ->
    calc.calculate(1, 2).join(',').should.equal ''
    calc.calculate(2, 2).join(',').should.equal ''
    calc.calculate(99, 3).join(',').should.equal ''


  calc9 = new SumCalculator [1..9]

  it "shouldn't make any difference working with bigger ranges", ->
    for number in [1..9]
      calc9.calculate(number, 1).join(',').should.equal "" + number
    calc9.calculate(16, 2).join(',').should.equal '7,9'
    calc9.calculate(17, 2).join(',').should.equal '8,9'
    calc9.calculate(23, 3).join(',').should.equal '6,8,9'
    calc9.calculate(24, 3).join(',').should.equal '7,8,9'
