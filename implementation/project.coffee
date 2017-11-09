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
    # this function seems useless, since [0,0,0,1,0,0,1,0] != "00010010"
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

    strReplace: (str, index, replacement) ->
        str.substr(0, index) + replacement + str.substr(index + replacement.length)
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
            if math.norm(@coeffs[i]) != 0
                ret += '(' + @coeffs[i] + ')*|' + (@toBin i, @dim) + '> + '
        ret.slice(0,-2)

    isMeasured: () ->
        @measured
class QuRegister extends QuObject
    # give "|001>", "/001>", or [0,1,0,0,0,0,0,0], which represents the same state
    # later, should add an option to just generate a random register of the dim specified
    constructor: (st) ->
        super()
        if ( (st[0] == "|") || (st[0] == "/") )  &&  ( st[(st.length)-1] == ">" )
            bin = st.slice(1,(st.length)-1)
            dim = bin.length
            arr = ( 0 for [1..(Math.pow(2,dim))] )
            arr[parseInt(parseInt(bin,2))] = 1
        else
            dim = parseInt Math.log2(st.length)
            arr = st

        @quState = new QuState dim, arr


    getState: () ->
        @quState.getState()

    p: (st) ->
        console.log '[' + st + '] '+ @getState()
        @


    measure: () ->
        #replace the quState with its value after measurment
        @quState = @quState.measure()
        @


    hadamard: (x) ->
        dim = @quState.dim
        newCoeffs = ( 0 for [1..(Math.pow(2,dim))] )

        for i in [0...(Math.pow(2,dim))]
            bin = (@toBin i, dim)
            if (bin[x] == "0") # H(|0>) = ( 1/sqrt(2) )*( |0> + |1> )
                [c1,c2] = [bin, (@strReplace bin, x, "1" )]
                newCoeffs[parseInt(c1,2)] += (@quState.coeffs[i]/Math.sqrt(2))
                newCoeffs[parseInt(c2,2)] += (@quState.coeffs[i]/Math.sqrt(2))
            else # H(|1>) = ( 1/sqrt(2) )*( |0> - |1> )
                [c1,c2] = [(@strReplace bin, x, "0" ), bin]
                newCoeffs[parseInt(c1,2)] += (@quState.coeffs[i]/Math.sqrt(2))
                newCoeffs[parseInt(c2,2)] -= (@quState.coeffs[i]/Math.sqrt(2))

        @quState = new QuState dim, newCoeffs
        @


    hadamardAll: () ->
        ret = @quState
        for i in [0...@quState.dim]
            @hadamard i
        @


    swap: (x, y) ->
        dim = @quState.dim
        newCoeffs = ( 0 for [1..(Math.pow(2,dim))] )

        for i in [0...(Math.pow(2,dim))]
            bin = (@toBin i, dim).split('')
            [ bin[x], bin[y] ] = [ bin[y], bin[x] ]
            bin = bin.join('')
            newCoeffs[parseInt(bin,2)] = @quState.coeffs[i]

        @quState = new QuState dim, newCoeffs
        @


    not: (x) ->
        dim = @quState.dim
        newCoeffs = ( 0 for [1..(Math.pow(2,dim))] )

        for i in [0...(Math.pow(2,dim))]
            bin = (@toBin i, dim)
            if (bin[x] == "0") # NOT(|0>) = |1>
                bin = @strReplace(bin, x, "1")
            else # NOT(|1>) = |0>
                bin = @strReplace(bin, x, "0")
            newCoeffs[parseInt(bin,2)] += @quState.coeffs[i]

        @quState = new QuState dim, newCoeffs
        @


    cnot: (x,y) ->
        dim = @quState.dim
        newCoeffs = ( 0 for [1..(Math.pow(2,dim))] )

        for i in [0...(Math.pow(2,dim))]
            bin = (@toBin i, dim)
            if (bin[x] == "1")
                if (bin[y] == "0") # NOT(|0>) = |1>
                    bin = @strReplace(bin, y, "1")
                else # NOT(|1>) = |0>
                    bin = @strReplace(bin, y, "0")
            newCoeffs[parseInt(bin,2)] += @quState.coeffs[i]

        @quState = new QuState dim, newCoeffs
        @


    phase: (x,phi) ->
        dim = @quState.dim
        newCoeffs = ( 0 for [1..(Math.pow(2,dim))] )

        for i in [0...(Math.pow(2,dim))]
            bin = (@toBin i, dim)
            if (bin[x] == "1")
                newCoeffs[parseInt(bin,2)] = math.multiply(math.complex({r : 1, phi : phi}), @quState.coeffs[i])
            else
                newCoeffs[parseInt(bin,2)] = @quState.coeffs[i]

        @quState = new QuState dim, newCoeffs
        @


    cphase: (x,y,phi) ->
        dim = @quState.dim
        newCoeffs = ( 0 for [1..(Math.pow(2,dim))] )

        for i in [0...(Math.pow(2,dim))]
            bin = (@toBin i, dim)
            if (bin[x] == "1" && bin[y] == "1")
                newCoeffs[parseInt(bin,2)] = math.multiply(math.complex({r : 1, phi : phi}), @quState.coeffs[i])
            else
                newCoeffs[parseInt(bin,2)] = @quState.coeffs[i]

        @quState = new QuState dim, newCoeffs
        @

