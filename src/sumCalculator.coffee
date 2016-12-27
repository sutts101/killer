_ = require 'lodash'

class SumCalculator

  constructor: (max) -> @values = [1..max]

  calculate: (sum, length, includes) ->

    solutions = []

    hunt = (values, working, value) ->
      candidate = working[0..working.length]
      candidate.push value
      if candidate.length < length
        for next in values[value...values.length]
          hunt values, candidate, next
      else
        solutions.push candidate if (candidate.reduce (x,y) -> x + y) is sum

    for value in @values
      hunt @values, [], value

    if includes? and includes.length > 0
      solutions = solutions.filter (a) ->
        _.intersection(a, includes).length is includes.length

    solutions

root = exports ? window
root.SumCalculator = SumCalculator
