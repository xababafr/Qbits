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