#reg = new QuRegister "/001>"
#reg2 = new QuRegister [0,1,0,0,0,0,0,0]
#reg3 = new QuRegister "|001>"
#reg4 = new QuRegister "/110>"
###

pour la classe QuRegister, chaque porte retourne this ( = @) pour pouvoir chainer les appels. Malgré cette possibilité, j'ai décidé que chaque appel à un porte modifierait l'objet en lui meme . Ainsi, on peux faire myreg.unePorteQuantique() puis observer myReg : il aura subit les modifications de la porte concernée.

Concernant la manière de coder les portes, pour le moment, je n'ai pas utilisé les matrices, car ça m'a aidé à mieux comprendre de faire ça "à la main". Dans l'avenir, je repasserai peut etre par la représentation matricielle. Je me demande cela dit s'il n'y a pas un léger gachis de calculs en utilisant les matrices.

###

# testing measure()
reg0 = new QuRegister [math.complex(0,4),0,0,4,0,0,0,0]
console.log "before measure : " + reg0.getState()
reg0.measure()
console.log "after  measure : " + reg0.getState()

# testing hadamard
reg1 = new QuRegister [1,0,0,0,0,0,1,0]
console.log "HADAMARD(0) : " + reg1.getState() + " ---> " + reg1.hadamard(0).getState()

# testing hadamard on all qubits
reg2 = new QuRegister [1,0,0,0,0,0,1,0]
console.log "HADAMARD ALL : " + reg2.getState() + " ---> " + reg2.hadamardAll().getState()

# testing swap on qubits 0 and 2
reg3 = new QuRegister "|001>" # = [0,1,0,0,0,0,0,0]
console.log "SWAP(0,2) : " + reg3.getState() + " ---> " + reg3.swap(0,2).getState()

# testing not on qubit 0
reg4 = new QuRegister "|001>"
console.log "NOT(0) : " + reg4.getState() + " ---> " + reg4.not(0).getState()

# testing cnot on qubit 2 with controlled qubit 0
reg5 = new QuRegister [0,0,0,0,1,0,0,0]
console.log "CNOT(0,2) : " + reg5.getState() + " ---> " + reg5.cnot(0,2).getState()

# testing phase on qubit 1
reg6 = new QuRegister "/010>"
console.log "PHASE(1,e^(i*PI/4)) : " + reg6.getState() + " ---> " + reg6.phase(1,(math.PI)/4).getState()

# testing phase on qubit 1 with controlled qubit 0
reg7 = new QuRegister "/110>"
console.log "CPHASE(0,1,e^(-i*PI/4)) : " + reg7.getState() + " ---> " + reg7.cphase(0,1,-(math.PI)/4).getState()

console.log "\n\n ------------------------------------------------------------------- \n\n"

reg8 = new QuRegister "/010>"
reg8.p('Init')
    .hadamard(1).p('Hadamard(1)')
    .swap(0,1)  .p( 'Swap(0,1)' )
    .cnot(0,2)  .p( 'Cnot(0,2)' )
    .not(0)     .p(   'Not(0)'  )
    .measure()  .p(' Measure()' )
