math = require 'mathjs'

class QuObject
    constructor: () ->

    # (array a#, array a2) -> (float |<a1/a2>|^2)
    prodSc: (a1,a2) ->
        math.norm( math.dot(a1,a2) )^2

    # "00010010" -> [0,0,0,1,0,0,1,0]
    getArr: (str) ->
        ret = []
        for i in [0...str.length]
            ret.push( parseInt(str[i]) )
        ret

    # [0,0,0,1,0,0,1,0] -> "00010010"
    getStr: (arr) ->
        ret = ""
        for i in [0...arr.length]
            ret +=  "" + arr[i] + ""
        ret

    toBin: (int, dim) ->
        bin = int.toString(2)
        for i in [0...(dim - bin.length)]
            bin = "0" + bin
        bin
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
# MAIN #

Q = new QuObject

strReplace = (str, index, replacement) ->
    str.substr(0, index) + replacement + str.substr(index + replacement.length)

swap = (quSt, x, y) ->
    newCoeffs = ( 0 for [1..(Math.pow(2,quSt.dim))] )
    #console.log newCoeffs

    for i in [0...(Math.pow(2,quSt.dim))]
        bin = (Q.toBin i, quSt.dim).split('')
        [ bin[x], bin[y] ] = [ bin[y], bin[x] ]
        bin = bin.join('')
        #console.log "new bin : " + bin
        newCoeffs[parseInt(bin,2)] = quSt.coeffs[i]

    new QuState quSt.dim, newCoeffs

hadamard = (quSt, x) ->
    newCoeffs = ( 0 for [1..(Math.pow(2,quSt.dim))] )

    for i in [0...(Math.pow(2,quSt.dim))]
        bin = (Q.toBin i, quSt.dim)
        if (bin[x] == "0") # H(|0>) = ( 1/sqrt(2) )*( |0> + |1> )
            [c1,c2] = [bin, (strReplace bin, x, "1" )]
            newCoeffs[parseInt(c1,2)] += (quSt.coeffs[i]/Math.sqrt(2))
            newCoeffs[parseInt(c2,2)] += (quSt.coeffs[i]/Math.sqrt(2))
        else # H(|1>) = ( 1/sqrt(2) )*( |0> - |1> )
            [c1,c2] = [(strReplace bin, x, "0" ), bin]
            newCoeffs[parseInt(c1,2)] += (quSt.coeffs[i]/Math.sqrt(2))
            newCoeffs[parseInt(c2,2)] -= (quSt.coeffs[i]/Math.sqrt(2))

    new QuState quSt.dim, newCoeffs

hadamardAll = (quSt) ->
    ret = quSt
    for i in [0...quSt.dim]
        ret = hadamard(ret, i)
    ret

notGate = (quSt, x) ->
    newCoeffs = ( 0 for [1..(Math.pow(2,quSt.dim))] )

    for i in [0...(Math.pow(2,quSt.dim))]
        bin = (Q.toBin i, quSt.dim)
        if (bin[x] == "0") # NOT(|0>) = |1>
            bin = strReplace(bin, x, "1")
        else # NOT(|1>) = |0>
            bin = strReplace(bin, x, "0")
        newCoeffs[parseInt(bin,2)] += quSt.coeffs[i]

    new QuState quSt.dim, newCoeffs

# x = control qubit, y = changed qubit
CnotGate = (quSt, x,y) ->
    newCoeffs = ( 0 for [1..(Math.pow(2,quSt.dim))] )

    for i in [0...(Math.pow(2,quSt.dim))]
        bin = (Q.toBin i, quSt.dim)
        if (bin[x] == "1")
            console.log bin
            if (bin[y] == "0") # NOT(|0>) = |1>
                console.log " --> un"
                bin = strReplace(bin, y, "1")
            else # NOT(|1>) = |0>
                console.log " --> zero"
                bin = strReplace(bin, y, "0")
            console.log bin + "///"
        newCoeffs[parseInt(bin,2)] += quSt.coeffs[i]

    new QuState quSt.dim, newCoeffs

#st = new QuState(3, [math.complex(0,4),0,0,4,0,0,0,0])
#console.log "before measure : " + st.getState()
#console.log "after  measure : " + st.measure().getState()

st2 = new QuState(3, [0,1,0,0,0,0,0,0])
console.log "SWAP(0,2) : " + st2.getState() + " ---> " + (swap st2, 0, 2).getState()

st3 = new QuState(3, [1,0,0,0,0,0,0,1])
console.log "HADAMARD(0) : " + st3.getState() + " ---> " + (hadamard st3, 0).getState()
console.log "HADAMARD ALL : " + st3.getState() + " ---> " + (hadamardAll st3).getState()

st4 = new QuState(3, [0,0,0,0,0,0,0,1])
console.log "NOT(0) : " + st4.getState() + " ---> " + (notGate st4, 0).getState()

st5 = new QuState(3, [0,0,0,0,1,0,0,0])
console.log "CNOT(0,2) : " + st5.getState() + " ---> " + (CnotGate st5, 0, 2).getState()
