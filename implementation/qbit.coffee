math = require 'mathjs'

class Qbit
    # Qbit = a*|0> + b*|1> = a*(1,0) + b*(0,1) / |a|^2 + |b|^2 = 1
    constructor: (alpha, beta) ->
        @state = math.add [alpha, 0], [0, beta]
        @state = math.multiply( 1/math.norm(@state), @state ) #normalization

    getZero: ->
        @state[0]

    getOne: ->
        @state[1]


class QuantumGate
    constructor: (@matrix) ->
        console.log @matrix

    action: (qbit) ->
        math.multiply @matrix, qbit.state


#test
q = new Qbit 2, 4
console.log q.getZero()**2 + q.getOne()**2

matrix = math.multiply( 1/math.sqrt(2), [
    [1, 1],
    [1,-1]
] )
hadamard = new QuantumGate matrix
console.log hadamard.action q
