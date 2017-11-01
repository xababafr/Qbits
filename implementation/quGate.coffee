#math = require 'mathjs'

#this class represents a quantum state
###class QuGate
    constructor: (@dim, @matrix) ->

    action(coeffs,targets) ->
        #first, we construct a vector ou

    # grows the @matrix
    grow: (newDim) ->
        if(newDim - @dim) <= 0
            false
        else
            for i in [1..(newDim - @dim)]
                @matrix = math.kron( @matrix, math.eye(2) )
                console.log @matrix._data

hadamard = new QuGate(1, math.multiply((1/Math.sqrt(2)), math.matrix([
    [1, 1],
    [1,-1]
])) )
# THIS CLASS IS ABANDONNED
###

# sadly it doesnt really help.....

#hadamard = new QuGate 1, math.matrix( [[1]] )
#hadamard.grow 3
