# this class represents the quantum state of a register of qubits
class QuState extends QuObject
    # we suppose coeffs.length == dim
    # dim is needed, coeffs might be optional, measured is a boolean
    constructor: (@dim, coeffs = [], @measured = false) ->
        super()
        @coeffs = if (coeffs.length == 0) then ( @genCoeffs(@dim) ) else coeffs
        @coeffs = math.multiply( 1/math.norm(@coeffs), @coeffs ) #normalization

    # (int dim) -> (array complex [a1, ... an]) / n = 2^dim
    genCoeffs: (dim) ->
        [ret, reals, ims] = [ [], math.random([1,@dim])[0], math.random([1,@dim])[0] ]
        for i in [0...Math.pow(2,@dim)]
            ret.push( math.complex(reals[i],ims[i]) )
        ret

    # (QuState state) -> (QuState postMeasureState = finalState)
    getProbas: () ->
        #array of the probability of each state to be measured, the random choice, a sum, and the future return result
        probas = []
        for i in [0...Math.pow(2,@dim)]
            # c'est pas propre mathématiquement mais ça marche et c'est + rapide
            probas.push( Math.pow( math.norm([@coeffs[i]]),2 ) )
        probas

    # return the state after measurment
    measure: () ->
        [probas, choice, sum, result] = [ @getProbas(), math.random(), 0, [] ]
        #console.log 'CHOICE : ' + choice
        for i in [0...Math.pow(2,@dim)]
            [prevSum, sum] = [sum, sum+probas[i]]
            result.push( if(choice >= prevSum && choice <= sum) then 1 else 0 )
        #console.log 'RESULT : [' + result + ']'
        new QuState(@dim, result, true)

    # if the state is measured, return the value of the n-th bit.
    getQubit: (n) ->
        if (!@measured)
            false
        else
            @coeffs[n-1]

    getCoeffs: () ->
        @coeffs

    getState: () ->
        ret = ''
        for i in [0...Math.pow(2,@dim)]
            if @coeffs[i] != 0
                ret += '(' + @coeffs[i] + ')*|' + (@toBin i, @dim) + '> + '
        ret.slice(0,-2)
        #ret.slice(-2)

    isMeasured: () ->
        @measured
