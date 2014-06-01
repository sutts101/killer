class SumCalculator

  constructor: (@values) ->

  calculate: (sum, length) ->

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

    solutions

root = exports ? window
root.SumCalculator = SumCalculator
